import express from "express";
import { getProfile, updateProfile, updatePassword } from "../controllers/userController.js";
import { protect } from "../middlewares/authMiddleware.js";

const router = express.Router();

router.get("/me", protect, getProfile);
router.patch("/me", protect, updateProfile);
router.patch("/me/password", protect, updatePassword);

export default router;