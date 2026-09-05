import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { createStaffInvite, joinBusinessWithCode } from "../services/staffInviteService.js";


export const generateInvite = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const invite = await createStaffInvite(ownerId);
  return successHandler(res, 201, "تم توليد الكود بنجاح", { code: invite.code });
});

export const joinBusiness = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { code } = req.body;

  if (!code) {
    throw new ApiError(400, "الكود مطلوب");
  }

  const staff = await joinBusinessWithCode(userId, code);
  return successHandler(res, 200, "تم الانضمام للمحل بنجاح", staff);
});

import { removeStaff } from "../services/staffInviteService.js";

export const fireStaff = asyncHandler(async (req, res) => {
  const ownerId = req.user.id;
  const { staffId } = req.params;

  await removeStaff(ownerId, Number(staffId));
  return successHandler(res, 200, "تم طرد الموظف بنجاح", null);
});