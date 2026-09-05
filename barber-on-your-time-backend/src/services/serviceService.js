import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";
import { createNotification } from "./notificationsService.js"; // 👈 إذا مش مستورد أصلاً

export const createService = async (ownerId, name, durationMinutes, price) => {
  const business = await prisma.business.findUnique({ where: { ownerId } });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  const service = await prisma.service.create({
    data: {
      name,
      durationMinutes,
      price,
      businessId: business.id,
    },
  });

  // 👇 جديد
  await createNotification({
    userId: ownerId,
    type: "SERVICE_ADDED",
    title: "تمت إضافة خدمة جديدة ✅",
    message: `تمت إضافة خدمة "${service.name}" إلى محلك بنجاح`,
    data: { serviceId: service.id },
  });

  return service;
};

export const getBusinessServices = async (ownerId) => {
  const business = await prisma.business.findUnique({ where: { ownerId } });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  return await prisma.service.findMany({ where: { businessId: business.id } });
};

export const updateService = async (ownerId, serviceId, name, durationMinutes, price) => {
  const business = await prisma.business.findUnique({ where: { ownerId } });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  const service = await prisma.service.findUnique({ where: { id: serviceId } });
  if (!service || service.businessId !== business.id) {
    throw new ApiError(404, "هاي الخدمة مش تابعة لمحلك");
  }

  return await prisma.service.update({
    where: { id: serviceId },
    data: { name, durationMinutes, price },
  });
};

export const deleteService = async (ownerId, serviceId) => {
  const business = await prisma.business.findUnique({ where: { ownerId } });
  if (!business) {
    throw new ApiError(404, "ما إلك محل مسجل");
  }

  const service = await prisma.service.findUnique({ where: { id: serviceId } });
  if (!service || service.businessId !== business.id) {
    throw new ApiError(404, "هاي الخدمة مش تابعة لمحلك");
  }

  // 1. التحقق أولاً فيما إذا كان للخدمة أي سجلات حجوزات (بأي حالة كانت)
  const existingBooking = await prisma.booking.findFirst({
    where: { serviceId },
  });

  if (existingBooking) {
    throw new ApiError(
      400,
      "لا يمكن حذف الخدمة لوجود حجوزات سابقة أو معلقة مرتبطة بها ❌"
    );
  }

  // 2. إذا لم ترتبط بأي حجز إطلاقاً، يتم الحذف بأمان
  try {
    await prisma.service.delete({ where: { id: serviceId } });
    return { message: "تم حذف الخدمة بنجاح" };
  } catch (error) {
    // التقاط إضافي لضمان عدم خروج خطأ 500
    if (error.code === "P2003") {
      throw new ApiError(
        400,
        "لا يمكن حذف الخدمة لوجود حجوزات مرتبطة بها ❌"
      );
    }
    throw error;
  }
};

// جلب خدمات محل معين للزبائن
export const getServicesByBusinessId = async (businessId) => {
  const business = await prisma.business.findUnique({
    where: { id: Number(businessId) },
  });

  if (!business) {
    throw new ApiError(404, "المحل غير موجود");
  }

  return await prisma.service.findMany({
    where: { businessId: Number(businessId) },
  });
};