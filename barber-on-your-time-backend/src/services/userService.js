import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";
import bcrypt from "bcrypt";

export const getMyProfile = async (userId) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, name: true, email: true, role: true, createdAt: true },
  });
  return user;
};

export const updateMyProfile = async (userId, name, email) => {
  if (email) {
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser && existingUser.id !== userId) {
      throw new ApiError(409, "هاد الإيميل مستخدم من مستخدم تاني");
    }
  }

  return await prisma.user.update({
    where: { id: userId },
    data: { name, email },
    select: { id: true, name: true, email: true, role: true },
  });
};

export const changeMyPassword = async (userId, oldPassword, newPassword) => {
  const user = await prisma.user.findUnique({ where: { id: userId } });

  const isOldPasswordValid = await bcrypt.compare(oldPassword, user.password);
  if (!isOldPasswordValid) {
    throw new ApiError(401, "الباسورد القديم غلط");
  }

  const hashedNewPassword = await bcrypt.hash(newPassword, 10);

  await prisma.user.update({
    where: { id: userId },
    data: { password: hashedNewPassword },
  });

  return { message: "تم تغيير الباسورد بنجاح" };
};