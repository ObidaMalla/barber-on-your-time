/*import cron from "node-cron";
import { prisma } from "../config/prisma.js";
import { createNotification } from "../services/notificationsService.js";

export const startDueDateReminderJob = () => {
  cron.schedule("* * * * *", async () => {
    const now = new Date();

    const dueTasks = await prisma.task.findMany({
      where: {
        dueDate: { lte: now },
        status: { notIn: ["DONE", "CANCELLED"] }, // 👈 عدّلنا الشرط
        notified: false,
      },
    });

    for (const task of dueTasks) {
      // 1. ابعت إشعار الإلغاء
      await createNotification({
        userId: task.userId,
        type: "TASK_DUE_SOON",
        title: "⛔ تم إلغاء المهمة",
        message: `المهمة "${task.title}" انتهى وقتها ولم تكتمل، تم إلغاؤها تلقائياً`,
        data: { taskId: task.id },
      });

      // 2. 👇 جديد — غيّر الحالة لـ CANCELLED بنفس اللحظة
      await prisma.task.update({
        where: { id: task.id },
        data: { status: "CANCELLED", notified: true },
      });
    }

    if (dueTasks.length > 0) {
      console.log(`⛔ تم إلغاء ${dueTasks.length} مهمة متأخرة`);
    }
  });
};*/