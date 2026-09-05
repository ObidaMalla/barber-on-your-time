import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";

import { createNotification } from "./notificationsService.js"; // 👈 جديد

export const requestAvailabilityChange = async (userId, availabilityId, dayOfWeek, startTime, endTime) => {
  const staff = await prisma.staff.findUnique({
    where: { userId },
    include: { user: true, business: true }, // 👈 جديد — نحتاج اسم الموظف ومالك المحل
  });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق لطلب تعديل دوام");
  }

  const availability = await prisma.availability.findUnique({ where: { id: availabilityId } });
  if (!availability || availability.staffId !== staff.id) {
    throw new ApiError(404, "هاد الدوام مش تابع إلك");
  }

  const request = await prisma.availabilityChangeRequest.create({
    data: {
      type: "UPDATE",
      dayOfWeek,
      startTime,
      endTime,
      staffId: staff.id,
      availabilityId: availability.id,
    },
  });

  // 👇 جديد
  await createNotification({
    userId: staff.business.ownerId,
    type: "AVAILABILITY_REQUEST",
    title: "طلب تعديل دوام 📅",
    message: `الموظف "${staff.user.name}" طلب تعديل دوامو`,
    data: { requestId: request.id, staffId: staff.id },
  });

  return request;
};

export const getPendingRequests = async (ownerId) => {
  const business = await prisma.business.findUnique({ where: { ownerId } });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  return await prisma.availabilityChangeRequest.findMany({
    where: {
      status: "PENDING",
      staff: { businessId: business.id },
    },
    include: {
      staff: {
        select: {
          id: true,
          userId: true,
          user: { select: { id: true, name: true, email: true } },
        },
      },
    },
  });
};

// ===== جديد: طلبات الحلاق المعلقة هو نفسه (للفرونت) =====
export const getMyPendingRequests = async (userId) => {
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق");
  }

  return await prisma.availabilityChangeRequest.findMany({
    where: { staffId: staff.id, status: "PENDING" },
    orderBy: { createdAt: "desc" },
  });
};



export const respondToRequest = async (ownerId, requestId, decision) => {
  const business = await prisma.business.findUnique({
    where: { ownerId },
    include: { owner: true }, // 👈 جديد — نحتاج اسم المالك للإشعار
  });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  const request = await prisma.availabilityChangeRequest.findUnique({
    where: { id: requestId },
    include: { staff: true }, // 👈 staff.userId موجود فيها أصلاً
  });
  if (!request || request.staff.businessId !== business.id) {
    throw new ApiError(404, "الطلب مش موجود أو مش تابع لمحلك");
  }
  if (request.status !== "PENDING") {
    throw new ApiError(409, "تم الرد على هاد الطلب من قبل");
  }

  const actionLabel = request.type === "DELETE" ? "حذف" : "تعديل";

  if (decision === "REJECT") {
    const updated = await prisma.availabilityChangeRequest.update({
      where: { id: requestId },
      data: { status: "REJECTED" },
    });

    // 👇 جديد
    await createNotification({
      userId: request.staff.userId,
      type: "AVAILABILITY_RESPONSE",
      title: "تم رفض طلبك ❌",
      message: `رفض المدير "${business.owner.name}" طلب ${actionLabel} دوامك`,
      data: { requestId: updated.id },
    });

    return updated;
  }

  let updatedRequest;

  if (request.type === "DELETE") {
    [, updatedRequest] = await prisma.$transaction([
      prisma.availability.delete({ where: { id: request.availabilityId } }),
      prisma.availabilityChangeRequest.update({
        where: { id: requestId },
        data: { status: "APPROVED" },
      }),
    ]);
  } else {
    [, updatedRequest] = await prisma.$transaction([
      prisma.availability.update({
        where: { id: request.availabilityId },
        data: {
          dayOfWeek: request.dayOfWeek,
          startTime: request.startTime,
          endTime: request.endTime,
        },
      }),
      prisma.availabilityChangeRequest.update({
        where: { id: requestId },
        data: { status: "APPROVED" },
      }),
    ]);
  }

  // 👇 جديد
  await createNotification({
    userId: request.staff.userId,
    type: "AVAILABILITY_RESPONSE",
    title: "تم قبول طلبك ✅",
    message: `قبل المدير "${business.owner.name}" طلب ${actionLabel} دوامك`,
    data: { requestId: updatedRequest.id },
  });

  return updatedRequest;
};

export const requestAvailabilityDeletion = async (userId, availabilityId) => {
  const staff = await prisma.staff.findUnique({
    where: { userId },
    include: { user: true, business: true }, // 👈 جديد
  });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق لطلب حذف دوام");
  }

  const availability = await prisma.availability.findUnique({ where: { id: availabilityId } });
  if (!availability || availability.staffId !== staff.id) {
    throw new ApiError(404, "هاد الدوام مش تابع إلك");
  }

  const request = await prisma.availabilityChangeRequest.create({
    data: {
      type: "DELETE",
      dayOfWeek: availability.dayOfWeek,
      startTime: availability.startTime,
      endTime: availability.endTime,
      staffId: staff.id,
      availabilityId: availability.id,
    },
  });

  // 👇 جديد
  await createNotification({
    userId: staff.business.ownerId,
    type: "AVAILABILITY_REQUEST",
    title: "طلب حذف دوام 🗑️",
    message: `الموظف "${staff.user.name}" طلب حذف دوامو`,
    data: { requestId: request.id, staffId: staff.id },
  });

  return request;
};