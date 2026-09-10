import express from "express";
import {
  requestBooking,
  respondBooking,
  listMyBookings,
  cancelMyBooking,
  listStaffBookings,
  requestCompletion,   // 👈 جديد
  confirmCompletion,   // 👈 جديد
  getStaffStats,
  getStaffStatsByOwner // 👈 جديد

} from "../controllers/bookingController.js";
import { protect } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.post("/", protect, requestBooking);
router.get("/my", protect, listMyBookings);
router.patch("/:bookingId/status", protect, respondBooking);
router.delete("/:bookingId", protect, cancelMyBooking);
router.get("/staff", protect, listStaffBookings);


router.post("/:bookingId/request-completion", protect, requestCompletion); // الزبون
router.post("/:bookingId/complete", protect, confirmCompletion);           // الحلاق


router.get("/my-stats", protect, getStaffStats);                    // موجود أصلاً
router.get("/staff/:staffId/stats", protect, getStaffStatsByOwner); // 👈 جديد
export default router;