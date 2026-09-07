/*import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import { createBooking, respondToBooking } from "../services/bookingService.js";


export const requestBooking = asyncHandler(async (req, res) => {
  const customerId = req.user.id;
  const { serviceId, staffId, startTime } = req.body;

  if (!serviceId || !staffId || !startTime) {
    throw new ApiError(400, "الخدمة والحلاق والوقت مطلوبين");
  }

  const booking = await createBooking(customerId, serviceId, staffId, startTime);
  return successHandler(res, 201, "تم إرسال طلب الحجز", booking);
});

export const respondBooking = asyncHandler(async (req, res) => {
  const staffUserId = req.user.id;
  const { bookingId } = req.params;
  const { decision } = req.body;

  if (!["ACCEPT", "REJECT"].includes(decision)) {
    throw new ApiError(400, "القرار لازم يكون ACCEPT أو REJECT");
  }

  const booking = await respondToBooking(staffUserId, Number(bookingId), decision);
  return successHandler(res, 200, "تم تسجيل ردك بنجاح", booking);
});


import { cancelBooking, getMyBookings } from "../services/bookingService.js";

export const cancelMyBooking = asyncHandler(async (req, res) => {
  const customerId = req.user.id;
  const { bookingId } = req.params;

  const booking = await cancelBooking(customerId, Number(bookingId));
  return successHandler(res, 200, "تم إلغاء الحجز", booking);
});

export const listMyBookings = asyncHandler(async (req, res) => {
  const customerId = req.user.id;
  const bookings = await getMyBookings(customerId);
  return successHandler(res, 200, "حجوزاتي", bookings);
});




// جلب الحجوزات الخاصة بالحلاق
export const listStaffBookings = async (req, res, next) => {
  try {
    const userId = req.user.id;

    // 1. التاكد من وجود حساب الموظف/الحلاق
    const staff = await prisma.staffMember.findUnique({
      where: { userId },
    });

    if (!staff) {
      return res.status(403).json({
        success: false,
        message: "حسابك غير مسجل كحلاق في النظام",
      });
    }

    // 2. جلب الحجوزات الخاصة به
    const bookings = await prisma.booking.findMany({
      where: { staffId: staff.id },
      include: {
        customer: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        service: true,
      },
      orderBy: { startTime: "asc" },
    });

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};*/

import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { successHandler } from "../handlers/successHandler.js";
import {
  createBooking,
  respondToBooking,
  cancelBooking,
  getMyBookings,
  getStaffBookings,
  getAvailableSlots,
  getAvailableSlotsAll, // 👈 جديد
} from "../services/bookingService.js";
export const requestBooking = asyncHandler(async (req, res) => {
  const customerId = req.user.id;
  const { serviceId, staffId, startTime } = req.body;

  if (!serviceId || !staffId || !startTime) {
    throw new ApiError(400, "الخدمة والحلاق والوقت مطلوبين");
  }

  const booking = await createBooking(customerId, serviceId, staffId, startTime);
  return successHandler(res, 201, "تم إرسال طلب الحجز", booking);
});

export const respondBooking = asyncHandler(async (req, res) => {
  const staffUserId = req.user.id;
  const { bookingId } = req.params;
  const { decision } = req.body;

  if (!["ACCEPT", "REJECT"].includes(decision)) {
    throw new ApiError(400, "القرار لازم يكون ACCEPT أو REJECT");
  }

  const booking = await respondToBooking(staffUserId, Number(bookingId), decision);
  return successHandler(res, 200, "تم تسجيل ردك بنجاح", booking);
});

export const cancelMyBooking = asyncHandler(async (req, res) => {
  const customerId = req.user.id;
  const { bookingId } = req.params;

  const cancelledBooking = await cancelBooking(customerId, Number(bookingId));
  return successHandler(res, 200, "تم إلغاء الحجز بنجاح", cancelledBooking);
});

export const listMyBookings = asyncHandler(async (req, res) => {
  const customerId = req.user.id;
  const bookings = await getMyBookings(customerId);
  return successHandler(res, 200, "حجوزاتي", bookings);
});

export const listStaffBookings = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const bookings = await getStaffBookings(userId);
  return successHandler(res, 200, "حجوزات الحلاق", bookings);
});
export const getStaffAvailableSlots = asyncHandler(async (req, res) => {
  const { staffId, date } = req.params;
  const { serviceId } = req.query;

  if (!serviceId) {
    throw new ApiError(400, "serviceId مطلوب");
  }

  const slots = await getAvailableSlots(Number(staffId), date, Number(serviceId));
  return successHandler(res, 200, "الأوقات المتاحة", slots);
});

export const getStaffAvailableSlotsAll = asyncHandler(async (req, res) => {
  const { staffId } = req.params;
  const { serviceId } = req.query;

  if (!serviceId) {
    throw new ApiError(400, "serviceId مطلوب");
  }

  const result = await getAvailableSlotsAll(Number(staffId), Number(serviceId));
  return successHandler(res, 200, "الأوقات المتاحة", result);
});