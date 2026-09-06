import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";

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

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  if (parsed < today) {
    throw new ApiError(400, "ما بتقدر تحدد دوام بتاريخ فات");
  }

  return parsed;
};

export const addAvailability = async (userId, date, startTime, endTime) => {
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق لتحديد دوامك");
  }

  const parsedDate = parseDateOnly(date);
  const dayOfWeek = parsedDate.getDay(); // 👈 محسوب من التاريخ، مش مأخوذ من الفرونت

  if (!startTime || !endTime || startTime >= endTime) {
    throw new ApiError(400, "وقت البدء لازم يكون قبل وقت النهاية");
  }

  const existing = await prisma.availability.findUnique({
    where: { staffId_date: { staffId: staff.id, date: parsedDate } },
  });
  if (existing) {
    throw new ApiError(409, "عندك دوام مسجل أصلاً بهاد التاريخ");
  }

  return await prisma.availability.create({
    data: {
      date: parsedDate,   // 👈 هاد كان مفقود
      dayOfWeek,          // 👈 هلق رقم صحيح، مش نص التاريخ
      startTime,
      endTime,
      staffId: staff.id,
    },
  });
};

export const getMyPendingRequest = async (userId) => {
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق");
  }
  return await prisma.availabilityChangeRequest.findFirst({
    where: { staffId: staff.id, status: "PENDING" },
  });
};

export const getMyAvailability = async (userId) => {
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق لعرض دوامك");
  }
  return await prisma.availability.findMany({
    where: { staffId: staff.id },
    orderBy: { date: "asc" },
  });
};