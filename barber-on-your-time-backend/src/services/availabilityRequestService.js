import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";
import { createNotification } from "./notificationsService.js";

// 👈 نفس الدالة المستخدمة بباقي الملفات — تحقق وتحويل تاريخ YYYY-MM-DD
const parseDateOnly = (dateString) => {
  if (!dateString || typeof dateString !== "string") {
    throw new ApiError(400, "التاريخ مطلوب");
  }
  const match = dateString.trim().match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) {
    throw new ApiError(400, "صيغة التاريخ غير صالحة، المطلوب YYYY-MM-DD");
  }
  const parsed = new Date(`${dateString}T00:00:00`);
  if (isNaN(parsed.getTime())) {
    throw new ApiError(400, "صيغة التاريخ غير صالحة");
  }
  return parsed;
};

export const requestAvailabilityChange = async (userId, availabilityId, date, startTime, endTime) => {
  const staff = await prisma.staff.findUnique({
    where: { userId },
    include: { user: true, business: true },
  });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق لطلب تعديل دوام");
  }

  const availability = await prisma.availability.findUnique({ where: { id: availabilityId } });
  if (!availability || availability.staffId !== staff.id) {
    throw new ApiError(404, "هاد الدوام مش تابع إلك");
  }

  const parsedDate = parseDateOnly(date);
  const dayOfWeek = parsedDate.getDay(); // 👈 محسوب سيرفر-سايد دايماً

  if (!startTime || !endTime || startTime >= endTime) {
    throw new ApiError(400, "وقت البدء لازم يكون قبل وقت النهاية");
  }

  const request = await prisma.availabilityChangeRequest.create({
    data: {
      type: "UPDATE",
      date: parsedDate,
      dayOfWeek,
      startTime,
      endTime,
      staffId: staff.id,
      availabilityId: availability.id,
    },
  });

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
    orderBy: { createdAt: "desc" }, // 👈 جديد — ترتيب منطقي
  });
};

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
    include: { owner: true },
  });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  const request = await prisma.availabilityChangeRequest.findUnique({
    where: { id: requestId },
    include: { staff: true },
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
    // 👇 UPDATE — هلق لازم نتأكد ما في تعارض على staffId+date قبل التطبيق
    const conflict = await prisma.availability.findFirst({
      where: {
        staffId: request.staffId,
        date: request.date,
        id: { not: request.availabilityId },
      },
    });
    if (conflict) {
      throw new ApiError(409, "عندك دوام مسجل أصلاً بهاد التاريخ، ما فيك توافق عالطلب");
    }

    [, updatedRequest] = await prisma.$transaction([
      prisma.availability.update({
        where: { id: request.availabilityId },
        data: {
          date: request.date,       // 👈 جديد
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
    include: { user: true, business: true },
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
      date: availability.date,       // 👈 جديد — ناخد التاريخ من الدوام نفسه
      dayOfWeek: availability.dayOfWeek,
      startTime: availability.startTime,
      endTime: availability.endTime,
      staffId: staff.id,
      availabilityId: availability.id,
    },
  });

  await createNotification({
    userId: staff.business.ownerId,
    type: "AVAILABILITY_REQUEST",
    title: "طلب حذف دوام 🗑️",
    message: `الموظف "${staff.user.name}" طلب حذف دوامو`,
    data: { requestId: request.id, staffId: staff.id },
  });

  return request;
};