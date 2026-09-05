import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { addAvailability, getMyAvailability } from "../services/availabilityService.js";

export const setAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { dayOfWeek, startTime, endTime } = req.body;

  /*لاحظ هون مش !dayOfWeek - ليش؟ لأنه لو الحلاق بيحدد "يوم الأحد" (dayOfWeek = 0)، والقيمة 0 بالجافاسكريبت بتتحسب "falsy" (يعني !0 بيرجع true)! لو استخدمنا !dayOfWeek، رح يرفض يوم الأحد بالغلط. undefined أدق هون */
  if (dayOfWeek === undefined || !startTime || !endTime) {
    throw new ApiError(400, "اليوم ووقت البداية والنهاية مطلوبين");
  }

  const availability = await addAvailability(userId, dayOfWeek, startTime, endTime);
  return successHandler(res, 201, "تم تحديد الدوام بنجاح", availability);
});

export const listMyAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const availability = await getMyAvailability(userId);
  return successHandler(res, 200, "أوقات دوامك", availability);
});