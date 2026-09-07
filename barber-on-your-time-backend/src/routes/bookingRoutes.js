import express from "express";
import {
  requestBooking,
  respondBooking,
  listMyBookings,
  cancelMyBooking,
  listStaffBookings,
} from "../controllers/bookingController.js";
import { protect } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.post("/", protect, requestBooking);
router.get("/my", protect, listMyBookings);
router.patch("/:bookingId/status", protect, respondBooking);
router.delete("/:bookingId", protect, cancelMyBooking);
router.get("/staff", protect, listStaffBookings);

export default router;