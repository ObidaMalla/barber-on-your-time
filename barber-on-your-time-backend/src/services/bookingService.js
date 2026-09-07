import { prisma } from "../config/prisma.js";
import { ApiError } from "../utils/ApiError.js";
import { createNotification } from "./notificationsService.js";

const BUSINESS_TIMEZONE = "Asia/Damascus";
const BUFFER_MINUTES = 5;
const SLOT_STEP_MINUTES = 15;

// 👈 جديد: توليد كود تأكيد عشوائي من 6 أرقام (كنص، مش رقم — عشان ما نضيع الأصفار بالبداية)
const generateCompletionCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// ===== أدوات مساعدة عامة =====

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

// بيحول أي تاريخ (Date أو ISO string) لتاريخ ووقت بتوقيت سوريا/الأردن، بغض النظر عن تايم زون السيرفر
const extractDateTimeParts = (dateInput) => {
  const date = dateInput instanceof Date ? dateInput : parseAndValidateDate(dateInput);

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

// تاريخ الـ Availability (مخزّن كـ DATE بقاعدة البيانات) → نص YYYY-MM-DD ثابت (UTC، بدون انزياح)
const availabilityDateToStr = (d) => {
  const dt = new Date(d);
  return `${dt.getUTCFullYear()}-${String(dt.getUTCMonth() + 1).padStart(2, "0")}-${String(dt.getUTCDate()).padStart(2, "0")}`;
};

const timeToMinutes = (hhmm) => {
  const [h, m] = hhmm.split(":").map(Number);
  return h * 60 + m;
};

const minutesToTime = (mins) => {
  const h = Math.floor(mins / 60).toString().padStart(2, "0");
  const m = (mins % 60).toString().padStart(2, "0");
  return `${h}:${m}`;
};

const getDayBoundsUTC = (dateStr) => {
  const start = new Date(`${dateStr}T00:00:00+03:00`);
  const end = new Date(`${dateStr}T23:59:59.999+03:00`);
  return { start, end };
};

// فترات انشغال الحلاق (بالدقائق) بيوم معين، بأخذ مدة الخدمة + الاستراحة بعين الاعتبار
const getBusyIntervals = async (staffId, dateStr) => {
  const { start, end } = getDayBoundsUTC(dateStr);

  const bookings = await prisma.booking.findMany({
    where: {
      staffId,
      status: { in: ["PENDING", "CONFIRMED", "NEEDS_OWNER"] },
      startTime: { gte: start, lte: end },
    },
    include: { service: { select: { durationMinutes: true } } },
  });

  return bookings.map((b) => {
    const { hhmm } = extractDateTimeParts(b.startTime);
    const startMin = timeToMinutes(hhmm);
    const endMin = startMin + b.service.durationMinutes + BUFFER_MINUTES;
    return { startMin, endMin };
  });
};

const checkStaffAvailability = async (staffId, requestedStart, requestedDurationMinutes, dateParts) => {
  const { dateStr, hhmm } = dateParts;

  const availabilitySlots = await prisma.availability.findMany({ where: { staffId } });

  const hasScheduleForThisTime = availabilitySlots.some(
    (slot) =>
      availabilityDateToStr(slot.date) === dateStr &&
      slot.startTime <= hhmm &&
      slot.endTime > hhmm
  );

  if (!hasScheduleForThisTime) return false;

  const requestedEnd = new Date(
    requestedStart.getTime() + (requestedDurationMinutes + BUFFER_MINUTES) * 60000
  );

  const activeBookings = await prisma.booking.findMany({
    where: { staffId, status: { in: ["PENDING", "CONFIRMED", "NEEDS_OWNER"] } },
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

// ===== 1. إنشاء حجز =====

export const createBooking = async (customerId, serviceId, staffId, startTime) => {
  const parsedStartTime = parseAndValidateDate(startTime);
  const dateParts = extractDateTimeParts(parsedStartTime);

  const service = await prisma.service.findUnique({ where: { id: serviceId } });
  if (!service) throw new ApiError(404, "الخدمة مش موجودة");

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

  const isAvailable = await checkStaffAvailability(staffId, parsedStartTime, service.durationMinutes, dateParts);
  if (!isAvailable) {
    throw new ApiError(409, "هاد الوقت غير متاح عند هاد الحلاق او لا يمتلك الدوام بهذا اليوم، جرب وقت تاني");
  }

  const booking = await prisma.booking.create({
    data: { customerId, serviceId, staffId, startTime: parsedStartTime, status: "PENDING" },
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

// ===== 2. البحث عن حلاق بديل عند الرفض =====

export const findAvailableStaff = async (businessId, serviceId, excludedStaffIds, startTime) => {
  const requestedDate = parseAndValidateDate(startTime);
  const dateParts = extractDateTimeParts(requestedDate);
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


export const respondToBooking = async (staffUserId, bookingId, decision) => {
  const staff = await prisma.staff.findUnique({
    where: { userId: staffUserId },
    include: { user: true },
  });
  if (!staff) throw new ApiError(403, "لازم تكون حلاق للرد على الحجز");

  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: { customer: true, service: true },
  });
  if (!booking) throw new ApiError(404, "الحجز مش موجود");
  if (booking.staffId !== staff.id) throw new ApiError(403, "هاد الحجز مش موجه إلك");

  const currentAttempt = await prisma.bookingAttempt.findFirst({
    where: { bookingId: booking.id, staffId: staff.id, status: "PENDING" },
  });
  if (!currentAttempt) throw new ApiError(409, "هاد الحجز مش بانتظار ردك حالياً");

  // ==================== 1. في حال القبول ====================
   if (decision === "ACCEPT") {
    await prisma.bookingAttempt.update({
      where: { id: currentAttempt.id },
      data: { status: "ACCEPTED", respondedAt: new Date() },
    });

    const completionCode = generateCompletionCode(); // 👈 جديد

    const confirmedBooking = await prisma.booking.update({
      where: { id: booking.id },
      data: { status: "CONFIRMED", completionCode }, // 👈 جديد: نخزن الكود على الحجز
    });

    // 🔔 إشعار للزبون بتم تأكيد الحجز
    await createNotification({
      userId: booking.customerId,
      type: "BOOKING_STATUS_UPDATE",
      title: "تم تأكيد حجزك ✅",
      message: `قبل الحلاق "${staff.user.name}" حجزك لخدمة "${booking.service.name}"`,
      data: { bookingId: confirmedBooking.id },
    });

    // 🔔 جديد: إشعار منفصل فيه كود التأكيد — منفصل عشان يكون واضح ومميز، مش مدفون بنص رسالة تانية
    await createNotification({
      userId: booking.customerId,
      type: "BOOKING_CODE",
      title: "كود تأكيد الخدمة 🔑",
      message: `احتفظ بهاد الكود وأعطيه للحلاق بعد ما توخد خدمتك: ${completionCode}`,
      data: { bookingId: confirmedBooking.id, completionCode },
    });

    return confirmedBooking;
  }

  // ==================== 2. في حال الرفض ====================
  await prisma.bookingAttempt.update({
    where: { id: currentAttempt.id },
    data: { status: "REJECTED", respondedAt: new Date() },
  });

  // 🔔 إشعار للزبون بالرفض (تم التغيير إلى BOOKING_STATUS_UPDATE)
  await createNotification({
    userId: booking.customerId,
    type: "BOOKING_STATUS_UPDATE",
    title: "تحديث بخصوص حجزك ⚠️",
    message: `اعتذر الحلاق "${staff.user.name}" عن استقبال حجزك، جاري البحث عن بديل...`,
    data: { bookingId: booking.id },
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

  // إذا ما في حلاق بديل -> تحويل لصاحب المحل
  if (!nextStaff) {
    const updatedBooking = await prisma.booking.update({
      where: { id: booking.id },
      data: { status: "NEEDS_OWNER" },
    });
    const business = await prisma.business.findUnique({
      where: { id: staff.businessId },
    });

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
      title: "تحديث بخصوص حجزك 🔔",
      message: `لم نجد حلاق بديل متاح حالياً، تم تحويل طلبك لصاحب المحل مباشرة للاعتماد.`,
      data: { bookingId: updatedBooking.id },
    });

    return updatedBooking;
  }

  // في حال وجود حلاق بديل -> تحويل الحجز له
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

  const nextStaffUser = await prisma.user.findUnique({
    where: { id: nextStaff.userId },
  });
  const business = await prisma.business.findUnique({
    where: { id: staff.businessId },
  });

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
    title: "تحديث بخصوص حجزك 🔄",
    message: `تم تحويل طلب حجزك إلى الحلاق "${nextStaffUser.name}" وبانتظار موافقته. يمكنك إلغاء الحجز إذا لا تريد هذا الحلاق`,
    data: { bookingId: updatedBooking.id },
  });

  return updatedBooking;
};
// ===== 4. إلغاء حجز =====

export const cancelBooking = async (customerId, bookingId) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: { staff: true, customer: { select: { name: true } } },
  });
  if (!booking) throw new ApiError(404, "الحجز مش موجود");
  if (booking.customerId !== customerId) throw new ApiError(403, "هاد الحجز مش إلك");
  if (booking.status === "CANCELLED") throw new ApiError(409, "الحجز أصلاً ملغي");

  const updated = await prisma.booking.update({ where: { id: bookingId }, data: { status: "CANCELLED" } });

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

// ===== 5. عرض الحجوزات =====

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
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) throw new ApiError(403, "حسابك غير مسجل كحلاق في النظام");

  return await prisma.booking.findMany({
    where: { staffId: staff.id },
    include: { customer: { select: { id: true, name: true, email: true } }, service: true },
    orderBy: { startTime: "asc" },
  });
};

