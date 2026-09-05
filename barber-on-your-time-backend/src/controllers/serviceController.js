import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { createService, getBusinessServices,getServicesByBusinessId, } from "../services/serviceService.js";

export const addService = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const { name, durationMinutes, price } = req.body;

  if (!name || !durationMinutes || !price) {
    throw new ApiError(400, "الاسم والمدة والسعر مطلوبين");
  }

  const service = await createService(ownerId, name, durationMinutes, price);
  return successHandler(res, 201, "تم إضافة الخدمة بنجاح", service);
});

export const listServices = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const services = await getBusinessServices(ownerId);
  return successHandler(res, 200, "قائمة الخدمات", services);
});

import { updateService, deleteService } from "../services/serviceService.js";

export const editService = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const { serviceId } = req.params;
  const { name, durationMinutes, price } = req.body;

  const service = await updateService(ownerId, Number(serviceId), name, durationMinutes, price);
  return successHandler(res, 200, "تم تحديث الخدمة", service);
});

export const removeService = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const { serviceId } = req.params;

  const result = await deleteService(ownerId, Number(serviceId));
  return successHandler(res, 200, result.message, null);
});
export const getMyRequest = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const request = await getMyPendingRequest(userId);
  return successHandler(
    res,
    200,
    request ? "طلبك المعلق" : "ما عندك طلب معلق حالياً",
    request
  );
});


export const listServicesByBusiness = asyncHandler(async (req, res) => {
  const { businessId } = req.params;

  if (!businessId || isNaN(Number(businessId))) {
    throw new ApiError(400, "معرّف المحل غير صالح");
  }

  const services = await getServicesByBusinessId(Number(businessId));
  return successHandler(res, 200, "قائمة خدمات المحل", services);
});