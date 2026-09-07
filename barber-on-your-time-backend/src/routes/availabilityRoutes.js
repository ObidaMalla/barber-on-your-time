import express from "express";
import {
  setAvailability,
  listMyAvailability,
  getMyFreeSlotsAll,
  getStaffFreeSlotsAll,
} from "../controllers/availabilityController.js";
import { protect } from "../middlewares/authMiddleware.js";
import {
  createRequest,
  listRequests,
  listMyPendingRequests,
  answerRequest,
  createDeletionRequest,
} from "../controllers/availabilityRequestController.js";

const router = express.Router();

router.post("/", protect, setAvailability);
router.get("/", protect, listMyAvailability);

router.get("/me/free-slots", protect, getMyFreeSlotsAll);           // 👈 الحلاق عن حاله
router.get("/staff/:staffId/free-slots", protect, getStaffFreeSlotsAll); // 👈 الزبون عن حلاق محدد

router.post("/requests", protect, createRequest);
router.get("/requests", protect, listRequests);
router.get("/requests/mine", protect, listMyPendingRequests);
router.patch("/requests/:requestId", protect, answerRequest);
router.post("/requests/delete", protect, createDeletionRequest);

export default router;