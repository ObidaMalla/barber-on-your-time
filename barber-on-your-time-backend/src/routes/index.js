import express from "express";

import authRoutes from "./authRoutes.js";
import businessRoutes from "./businessRoutes.js";
import serviceRoutes from "./serviceRoutes.js";
import availabilityRoutes from "./availabilityRoutes.js";
import bookingRoutes from "./bookingRoutes.js";
import userRoutes from "./userRoutes.js";
import notificationsRoutes from "./notifications.js"; // 👈 تم تعديل الاسم لـ notifications.js

const router = express.Router();

// Health Check Endpoint
router.get("/", (req, res) => {
  res.json({
    success: true,
    statusCode: 200,
    message: "Barber On Your Time API Running",
    data: null,
  });
});

router.use("/auth", authRoutes);
router.use("/business", businessRoutes);
router.use("/services", serviceRoutes);
router.use("/availability", availabilityRoutes);
router.use("/bookings", bookingRoutes);
router.use("/users", userRoutes);
router.use("/notifications", notificationsRoutes);

export default router;

/*
import usersRouter from "./users.js";
import authRouter from "./auth.js";
import tasksRouter from "./tasks.js";
import projectsRoutes from "./projects.js";
import commentsRouter from "./comments.js";
import adminRouter from "./admin.js";

import notificationsRoutes from "./notifications.js"; // 👈 استيراد صحيح للموجه
const router = express.Router();


///بفيدني شوف اذا السيرفر شغال  
///http://localhost:3000
///يفضل دائماً إبقاؤه لأنه خفيف جداً (لا يستهلك أي موارد أو استعلامات داتا بيز) ويعتبر معياراً قياسياً (Best Practice) في بناء الـ REST APIs.
/*فوائد وجود هذا المسار (لماذا نتركه؟)
اختبار سلامة السيرفر (Health Check): بيسمح لك تتأكد فوراً إن السيرفر شغال ومستجيب من Postman أو المتصفح برابط http://localhost:3000/ بدون ما تضطر تبعث Headers أو Tokens أو بيانات معقدة.

فحص الاستضافة السحابية (Cloud Deployment): خدمات الرفع السحابي (مثل Render أو AWS أو Railway) بتعمل Pings تلقائية على المسار الرئيسي / لتتأكد إن التطبيق شغال ومو معلّق (Crash).

تجربة مستخدم/مطور أنظف: بدل ما يظهر للمستخدم أو المطور صفحة خطأ صفراء بـ Express تسمى Cannot GET / لما يفتح رابط الـ Domain الرئيسي، بتظهر له رسالة JSON مرتبة بتوضح إن الـ API شغال.



*/
/*
router.get("/", (req, res) => {

    res.json({
        success: true,
        statusCode: 200,
        message: "TaskFlow API Running",
        data: null
    });

});

router.use("/users", usersRouter);
router.use("/auth", authRouter);
router.use("/tasks", tasksRouter);
router.use("/projects", projectsRoutes);
router.use(
    "/comments",
    commentsRouter
);
router.use(
    "/admin",
    adminRouter
);
router.use("/api/notifications", notificationsRoutes);
export default router;*/