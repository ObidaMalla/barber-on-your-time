import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { addAvailability, getMyAvailability } from "../services/availabilityService.js";

export const setAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { date, startTime, endTime } = req.body; // 👈 date بدل dayOfWeek

  if (!date || !startTime || !endTime) {
    throw new ApiError(400, "التاريخ ووقت البداية والنهاية مطلوبين");
  }

  const availability = await addAvailability(userId, date, startTime, endTime);
  return successHandler(res, 201, "تم تحديد الدوام بنجاح", availability);
});

export const listMyAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const availability = await getMyAvailability(userId);
  return successHandler(res, 200, "أوقات دوامك", availability);
});