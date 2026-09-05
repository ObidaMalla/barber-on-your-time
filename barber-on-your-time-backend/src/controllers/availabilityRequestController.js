import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import {
  requestAvailabilityChange,
  getPendingRequests,
  getMyPendingRequests,
  respondToRequest,
  requestAvailabilityDeletion,
} from "../services/availabilityRequestService.js";

export const createRequest = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { availabilityId, dayOfWeek, startTime, endTime } = req.body;

  if (!availabilityId || dayOfWeek === undefined || !startTime || !endTime) {
    throw new ApiError(400, "availabilityId واليوم ووقت البداية والنهاية مطلوبين");
  }

  const request = await requestAvailabilityChange(
    userId,
    Number(availabilityId),
    dayOfWeek,
    startTime,
    endTime
  );
  return successHandler(res, 201, "تم إرسال طلب التعديل", request);
});

export const listRequests = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const requests = await getPendingRequests(ownerId);
  return successHandler(res, 200, "الطلبات المعلقة", requests);
});

// ===== جديد =====
export const listMyPendingRequests = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const requests = await getMyPendingRequests(userId);
  return successHandler(res, 200, "طلباتي المعلقة", requests);
});

export const answerRequest = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const { requestId } = req.params;
  const { decision } = req.body;

  if (!["APPROVE", "REJECT"].includes(decision)) {
    throw new ApiError(400, "القرار لازم يكون APPROVE أو REJECT");
  }

  const result = await respondToRequest(ownerId, Number(requestId), decision);
  return successHandler(res, 200, "تم تسجيل الرد", result);
});

export const createDeletionRequest = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { availabilityId } = req.body;

  if (!availabilityId) {
    throw new ApiError(400, "availabilityId مطلوب");
  }

  const request = await requestAvailabilityDeletion(userId, Number(availabilityId));
  return successHandler(res, 201, "تم إرسال طلب الحذف", request);
});