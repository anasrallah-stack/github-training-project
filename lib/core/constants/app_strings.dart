class AppStrings {
  // App
  static const appName = 'TimeSync';
  static const appTagline = 'تتبع ساعات عملك تلقائياً';

  // Auth
  static const login = 'تسجيل الدخول';
  static const register = 'إنشاء حساب';
  static const logout = 'تسجيل الخروج';
  static const email = 'البريد الإلكتروني';
  static const password = 'كلمة المرور';
  static const fullName = 'الاسم الكامل';
  static const confirmPassword = 'تأكيد كلمة المرور';
  static const forgotPassword = 'نسيت كلمة المرور؟';
  static const signInWithGoogle = 'الدخول بحساب Google';
  static const dontHaveAccount = 'ليس لديك حساب؟';
  static const alreadyHaveAccount = 'لديك حساب بالفعل؟';
  static const createAccount = 'إنشاء حساب جديد';

  // Dashboard
  static const welcomeBack = 'مرحباً بعودتك';
  static const todayHours = 'ساعات اليوم';
  static const weeklyHours = 'ساعات الأسبوع';
  static const currentStatus = 'الحالة الحالية';
  static const tracking = 'جارٍ التتبع';
  static const notTracking = 'متوقف';
  static const connectedTo = 'متصل بـ';
  static const disconnected = 'غير متصل';
  static const trackingFor = 'يتم تتبع الوقت لـ';

  // Tracking
  static const sessionHistory = 'سجل الجلسات';
  static const startTime = 'وقت البداية';
  static const endTime = 'وقت النهاية';
  static const duration = 'المدة';
  static const totalHours = 'إجمالي الساعات';
  static const noSessions = 'لا توجد جلسات بعد';

  // Reports
  static const weeklyReport = 'التقرير الأسبوعي';
  static const dailyAverage = 'المعدل اليومي';
  static const productivityScore = 'نقاط الإنتاجية';
  static const exportPdf = 'تصدير PDF';

  // Profile
  static const myProfile = 'ملفي الشخصي';
  static const editProfile = 'تعديل الملف';
  static const syncedDevices = 'الأجهزة المتزامنة';
  static const thisDevice = 'هذا الجهاز';

  // Settings
  static const settings = 'الإعدادات';
  static const wifiSettings = 'إعدادات Wi-Fi';
  static const chooseWifi = 'اختيار شبكة العمل';
  static const notifications = 'الإشعارات';
  static const darkMode = 'الوضع الليلي';
  static const language = 'اللغة';
  static const arabic = 'العربية';
  static const english = 'English';

  // Devices
  static const deviceSync = 'مزامنة الأجهزة';
  static const addDevice = 'إضافة جهاز';
  static const removeDevice = 'إزالة الجهاز';
  static const lastSeen = 'آخر ظهور';

  // Days
  static const days = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  static const daysShort = [
    'سبت',
    'أحد',
    'إثن',
    'ثلا',
    'أرب',
    'خمس',
    'جمع',
  ];
  static const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  // Errors
  static const emailRequired = 'البريد الإلكتروني مطلوب';
  static const invalidEmail = 'البريد الإلكتروني غير صالح';
  static const passwordRequired = 'كلمة المرور مطلوبة';
  static const passwordTooShort = 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)';
  static const nameRequired = 'الاسم مطلوب';
  static const passwordsMismatch = 'كلمتا المرور غير متطابقتين';
  static const loginFailed = 'فشل تسجيل الدخول. تحقق من بياناتك.';
  static const networkError = 'خطأ في الاتصال بالشبكة';
}
