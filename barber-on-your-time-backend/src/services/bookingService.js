import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";
import { createNotification } from "./notificationsService.js";


const BUSINESS_TIMEZONE = "Asia/Damascus"; // 👈 سوريا (UTC+3)
// دالة لتأمين تحويل التاريخ (للتخزين بقاعدة البيانات فقط)
const parseAndValidateDate = (dateString) => {
  if (!dateString) {
    throw new ApiError(400, "تاريخ الحجز مطلوب");
  }
  const formattedString =
    typeof dateString === "string"
      ? dateString.trim().replace(/T(\d):/, "T0$1:")
      : dateString;

  const parsedDate = new Date(formattedString);
  if (isNaN(parsedDate.getTime())) {
    throw new ApiError(
      400,
      "صيغة التاريخ غير صالحة، يرجى إرسال ISO string مثل 2026-08-31T06:00:00.000Z"
    );
  }
  return parsedDate;
};


// 👈 معدّل بالكامل: بيحول الوقت المستلم (UTC) لتوقيت العمل المحلي دايماً
const extractDateTimeParts = (dateString) => {
  const formattedString =
    typeof dateString === "string"
      ? dateString.trim().replace(/T(\d):/, "T0$1:")
      : dateString;

  const date = new Date(formattedString);
  if (isNaN(date.getTime())) {
    throw new ApiError(400, "صيغة التاريخ غير صالحة");
  }

  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone: BUSINESS_TIMEZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    weekday: "short",
  });

  const parts = formatter.formatToParts(date);
  const map = {};
  for (const p of parts) map[p.type] = p.value;

  const dateStr = `${map.year}-${map.month}-${map.day}`;
  const hhmm = `${map.hour === "24" ? "00" : map.hour}:${map.minute}`;
  const weekdayMap = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
  const dayOfWeek = weekdayMap[map.weekday];

  return { dateStr, hhmm, dayOfWeek };
};
// 👈 جديد: تحويل تاريخ الـ Availability (المخزن كـ DATE بقاعدة البيانات) لنص YYYY-MM-DD بشكل ثابت (UTC)
const availabilityDateToStr = (d) => {
  const dt = new Date(d);
  return `${dt.getUTCFullYear()}-${String(dt.getUTCMonth() + 1).padStart(2, "0")}-${String(dt.getUTCDate()).padStart(2, "0")}`;
};

const BUFFER_MINUTES = 5;

const checkStaffAvailability = async (staffId, requestedStart, requestedDurationMinutes, dateParts) => {
  const { dateStr, hhmm } = dateParts;

  const availabilitySlots = await prisma.availability.findMany({
    where: { staffId },
  });

  const hasScheduleForThisTime = availabilitySlots.some(
    (slot) =>
      availabilityDateToStr(slot.date) === dateStr && // 👈 مطابقة على نفس التاريخ بالضبط
      slot.startTime <= hhmm &&
      slot.endTime > hhmm
  );

  if (!hasScheduleForThisTime) {
    return false;
  }

  const requestedEnd = new Date(
    requestedStart.getTime() + (requestedDurationMinutes + BUFFER_MINUTES) * 60000
  );

  const activeBookings = await prisma.booking.findMany({
    where: {
      staffId,
      status: { in: ["PENDING", "CONFIRMED", "NEEDS_OWNER"] },
    },
    include: { service: { select: { durationMinutes: true } } },
  });

  for (const existing of activeBookings) {
    const existingStart = existing.startTime;
    const existingEnd = new Date(
      existingStart.getTime() + (existing.service.durationMinutes + BUFFER_MINUTES) * 60000
    );
    const overlaps = requestedStart < existingEnd && existingStart < requestedEnd;
    if (overlaps) return false;
  }

  return true;
};

