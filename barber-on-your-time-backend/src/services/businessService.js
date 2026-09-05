import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";

export const createBusinessForUser = async (userId, name, address) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (user.role === "STAFF") {
    throw new ApiError(403, "أنت أصلاً موظف بمحل، ما فيك تفتح محل جديد");
  }

  const existingBusiness = await prisma.business.findUnique({
    where: { ownerId: userId },
  });
  if (existingBusiness) {
    throw new ApiError(409, "عندك محل مسجل أصلاً");
  }

  const [business] = await prisma.$transaction([
    prisma.business.create({
      data: { name, address, ownerId: userId },
    }),
    prisma.user.update({
      where: { id: userId },
      data: { role: "OWNER" },
    }),
  ]);

  return business;
};

// جلب موظفي المحل الخاص بصاحب المحل (OWNER)
export const getMyBusinessStaff = async (ownerId) => {
  const business = await prisma.business.findUnique({
    where: { ownerId },
  });

  if (!business) {
    throw new ApiError(404, "لم يتم العثور على محل خاص بك");
  }

  return await prisma.staff.findMany({
    where: {
      businessId: business.id,
    },
    select: {
      id: true,
      active: true,
      createdAt: true,
      user: {
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
        },
      },
    },
  });
};

// جلب حلاقي محل معين برقم المحل (للكاستمر / الزبائن)
export const getStaffByBusinessId = async (businessId) => {
  const business = await prisma.business.findUnique({
    where: { id: Number(businessId) },
  });

  if (!business) {
    throw new ApiError(404, "المحل غير موجود");
  }

  return await prisma.staff.findMany({
    where: {
      businessId: Number(businessId),
      active: true,
    },
    select: {
      id: true,
      active: true,
      createdAt: true,
      user: {
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
        },
      },
    },
  });
};


// جلب جميع المحلات المتاحة للزبائن
export const getAllBusinesses = async () => {
  return await prisma.business.findMany({
    select: {
      id: true,
      name: true,
      address: true,
      createdAt: true,
      owner: {
        select: {
          id: true,
          name: true,
          email: true,
        },
      },
    },
  });
};