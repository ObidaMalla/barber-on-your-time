# 💈 Barber On Your Time — Salon Booking Management System

نظام حجز مواعيد لصالونات الحلاقة، بميزته الأساسية: **تحويل تلقائي للحجز** — لو الحلاق رفض طلب حجز، ينتقل تلقائيًا لأقرب حلاق بديل متوفر بنفس الوقت، بدون ما الزبون يحتاج يعيد المحاولة يدويًا.

---
🔗 Backend Live:barber-on-your-time.onrender.com



## 📋 نظرة عامة

تطبيق يربط بين ثلاثة أطراف: **صاحب صالون**، **حلاق (موظف)**، و**زبون**. كل مستخدم يسجل كـ Customer بشكل افتراضي، ويترقّى تلقائيًا لـ Owner (عند إنشاء محل) أو Staff (عند الانضمام بكود دعوة).

### الأدوار الثلاثة
| الدور | الصلاحيات |
|---|---|
| **Customer (زبون)** | يحجز خدمة مع حلاق معين، يشوف حجوزاته، يلغي حجز |
| **Staff (حلاق)** | ينضم بكود دعوة، يحدد دوامه، يوافق/يرفض الحجوزات، يطلب تعديل دوامه |
| **Salon Owner (صاحب صالون)** | ينشئ محل، يضيف خدمات، يولّد أكواد دعوة للحلاقين، يطرد موظفين، يوافق/يرفض طلبات تعديل الدوام |

---

## ✨ أبرز الميزات التقنية

- **تحويل تلقائي للحجز (Automatic Booking Reassignment)** — عند رفض الحلاق للحجز، يبحث النظام عن حلاق بديل متوفر بنفس الوقت تلقائيًا، ويتجاهل كل الحلاقين المجرَّبين سابقًا لنفس الحجز
- **نظام تأكيد اكتمال الخدمة بكود تحقق (Completion Code)** — عند قبول الحجز، يتولّد كود عشوائي يوصل للزبون، ولازم الحلاق يدخله بعد انتهاء الموعد فعليًا حتى يتحول الحجز لـ COMPLETED؛ هيك ما فيه لا الزبون يقدر يقفل حجز بدون ما ياخد الخدمة، ولا الحلاق يقدر يقفله بدون تأكيد حضور الزبون
- **نظام موافقة على تعديلات الدوام** — أي تغيير (إضافة أو حذف) بجدول دوام الحلاق لازم يمر بموافقة صاحب الصالون قبل ما ينفّذ فعليًا
- **Soft Delete للموظفين** — الحلاق المطرود ما بينحذف فعليًا من قاعدة البيانات (حفاظًا على السجل التاريخي للحجوزات)، بس بيتعطّل (`active: false`)
- **حماية صارمة من تسريب بيانات المستخدم** — أي استعلام بيرجع بيانات مرتبطة بـ `User` (زي الحلاق أو العميل بحجز)، بيستخدم `select` محدد بدل `include` الكامل، حتى ولو الحقل المشفر (`password`) ما يترجع أبدًا بأي رد
- **معاملات ذرية (`$transaction`)** بكل عملية فيها أكتر من تغيير مترابط (إنشاء محل + ترقية owner، انضمام حلاق + تحديث كود الدعوة + ترقية role...) لضمان تناسق البيانات حتى لو صار خطأ بالمنتصف
- **Blacklisted Tokens** لتسجيل خروج آمن رغم طبيعة JWT الـ Stateless
- **فحص أوقات الفراغ (Free Slots)** — endpoint مخصص يحسب الأوقات المتاحة فعليًا عند كل حلاق ضمن دوامه، مع أخذ فترة استراحة 5 دقائق بعد كل حجز بعين الاعتبار

---

## 🛠️ التقنيات المستخدمة

**Backend:**
- Node.js + Express.js (ES Modules)
- PostgreSQL + Prisma ORM
- JWT (jsonwebtoken) + bcrypt

**Frontend:**
- Flutter + Dart
- BLoC / Cubit لإدارة الحالة
- Retrofit + Dio للاتصال بالـ API
- GetIt لحقن التبعيات
- Freezed
- Firebase Messaging (إشعارات Push)

---

## 🏗️ المعمارية

```
Flutter
 ├── UI
 ├── Cubit / BLoC
 ├── Repository
 ├── Retrofit / Dio
 ├── Models
 └── Dependency Injection
        │
        ▼  REST API
Node.js + Express
 ├── Routes
 ├── Middlewares (auth)
 ├── Controllers (خفيفة — تحقق أساسي فقط)
 └── Services (كل منطق العمل الحقيقي)
        │
        ▼
     Prisma ORM
        │
        ▼
   PostgreSQL
```

**نمط الكود:** Controller خفيف (يتحقق من صحة الطلب وينادي الـ Service) + Service فيه كل منطق العمل الفعلي والتعامل المباشر مع قاعدة البيانات. الأخطاء تُرمى عبر `ApiError` موحّد بدل تكرار `res.status().json()` بكل مكان، وكل Controller ملفوف بـ `asyncHandler` لتفادي تكرار try/catch.

---

## 🔄 دورة حياة الحجز

```
الزبون يطلب حجز مع حلاق معين بوقت محدد
        │
        ▼
   PENDING (أول BookingAttempt)
        │
   ┌────┴────┐
   ▼         ▼
ACCEPT    REJECT
   │         │
   ▼         ▼
CONFIRMED   البحث عن حلاق بديل متوفر بنفس الوقت
   │         │ (يستثني كل الحلاقين المجرَّبين سابقًا)
   │      ┌──┴──┐
   │      ▼     ▼
   │   وُجد   ما وُجد
   │      │     │
   │      ▼     ▼
   │  محاولة   NEEDS_OWNER
   │  جديدة
   │
   ▼ (بعد الموعد)
الزبون يضغط "استلمت الخدمة" ──> إشعار تذكير للحلاق بكود التحقق
        │
        ▼
الحلاق يُدخل الكود الصحيح ──> COMPLETED
```