export const createBooking = async (customerId, serviceId, staffId, startTime) => {
  const parsedStartTime = parseAndValidateDate(startTime);
  const dateParts = extractDateTimeParts(startTime); // 👈 جديد

  const service = await prisma.service.findUnique({ where: { id: serviceId } });
  if (!service) {
    throw new ApiError(404, "الخدمة مش موجودة");
  }

  const staff = await prisma.staff.findUnique({ where: { id: staffId } });
  if (!staff || staff.businessId !== service.businessId) {
    throw new ApiError(400, "هاد الحلاق ما بيقدم هاي الخدمة");
  }

  const existingBooking = await prisma.booking.findFirst({
    where: {
      customerId,
      staffId,
      startTime: parsedStartTime,
      status: { in: ["PENDING", "NEEDS_OWNER"] },
    },
  });
  if (existingBooking) {
    throw new ApiError(409, "عندك طلب حجز معلق أصلاً بنفس الوقت مع هاد الحلاق");
  }

  const isAvailable = await checkStaffAvailability(
    staffId,
    parsedStartTime,
    service.durationMinutes,
    dateParts // 👈 جديد
  );
  if (!isAvailable) {
    throw new ApiError(409, "هاد الوقت غير متاح عند هاد الحلاق او لا يمتلك الدوام بهذا اليوم، جرب وقت تاني");
  }

  const booking = await prisma.booking.create({
    data: {
      customerId,
      serviceId,
      staffId,
      startTime: parsedStartTime,
      status: "PENDING",
    },
    include: {
      staff: { include: { user: { select: { id: true, name: true, email: true, role: true } } } },
      customer: { select: { name: true } },
    },
  });

  await prisma.bookingAttempt.create({
    data: { bookingId: booking.id, staffId, order: 1, status: "PENDING" },
  });

  await createNotification({
    userId: booking.staff.userId,
    type: "BOOKING_CREATED",
    title: "حجز جديد 📅",
    message: `الزبون "${booking.customer.name}" حجز موعد عندك`,
    data: { bookingId: booking.id },
  });

  return booking;
};

export const findAvailableStaff = async (businessId, serviceId, excludedStaffIds, startTime) => {
  const requestedDate = parseAndValidateDate(startTime);
  const isoLike = requestedDate.toISOString(); // للحفاظ على شكل موحّد قبل الاستخراج
  const dateParts = extractDateTimeParts(
    typeof startTime === "string" ? startTime : isoLike
  );
  const { dateStr, hhmm } = dateParts;

  const candidates = await prisma.staff.findMany({
    where: { businessId, id: { notIn: excludedStaffIds }, active: true },
    include: { availability: true },
  });

  for (const staff of candidates) {
    const isAvailableToday = staff.availability.some(
      (a) => availabilityDateToStr(a.date) === dateStr && a.startTime <= hhmm && a.endTime > hhmm
    );
    if (!isAvailableToday) continue;

    const conflict = await prisma.booking.findFirst({
      where: { staffId: staff.id, startTime: requestedDate, status: "CONFIRMED" },
    });
    if (conflict) continue;

    return staff;
  }

  return null;
};

// ===== باقي الملف بدون أي تغيير =====