// ===== 6. الأوقات الفاضية (للزبون + للحلاق) =====


// ===== فراغات حلاق معيّن (staffId مباشر) — الدالة الأساسية المشتركة =====
const getFreeWindowsByStaffId = async (staffId) => {
  const staff = await prisma.staff.findUnique({ where: { id: staffId } });
  if (!staff) throw new ApiError(404, "الحلاق مش موجود");

  const allAvailability = await prisma.availability.findMany({
    where: { staffId },
    orderBy: { date: "asc" },
  });

  const results = [];

  for (const dayAvailability of allAvailability) {
    const dateStr = availabilityDateToStr(dayAvailability.date);
    const busyIntervals = (await getBusyIntervals(staffId, dateStr)).sort((a, b) => a.startMin - b.startMin);

    const workStart = timeToMinutes(dayAvailability.startTime);
    const workEnd = timeToMinutes(dayAvailability.endTime);

    const freeWindows = [];
    let cursor = workStart;

    for (const busy of busyIntervals) {
      const busyStart = Math.max(busy.startMin, workStart);
      const busyEnd = Math.min(busy.endMin, workEnd);
      if (busyStart > cursor) freeWindows.push({ from: minutesToTime(cursor), to: minutesToTime(busyStart) });
      cursor = Math.max(cursor, busyEnd);
    }
    if (cursor < workEnd) freeWindows.push({ from: minutesToTime(cursor), to: minutesToTime(workEnd) });

    results.push({
      date: dateStr,
      workingHours: { startTime: dayAvailability.startTime, endTime: dayAvailability.endTime },
      freeWindows,
    });
  }

  return results;
};

// للحلاق: فراغاته هو، بتوكن نفسه (userId → staff)
export const getMyFreeWindowsAll = async (userId) => {
  const staff = await prisma.staff.findUnique({ where: { userId } });
  if (!staff) throw new ApiError(403, "لازم تكون حلاق");
  return await getFreeWindowsByStaffId(staff.id);
};

// للزبون: فراغات حلاق محدد، بتوكن الزبون
export const getStaffFreeWindowsAll = async (staffId) => {
  return await getFreeWindowsByStaffId(staffId);
};