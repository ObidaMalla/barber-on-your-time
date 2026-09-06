/*import { initializeApp, cert } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";
import { readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const serviceAccount = JSON.parse(
  readFileSync(join(__dirname, "../../firebase-service-account.json"), "utf-8")
);

initializeApp({ credential: cert(serviceAccount) });

const messaging = getMessaging();
export default messaging;*/

import { initializeApp, cert } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";

const rawServiceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;

if (!rawServiceAccount) {
  throw new Error("FIREBASE_SERVICE_ACCOUNT is missing in environment variables!");
}

// تحويل النص إلى Object إذا كان قادماً كـ String
const serviceAccount = typeof rawServiceAccount === "string" 
  ? JSON.parse(rawServiceAccount) 
  : rawServiceAccount;

// معالجة الأسطر الجديدة في المفتاح الخاص لمنع خطأ الاتصال
if (serviceAccount.private_key) {
  serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
}

initializeApp({ credential: cert(serviceAccount) });

const messaging = getMessaging();
export default messaging;