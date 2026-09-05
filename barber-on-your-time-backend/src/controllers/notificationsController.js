import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import * as notificationsService from "../services/notificationsService.js";

export const getMyNotifications = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { page, limit, isRead } = req.query;

  const result = await notificationsService.getUserNotifications(userId, {
    page,
    limit,
    isRead,
  });

  res.status(200).json(new ApiResponse(true, 200, "تم جلب الإشعارات بنجاح", result));
});

export const getUnreadCount = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const result = await notificationsService.getUnreadCount(userId);

  res.status(200).json(new ApiResponse(true, 200, "تم جلب عدد الإشعارات الغير مقروءة", result));
});

export const markNotificationAsRead = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;

  const notification = await notificationsService.markAsRead(id, userId);

  res.status(200).json(new ApiResponse(true, 200, "تم تعليم الإشعار كمقروء", notification));
});

export const markAllNotificationsAsRead = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const result = await notificationsService.markAllAsRead(userId);

  res.status(200).json(new ApiResponse(true, 200, "تم تعليم كل الإشعارات كمقروءة", result));
});

export const deleteNotification = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;

  await notificationsService.deleteNotification(id, userId);

  res.status(200).json(new ApiResponse(true, 200, "تم حذف الإشعار بنجاح", null));
});