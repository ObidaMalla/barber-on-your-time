import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";
import { findAvailableStaff } from "./bookingService.js";
import crypto from "crypto";
import { createNotification } from "./notificationsService.js"; // 👈 جديد

const generateCode = () => {
  return crypto.randomBytes(4).toString("hex").toUpperCase();
};

export const createStaffInvite = async (ownerId) => {
  const business = await prisma.business.findUnique({
    where: { ownerId },
  });
  if (!business) {
    throw new ApiError(404, "لا يمكنك توليد كود الدعوة لانك لا تمتلك محل");
  }

  const code = generateCode();

  const invite = await prisma.staffInvite.create({
    data: {
      code,
      businessId: business.id,
    },
  });

  return invite;
};

export const joinBusinessWithCode = async (userId, code) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (user.role === "OWNER") {
    throw new ApiError(403, "صاحب المحل ما بيقدر ينضم كموظف");
  }

  const existingStaff = await prisma.staff.findUnique({ where: { userId } });
  if (existingStaff && existingStaff.active) {
    throw new ApiError(409, "أنت أصلاً موظف بمحل");
  }

  const invite = await prisma.staffInvite.findUnique({
    where: { code },
    include: { business: true }, // 👈 جديد — نحتاج بيانات المحل والمالك
  });

  if (!invite) {
    throw new ApiError(404, "الكود مو صحيح");
  }

  if (invite.used) {
    throw new ApiError(409, "الكود مستخدم من قبل");
  }

  let staff;
  if (existingStaff) {
    staff = await prisma.staff.update({
      where: { id: existingStaff.id },
      data: { businessId: invite.businessId, active: true },
    });
  } else {
    staff = await prisma.staff.create({
      data: { userId, businessId: invite.businessId },
    });
  }

  await prisma.staffInvite.update({
    where: { id: invite.id },
    data: { used: true, usedByUserId: userId },
  });

  await prisma.user.update({
    where: { id: userId },
    data: { role: "STAFF" },
  });

  // 👇 جديد — إشعار المالك بانضمام الموظف
  await createNotification({
    userId: invite.business.ownerId,
    type: "STAFF_JOINED",
    title: "موظف جديد انضم 🎉",
    message: `الموظف "${user.name}" انضم إلى محلك`,
    data: { staffId: staff.id, joinedUserId: userId },
  });

  return staff;
};

export const removeStaff = async (ownerId, staffId) => {
  const business = await prisma.business.findUnique({ where: { ownerId } });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  const staff = await prisma.staff.findUnique({ where: { id: staffId } });
  if (!staff || staff.businessId !== business.id) {
    throw new ApiError(404, "هاد الموظف مش تابع لمحلك");
  }

  const pendingBookings = await prisma.booking.findMany({
    where: { staffId, status: "PENDING" },
  });

  for (const booking of pendingBookings) {
    const previousAttempts = await prisma.bookingAttempt.findMany({
      where: { bookingId: booking.id },
      select: { staffId: true },
    });
    const excludedStaffIds = previousAttempts.map((a) => a.staffId);

    const nextStaff = await findAvailableStaff(
      business.id,
      booking.serviceId,
      excludedStaffIds,
      booking.startTime
    );

    if (nextStaff) {
      await prisma.bookingAttempt.create({
        data: {
          bookingId: booking.id,
          staffId: nextStaff.id,
          order: previousAttempts.length + 1,
          status: "PENDING",
        },
      });
      await prisma.booking.update({
        where: { id: booking.id },
        data: { staffId: nextStaff.id },
      });
    } else {
      await prisma.booking.update({
        where: { id: booking.id },
        data: { status: "NEEDS_OWNER" },
      });
    }
  }

  await prisma.staff.update({
    where: { id: staffId },
    data: { active: false },
  });

  return await prisma.user.update({
    where: { id: staff.userId },
    data: { role: "CUSTOMER" },
  });
};