export const respondToBooking = async (staffUserId, bookingId, decision) => {
  const staff = await prisma.staff.findUnique({
    where: { userId: staffUserId },
    include: { user: true },
  });
  if (!staff) {
    throw new ApiError(403, "لازم تكون حلاق للرد على الحجز");
  }

  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: { customer: true },
  });
  if (!booking) {
    throw new ApiError(404, "الحجز مش موجود");
  }

  if (booking.staffId !== staff.id) {
    throw new ApiError(403, "هاد الحجز مش موجه إلك");
  }

  const currentAttempt = await prisma.bookingAttempt.findFirst({
    where: { bookingId: booking.id, staffId: staff.id, status: "PENDING" },
  });
  if (!currentAttempt) {
    throw new ApiError(409, "هاد الحجز مش بانتظار ردك حالياً");
  }

  if (decision === "ACCEPT") {
    await prisma.bookingAttempt.update({
      where: { id: currentAttempt.id },
      data: { status: "ACCEPTED", respondedAt: new Date() },
    });

    return await prisma.booking.update({
      where: { id: booking.id },
      data: { status: "CONFIRMED" },
    });
  }

  await prisma.bookingAttempt.update({
    where: { id: currentAttempt.id },
    data: { status: "REJECTED", respondedAt: new Date() },
  });

  const previousAttempts = await prisma.bookingAttempt.findMany({
    where: { bookingId: booking.id },
    select: { staffId: true },
  });

  const excludedStaffIds = previousAttempts.map((a) => a.staffId);

  const nextStaff = await findAvailableStaff(
    staff.businessId,
    booking.serviceId,
    excludedStaffIds,
    booking.startTime
  );

  if (!nextStaff) {
    const updatedBooking = await prisma.booking.update({
      where: { id: booking.id },
      data: { status: "NEEDS_OWNER" },
    });

    const business = await prisma.business.findUnique({ where: { id: staff.businessId } });

    await createNotification({
      userId: business.ownerId,
      type: "BOOKING_NEEDS_OWNER",
      title: "حجز يحتاج تدخلك ⚠️",
      message: `الحلاق "${staff.user.name}" رفض الحجز ولا يوجد حلاق بديل متاح، يرجى الاهتمام بالطلب`,
      data: { bookingId: updatedBooking.id },
    });

    await createNotification({
      userId: booking.customerId,
      type: "BOOKING_STATUS_UPDATE",
      title: "تحديث بخصوص حجزك",
      message: `الحلاق "${staff.user.name}" غير متوفر حالياً، تم تحويل طلبك لصاحب المحل مباشرة. نحن في الخدمة، يمكنك الانتظار أو إلغاء الحجز`,
      data: { bookingId: updatedBooking.id },
    });

    return updatedBooking;
  }

  await prisma.bookingAttempt.create({
    data: {
      bookingId: booking.id,
      staffId: nextStaff.id,
      order: currentAttempt.order + 1,
      status: "PENDING",
    },
  });

  const updatedBooking = await prisma.booking.update({
    where: { id: booking.id },
    data: { staffId: nextStaff.id },
  });

  const nextStaffUser = await prisma.user.findUnique({ where: { id: nextStaff.userId } });
  const business = await prisma.business.findUnique({ where: { id: staff.businessId } });

  await createNotification({
    userId: nextStaff.userId,
    type: "BOOKING_TRANSFERRED",
    title: "تم تحويل حجز إليك 🔄",
    message: `تم تحويل حجز من الحلاق "${staff.user.name}" إليك`,
    data: { bookingId: updatedBooking.id },
  });

  await createNotification({
    userId: business.ownerId,
    type: "BOOKING_TRANSFERRED",
    title: "تحويل حجز 🔄",
    message: `الحلاق "${staff.user.name}" رفض حجزاً وتم تحويله إلى "${nextStaffUser.name}"`,
    data: { bookingId: updatedBooking.id },
  });

  await createNotification({
    userId: booking.customerId,
    type: "BOOKING_STATUS_UPDATE",
    title: "تحديث بخصوص حجزك",
    message: `الحلاق "${staff.user.name}" غير متوفر حالياً، تم تحويل طلبك للحلاق "${nextStaffUser.name}". نحن في الخدمة، يمكنك الانتظار أو إلغاء الحجز في أي وقت`,
    data: { bookingId: updatedBooking.id },
  });

  return updatedBooking;
};

export const cancelBooking = async (customerId, bookingId) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: {
      staff: true,
      customer: { select: { name: true } },
    },
  });

  if (!booking) {
    throw new ApiError(404, "الحجز مش موجود");
  }

  if (booking.customerId !== customerId) {
    throw new ApiError(403, "هاد الحجز مش إلك");
  }

  if (booking.status === "CANCELLED") {
    throw new ApiError(409, "الحجز أصلاً ملغي");
  }

  const updated = await prisma.booking.update({
    where: { id: bookingId },
    data: { status: "CANCELLED" },
  });

  if (booking.staff) {
    await createNotification({
      userId: booking.staff.userId,
      type: "BOOKING_CANCELLED",
      title: "تم إلغاء حجز ❌",
      message: `الزبون "${booking.customer.name}" ألغى حجزو معك`,
      data: { bookingId: updated.id },
    });
  }

  return updated;
};

export const getMyBookings = async (customerId) => {
  return await prisma.booking.findMany({
    where: { customerId },
    include: {
      service: { select: { name: true, price: true, durationMinutes: true } },
      staff: { select: { id: true, user: { select: { name: true } } } },
    },
    orderBy: { startTime: "desc" },
  });
};

export const getStaffBookings = async (userId) => {
  const staff = await prisma.staff.findUnique({
    where: { userId },
  });

  if (!staff) {
    throw new ApiError(403, "حسابك غير مسجل كحلاق في النظام");
  }

  return await prisma.booking.findMany({
    where: { staffId: staff.id },
    include: {
      customer: {
        select: { id: true, name: true, email: true },
      },
      service: true,
    },
    orderBy: { startTime: "asc" },
  });
};