import { prisma } from "../config/prisma.js"; // 👈 عدّل المسار إذا مختلف عندك
import { ApiError } from "../utils/ApiError.js";
import messaging from "../config/firebase.js"; // 👈 بدل admin

export const createNotification = async ({ userId, type, title, message, data }) => {
  const notification = await prisma.notification.create({
    data: { userId, type, title, message, data },
  });

  const user = await prisma.user.findUnique({ where: { id: userId }, select: { fcmToken: true } });

  if (user?.fcmToken) {
    await sendPushNotification(userId, user.fcmToken, title, message, data);
  }

  return notification;
};

const sendPushNotification = async (userId, fcmToken, title, body, data = {}) => {
  try {
  await messaging.send({
  token: fcmToken,
  notification: { title, body },
  data: Object.fromEntries(Object.entries(data || {}).map(([k, v]) => [k, String(v)])),
});
  } catch (err) {
    console.error("فشل إرسال Push:", err.message);
    if (
      err.code === "messaging/invalid-registration-token" ||
      err.code === "messaging/registration-token-not-registered"
    ) {
      await prisma.user.update({ where: { id: userId }, data: { fcmToken: null } }).catch(() => {});
    }
  }
};
export const getUserNotifications = async (userId, { page = 1, limit = 10, isRead }) => {
  const skip = (page - 1) * limit;

  const where = {
    userId,
    ...(isRead !== undefined && { isRead: isRead === "true" || isRead === true }),
  };

  const [notifications, total] = await Promise.all([
    prisma.notification.findMany({
      where,
      orderBy: { createdAt: "desc" },
      skip,
      take: Number(limit),
    }),
    prisma.notification.count({ where }),
  ]);

  return {
    notifications,
    pagination: {
      total,
      page: Number(page),
      limit: Number(limit),
      totalPages: Math.ceil(total / limit),
    },
  };
};

export const getUnreadCount = async (userId) => {
  const count = await prisma.notification.count({ where: { userId, isRead: false } });
  return { unreadCount: count };
};

export const markAsRead = async (notificationId, userId) => {
  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });

  if (!notification) throw new ApiError(404, "الإشعار غير موجود");
  if (notification.userId !== userId) throw new ApiError(403, "غير مسموح لك بالوصول لهذا الإشعار");

  return prisma.notification.update({ where: { id: notificationId }, data: { isRead: true } });
};

export const markAllAsRead = async (userId) => {
  return prisma.notification.updateMany({
    where: { userId, isRead: false },
    data: { isRead: true },
  });
};

export const deleteNotification = async (notificationId, userId) => {
  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });

  if (!notification) throw new ApiError(404, "الإشعار غير موجود");
  if (notification.userId !== userId) throw new ApiError(403, "غير مسموح لك بالوصول لهذا الإشعار");

  return prisma.notification.delete({ where: { id: notificationId } });
};