import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";

export const addAvailability = async (userId, dayOfWeek, startTime, endTime) => {
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق لتحديد دوامك");
  }

  return await prisma.availability.create({
    data: {
      dayOfWeek,
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

  const pendingRequest = await prisma.availabilityChangeRequest.findFirst({
    where: { staffId: staff.id, status: "PENDING" },
  });

  return pendingRequest; // ممكن يكون null لو ما في طلب معلق
};

export const getMyAvailability = async (userId) => {
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق لعرض دوامك");
  }

  return await prisma.availability.findMany({ where: { staffId: staff.id } });
};