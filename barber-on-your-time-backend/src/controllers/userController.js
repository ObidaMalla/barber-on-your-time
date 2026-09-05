import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { getMyProfile, updateMyProfile, changeMyPassword } from "../services/userService.js";

export const getProfile = asyncHandler(async (req, res) => {
  const profile = await getMyProfile(req.user.id);
  return successHandler(res, 200, "بياناتك", profile);
});

export const updateProfile = asyncHandler(async (req, res) => {
  const { name, email } = req.body;

  if (!name && !email) {
    throw new ApiError(400, "لازم تبعت اسم أو إيميل على الأقل");
  }

  const updated = await updateMyProfile(req.user.id, name, email);
  return successHandler(res, 200, "تم تحديث بياناتك", updated);
});

export const updatePassword = asyncHandler(async (req, res) => {
  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword) {
    throw new ApiError(400, "الباسورد القديم والجديد مطلوبين");
  }

  const result = await changeMyPassword(req.user.id, oldPassword, newPassword);
  return successHandler(res, 200, result.message, null);
});