import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import {
  createBusinessForUser,
  getMyBusinessStaff,
  getStaffByBusinessId,
  getAllBusinesses, 
} from "../services/businessService.js";

export const createBusiness = asyncHandler(async (req, res) => {
  const { name, address } = req.body;
  const userId = req.user.id;

  if (!name) {
    throw new ApiError(400, "اسم المحل مطلوب");
  }

  const business = await createBusinessForUser(userId, name, address);
  return successHandler(res, 201, "تم إنشاء المحل بنجاح", business);
});

// جلب موظفي المحل (خاص بصاحب المحل)
export const getStaff = asyncHandler(async (req, res) => {
  const staff = await getMyBusinessStaff(req.user.id);
  return successHandler(res, 200, "قائمة الموظفين في المحل", staff);
});

// جلب موظفي محل معين عبر ID المحل (للزبائن)
export const getStaffByBusiness = asyncHandler(async (req, res) => {
  const { businessId } = req.params;

  if (!businessId || isNaN(Number(businessId))) {
    throw new ApiError(400, "معرّف المحل غير صالح");
  }

  const staff = await getStaffByBusinessId(Number(businessId));
  return successHandler(res, 200, "قائمة موظفين المحل", staff);
});

// جلب قائمة كل المحلات (للزبائن)
export const listAllBusinesses = asyncHandler(async (req, res) => {
  const businesses = await getAllBusinesses();
  return successHandler(res, 200, "قائمة المحلات المتاحة", businesses);
});