import jwt from "jsonwebtoken";
import { ApiError } from "../utils/ApiError.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { prisma } from "../config/prisma.js";
export const protect = asyncHandler(async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new ApiError(401, "لازم تسجل دخول أول");
  }

  const token = authHeader.split(" ")[1];

  const blacklisted = await prisma.blacklistedToken.findUnique({ where: { token } });
  if (blacklisted) {
    throw new ApiError(401, "جلسة الدخول منتهية، سجل دخول من جديد");
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.userId, role: decoded.role };
    next();
  } catch (error) {
    throw new ApiError(401, "جلسة الدخول منتهية أو غير صالحة");
  }
});