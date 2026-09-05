import express from "express";
import {
  createBusiness,
  getStaff,
  getStaffByBusiness,
  listAllBusinesses,
} from "../controllers/businessController.js";
import {
  generateInvite,
  joinBusiness,
  fireStaff,
} from "../controllers/staffInviteController.js";
import { protect } from "../middlewares/authMiddleware.js";

const router = express.Router();

// 🟢 1. مسار جلب جميع المحلات للزبائن (يجب أن يكون في البداية)
router.get("/", protect, listAllBusinesses);

// 🟢 2. مسار جلب موظفي محلي (خاص بصاحب المحل)
router.get("/staff", protect, getStaff);

// 🟢 3. مسارات العمليات على المحل والدعوات
router.post("/", protect, createBusiness);
router.post("/staff-invites", protect, generateInvite);
router.post("/join", protect, joinBusiness);
router.delete("/staff/:staffId", protect, fireStaff);

// 🟢 4. مسار جلب موظفي محل معين للزبائن (يُفضل وضعه في النهاية)
router.get("/:businessId/staff", protect, getStaffByBusiness);

export default router;