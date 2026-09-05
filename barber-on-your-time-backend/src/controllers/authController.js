import jwt from "jsonwebtoken";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { registerUser, loginUser, logoutUser } from "../services/authService.js";
import { createNotification } from "../services/notificationsService.js";
import { updateFcmToken } from "../services/authService.js"; // 👈 جديد


export const register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    throw new ApiError(400, "الاسم والإيميل والباسورد مطلوبين");
  }

  const user = await registerUser(name, email, password);
  return successHandler(res, 201, "تم إنشاء الحساب بنجاح", user);
});


export const login = asyncHandler(async (req, res) => {
  const { email, password, fcmToken } = req.body; // 👈 fcmToken جديد

  if (!email || !password) {
    throw new ApiError(400, "الإيميل والباسورد مطلوبين");
  }

  const result = await loginUser(email, password);

  if (fcmToken) {
    await updateFcmToken(result.user.id, fcmToken); // 👈 جديد
  }

  await createNotification({
    userId: result.user.id,
    type: "WELCOME",
    title: "أهلاً وسهلاً 👋",
    message: `مرحباً بك يا ${result.user.name}!`,
    data: {},
  });

  return successHandler(res, 200, "تم تسجيل الدخول بنجاح", result);
});

// 👈 إضافة دالة logout المُصدّرة
export const logout = asyncHandler(async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    throw new ApiError(401, "التوكن غير موجود");
  }

  const token = authHeader.split(" ")[1];
  const decoded = jwt.decode(token);
  const expiresAt = new Date(decoded.exp * 1000);

  const result = await logoutUser(token, expiresAt);
  return successHandler(res, 200, result.message || "تم تسجيل الخروج بنجاح", null);
});