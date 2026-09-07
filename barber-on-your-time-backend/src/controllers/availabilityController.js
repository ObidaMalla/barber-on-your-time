import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { addAvailability, getMyAvailability } from "../services/availabilityService.js";
import { getMyFreeWindowsAll, getStaffFreeWindowsAll } from "../services/bookingService.js";

export const setAvailability = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { date, startTime, endTime } = req.body;

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

// 👈 للحلاق: فراغاته هو (بتوكن نفسه)
export const getMyFreeSlotsAll = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const result = await getMyFreeWindowsAll(userId);
  return successHandler(res, 200, "أوقات فراغك", result);
});

// 👈 للزبون: فراغات حلاق محدد (بتوكن الزبون)
export const getStaffFreeSlotsAll = asyncHandler(async (req, res) => {
  const { staffId } = req.params;
  const result = await getStaffFreeWindowsAll(Number(staffId));
  return successHandler(res, 200, "أوقات فراغ الحلاق", result);
});