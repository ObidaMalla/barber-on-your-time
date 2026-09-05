import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

export const registerUser = async (name, email, password) => {
  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) {
    throw new ApiError(409, "هاد الإيميل مسجل مسبقاً");
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: { name, email, password: hashedPassword },
    select: { id: true, name: true, email: true, role: true, createdAt: true },
  });

  return user;
};

export const loginUser = async (email, password) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    throw new ApiError(401, "الإيميل أو الباسورد غلط");
  }

  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    throw new ApiError(401, "الإيميل أو الباسورد غلط");
  }

  const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );

  return {
    token,
    user: { id: user.id, name: user.name, email: user.email, role: user.role },
  };
};

export const logoutUser = async (token, expiresAt) => {
  await prisma.blacklistedToken.create({
    data: { token, expiresAt },
  });
  return { message: "تم تسجيل الخروج بنجاح" };
};
export const updateFcmToken = async (userId, fcmToken) => {
  return prisma.user.update({ where: { id: userId }, data: { fcmToken } });
};