> **نفس منطق البحث عن حلاق بديل** بينفّذ تلقائيًا أيضًا لما صاحب الصالون **يطرد موظف** وعندو حجوزات PENDING معلّقة.

---

## 🗄️ الجداول الأساسية (Database Schema)

| الجدول | الوصف |
|---|---|
| `User` | كل مستخدم بالنظام (id, name, email, password مشفّر, role, createdAt) |
| `Business` | الصالون (مرتبط بصاحبه عبر `ownerId` الفريد — صالون واحد لكل owner) |
| `Staff` | علاقة (User ↔ Business) — بيانات عمل الحلاق (`active` لدعم Soft Delete) |
| `Service` | الخدمات المقدَّمة بالصالون (الاسم، المدة، السعر) |
| `StaffInvite` | أكواد دعوة الحلاقين (فريدة، استخدام مرة واحدة) |
| `Booking` | الحجز نفسه (الوقت، الحالة، العميل، الخدمة، الحلاق) |
| `BookingAttempt` | سجل كل محاولة تحويل للحجز بين الحلاقين (الترتيب، الحالة، وقت الرد) |
| `Availability` | دوام كل حلاق (يوم الأسبوع، وقت البداية والنهاية) |
| `AvailabilityChangeRequest` | طلبات تعديل/حذف الدوام بانتظار موافقة صاحب الصالون |
| `BlacklistedToken` | قائمة التوكنات الملغاة (لدعم تسجيل خروج حقيقي) |

---

## 📡 أبرز الـ API Endpoints

### Auth
| Method | Endpoint | الوصف |
|---|---|---|
| `POST` | `/auth/register` | تسجيل حساب جديد (role = CUSTOMER افتراضيًا) |
| `POST` | `/auth/login` | تسجيل الدخول |
| `POST` | `/auth/logout` | تسجيل خروج (Blacklist للتوكن) |

### Business (Owner)
| Method | Endpoint | الوصف |
|---|---|---|
| `POST` | `/business` | إنشاء صالون (يترقّى المستخدم لـ OWNER) |
| `POST` | `/business/staff-invites` | توليد كود دعوة لحلاق جديد |
| `POST` | `/business/join` | انضمام حلاق بكود دعوة (يترقّى لـ STAFF) |
| `DELETE` | `/business/staff/:staffId` | طرد موظف (Soft Delete + تحويل حجوزاته المعلّقة) |

### Services
| Method | Endpoint | الوصف |
|---|---|---|
| `GET/POST/PATCH/DELETE` | `/services` `/services/:id` | إدارة خدمات الصالون (Owner) |

### Availability
| Method | Endpoint | الوصف |
|---|---|---|
| `POST` | `/availability` | تحديد دوام مباشر (Staff) |
| `GET` | `/availability/staff/:id/free-slots` | عرض أوقات الفراغ المتاحة عند حلاق معيّن |
| `POST` | `/availability/requests` `/requests/delete` | طلب إضافة/حذف دوام (بانتظار موافقة) |
| `PATCH` | `/availability/requests/:id` | موافقة/رفض صاحب الصالون على الطلب |

### Bookings
| Method | Endpoint | الوصف |
|---|---|---|
| `POST` | `/bookings` | طلب حجز جديد (Customer) |
| `PATCH` | `/bookings/:id/status` | رد الحلاق (ACCEPT / REJECT) |
| `POST` | `/bookings/:id/request-completion` | الزبون يبلّغ إنه استلم الخدمة |
| `POST` | `/bookings/:id/complete` | الحلاق يؤكد الاكتمال بإدخال الكود |
| `GET` | `/bookings/mine` `/bookings/staff` | عرض الحجوزات (لكل دور حسب صلاحيته) |
| `DELETE` | `/bookings/:id` | إلغاء حجز (Customer) |
| `GET` | `/bookings/my-stats` `/bookings/staff/:id/stats` | إحصائيات الحلاق (أسبوعية + إجمالية) |

---

## 🔐 الأمان والصلاحيات

- مصادقة عبر **JWT** — كل endpoint محمي يتطلب `Authorization: Bearer <token>`
- فحوصات صريحة تمنع تعارض الأدوار: **Owner ما بيقدر ينضم كـ Staff**، و**Staff ما بيقدر ينشئ صالون**
- تسجيل خروج حقيقي عبر **Blacklisted Tokens** بدل الاعتماد فقط على انتهاء صلاحية التوكن

---

## 🚀 التشغيل محليًا

```bash
# 1. استنساخ المشروع
git clone https://github.com/ObidaMalla/barber-on-your-time.git
cd barber-on-your-time

# 2. تثبيت الحزم
npm install

# 3. إعداد متغيرات البيئة
cp .env.example .env
# ثم عبّي القيم المطلوبة (JWT_SECRET, DATABASE_URL, إلخ)

# 4. تطبيق الـ Migrations
npx prisma generate
npx prisma migrate deploy

# 5. تشغيل السيرفر
npm start
```

---

## 👤 المطوّر

**عبيده عبد الفتاح مللا**
Full Stack Developer | Flutter & Node.js

📧 obidamalla@gmail.com | 📱 +963 981 674 273
