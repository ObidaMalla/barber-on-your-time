import express from "express";
import {
  addService,
  listServices,
  editService,
  removeService,
  listServicesByBusiness,
} from "../controllers/serviceController.js";
import { protect } from "../middlewares/authMiddleware.js";
import bookingRoutes from "./bookingRoutes.js";

const router = express.Router();

// 1. مسار عمومي للزبائن: جلب خدمات محل محدد عبر id المحل
router.get("/business/:businessId", protect, listServicesByBusiness);

// 2. مسارات صاحب المحل (تعتمد على حساب الـ Owner الحالي)
router.post("/", protect, addService);
router.get("/", protect, listServices);
router.patch("/:serviceId", protect, editService);
router.delete("/:serviceId", protect, removeService);

// 3. مسارات الحجوزات المرتبطة بالخدمات
router.use("/bookings", bookingRoutes);

export default router;