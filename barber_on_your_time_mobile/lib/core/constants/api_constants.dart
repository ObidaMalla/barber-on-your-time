abstract class ApiConstants {
  // الرابط الجديد المرفوع على Render
  static const String baseUrl = 'http://localhost:3000';
}

/*
*
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:3000 tcp:3000
* وهذه التعليمة تقوم بربط المنفذ 3000 الخاص بالمحاكي بنفس المنفذ على جهازك الشخصي، مما يتيح لك استخدام http://localhost:3000 داخل التطبيق مباشرة.
* */
