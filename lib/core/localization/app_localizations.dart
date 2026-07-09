import 'package:flutter/material.dart';

class AppLanguageController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggle() {
    setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }
}

class AppLanguageScope extends InheritedNotifier<AppLanguageController> {
  const AppLanguageScope({
    super.key,
    required AppLanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLanguageController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    assert(scope != null, 'AppLanguageScope was not found in the widget tree');
    return scope!.notifier!;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLanguageController get language => AppLanguageScope.of(this);
  bool get isArabic => language.isArabic;
  TextDirection get appTextDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  String tr(String key) {
    if (!isArabic) return key;
    return _ar[key] ?? key;
  }
}

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            label: 'EN',
            selected: !isArabic,
            onTap: () => context.language.setLocale(const Locale('en')),
          ),
          _LanguageOption(
            label: 'AR',
            selected: isArabic,
            onTap: () => context.language.setLocale(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 52,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC69DCF) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF575555),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

const Map<String, String> _ar = {
  'Answer': 'رد',
  'Decline': 'رفض',
  'Emergency Call': 'اتصال طارئ',
  'SEND & Call': 'إرسال واتصال',
  'activity': 'النشاط',
  'Br. Memory': 'بي آر ميموري',
  'Br. memory': 'بي آر ميموري',
  'Skip': 'تخطي',
  'Next': 'التالي',
  'A digital solution': 'حل رقمي',
  "That supports Alzheimer's families and makes care-giving easier and more humane":
      'يدعم عائلات مرضى الزهايمر ويجعل الرعاية أسهل وأكثر إنسانية',
  'patient Day Mgmt': 'إدارة يوم المريض',
  'medication, meal, and check-ups all in one smart system':
      'الأدوية والوجبات والفحوصات في نظام ذكي واحد',
  'Instant alerts': 'تنبيهات فورية',
  "continuous connection because the patient's comfort starts with their family's peace of mind":
      'اتصال مستمر لأن راحة المريض تبدأ من اطمئنان عائلته',
  'Create an Account': 'إنشاء حساب',
  'Support your loved one with a connected experience':
      'ادعم من تحب بتجربة رعاية متصلة',
  'Register': 'تسجيل',
  'Have an account? ': 'لديك حساب؟ ',
  'Login': 'تسجيل الدخول',
  'Welcome! Please login': 'مرحبًا! الرجاء تسجيل الدخول',
  'Enter Your Email': 'أدخل بريدك الإلكتروني',
  'Enter Your Password': 'أدخل كلمة المرور',
  'incorrect password!': 'كلمة المرور غير صحيحة!',
  'Forget Password?': 'نسيت كلمة المرور؟',
  'Create your account to get started': 'أنشئ حسابك للبدء',
  'Full Name': 'الاسم بالكامل',
  'Email': 'البريد الإلكتروني',
  'Phone Number': 'رقم الهاتف',
  'Password': 'كلمة المرور',
  'By registering you agree to our\nTerms and Conditions':
      'بتسجيلك فأنت توافق على\nالشروط والأحكام',
  'Forgot\nPassword': 'نسيت\nكلمة المرور',
  'We will send you a message to set or reset your new password':
      'سنرسل لك رسالة لتعيين كلمة المرور الجديدة أو إعادة تعيينها',
  'Verification Method': 'طريقة التحقق',
  'Choose your preferred verification method': 'اختر طريقة التحقق المناسبة لك',
  'Phone': 'الهاتف',
  'Press here': 'اضغط هنا',
  'Enter Your Phone': 'أدخل رقم الهاتف',
  'Verify Phone': 'تأكيد الهاتف',
  'Enter the verification code sent to your phone number':
      'أدخل رمز التحقق المرسل إلى رقم هاتفك',
  'Verify and Continue': 'تحقق وتابع',
  'Reset\nPassword': 'إعادة تعيين\nكلمة المرور',
  'Please enter your new password': 'أدخل كلمة المرور الجديدة',
  'Confirm Password': 'تأكيد كلمة المرور',
  'Home': 'الرئيسية',
  'Routine': 'الروتين',
  'Contact': 'التواصل',
  'Patient': 'المريض',
  'Sensors': 'الحساسات',
  'Hello, Ali': 'مرحبًا، علي',
  'Location ': 'الموقع ',
  '(Live)': '(مباشر)',
  'Emergency Help': 'مساعدة طارئة',
  'Vitals & Result': 'المؤشرات والنتائج',
  'Care Notes': 'ملاحظات الرعاية',
  'Current Location : ': 'الموقع الحالي: ',
  'Bedroom': 'غرفة النوم',
  'Statue : ': 'الحالة: ',
  'Status : ': 'الحالة: ',
  'Safe': 'آمن',
  'See details': 'عرض التفاصيل',
  'Get immediate\nassistance': 'احصل على\nمساعدة فورية',
  'Call for Help': 'طلب المساعدة',
  'battery': 'البطارية',
  'Heart': 'القلب',
  'bpm': 'نبضة/دقيقة',
  'Blood-S': 'السكر',
  'mmol/L': 'مليمول/لتر',
  'Blood-P': 'الضغط',
  'mmHg': 'مم زئبق',
  'Steps': 'الخطوات',
  'Sleep': 'النوم',
  'H': 'س',
  'Min': 'دقيقة',
  'Water': 'الماء',
  'L': 'لتر',
  'Health Report': 'تقرير صحي',
  'View Report': 'عرض التقرير',
  'Average Daily Health': 'متوسط الصحة اليومي',
  'Result': 'النتيجة',
  'Date: 25 April 2026': 'التاريخ: 25 أبريل 2026',
  'Time': 'الوقت',
  'Time: 8:00 PM': 'الوقت: 8:00 مساءً',
  '9:50 PM': '9:50 مساءً',
  'Average Vital Signs': 'متوسط المؤشرات الحيوية',
  'Heart Rate: 82 bpm': 'نبض القلب: 82 نبضة/دقيقة',
  '80 bpm': '80 نبضة/دقيقة',
  '82 bpm': '82 نبضة/دقيقة',
  '851 ms': '851 مللي ثانية',
  'Blood Pressure: 120/80 mmHg': 'ضغط الدم: 120/80 مم زئبق',
  'Blood Sugar: 8.1 mmol/L': 'سكر الدم: 8.1 مليمول/لتر',
  'Blood Pressure': 'ضغط الدم',
  'Pressure': 'الضغط',
  'Status: Normal / Hypertension': 'الحالة: طبيعي / ارتفاع ضغط',
  'Morning': 'الصباح',
  'Evening': 'المساء',
  'Average': 'المتوسط',
  'Highest': 'الأعلى',
  'Lowest': 'الأقل',
  'Blood Sugar': 'سكر الدم',
  'Glucose': 'الجلوكوز',
  'Status: High / Normal': 'الحالة: مرتفع / طبيعي',
  'Before Meal': 'قبل الوجبة',
  'After Meal': 'بعد الوجبة',
  'Notes: Ate sweets': 'ملاحظات: تناول حلويات',
  'Notes: Missed medication': 'ملاحظات: نسي الدواء',
  'Highest: 90 mg/dL': 'الأعلى: 90 مجم/دل',
  'Average: 59 mg/dL': 'المتوسط: 59 مجم/دل',
  'Lowest: 48mg/dL': 'الأقل: 48 مجم/دل',
  'Today Blood Sugar': 'سكر الدم اليوم',
  'Heartbeat': 'نبض القلب',
  'Status : Normal': 'الحالة: طبيعي',
  'Status: Normal': 'الحالة: طبيعي',
  'Status: Measuring': 'الحالة: جار القياس',
  'Status: Not available': 'الحالة: غير متاح',
  'Status: Watch not connected': 'الحالة: الساعة غير متصلة',
  'Measure now': 'قياس الآن',
  'Measuring...': 'جار القياس...',
  'Current Reading:': 'القراءة الحالية:',
  'Heart Variability (HRV)': 'تغير نبض القلب (HRV)',
  'Today Heart Activity': 'نشاط القلب اليوم',
  'Highest: 102 bpm': 'الأعلى: 102 نبضة/دقيقة',
  'Average: 78 bpm': 'المتوسط: 78 نبضة/دقيقة',
  'Lowest: 65 bpm': 'الأقل: 65 نبضة/دقيقة',
  'Daily Activity': 'النشاط اليومي',
  'steps': 'خطوة',
  'Activity Steps': 'خطوات النشاط',
  'Sleep Analysis': 'تحليل النوم',
  'Status: Sleep': 'الحالة: نائم',
  'Sleep Timeline': 'الجدول الزمني للنوم',
  'Deep\nSleep': 'نوم\nعميق',
  'Light\nSleep': 'نوم\nخفيف',
  'Awake': 'مستيقظ',
  'Water reminder': 'تذكير شرب الماء',
  'Please drink 2 glass of water now.': 'يرجى شرب كوبين من الماء الآن.',
  'Send': 'إرسال',
  'Goal : ': 'الهدف: ',
  '3L': '3 لتر',
  'Cups': 'أكواب',
  'Average Daily Activity': 'متوسط النشاط اليومي',
  'Steps: 50 steps': 'الخطوات: 50 خطوة',
  'Water Intake: 2 L': 'شرب الماء: 2 لتر',
  'Total Sleep: 7h 24m': 'إجمالي النوم: 7 ساعات و24 دقيقة',
  'Status': 'الحالة',
  'Overall Status: Stable': 'الحالة العامة: مستقرة',
  'Notes:': 'ملاحظات:',
  'No abnormal activity detected': 'لم يتم رصد نشاط غير طبيعي',
  'Your report will be sent in 10 minutes.': 'سيتم إرسال تقريرك خلال 10 دقائق.',
  'Send Now': 'إرسال الآن',
  'Hold': 'انتظار',
  'Add Call': 'إضافة مكالمة',
  'Mute': 'كتم الصوت',
  'Video call': 'مكالمة فيديو',
  'End': 'إنهاء',
  'Speaker': 'السماعة',
  'Home Status': 'حالة المنزل',
  'Bathroom': 'الحمام',
  "Kid's room": 'غرفة الأطفال',
  'Kitchen': 'المطبخ',
  'Dinging room': 'غرفة الطعام',
  'Living room': 'غرفة المعيشة',
  'Fall detected': 'تم رصد سقوط',
  'Fall status': 'حالة السقوط',
  'Confidence': 'الثقة',
  'Camera': 'الكاميرا',
  'Online': 'متصل',
  'Location': 'المكان',
  'Patient Activity': 'نشاط المريض',
  'Last update: 2 min ago': 'آخر تحديث: منذ دقيقتين',
  'View Timeline': 'عرض السجل الزمني',
  'REPORT': 'بلاغ',
  'What kind of emergency ?': 'ما نوع الطوارئ؟',
  'Fall': 'سقوط',
  'Fire': 'حريق',
  'Flood': 'فيضان',
  'Missing': 'مفقود',
  'Where is the emergency?': 'أين حالة الطوارئ؟',
  'MY LOCATION': 'موقعي',
  'Call': 'اتصال',
  'Emergency Alert!': 'تنبيه طارئ!',
  'Type : ': 'النوع: ',
  'Fall Detected': 'تم رصد سقوط',
  'Location: ': 'الموقع: ',
  'Building: ': 'المبنى: ',
  'Al Nour Residence': 'سكن النور',
  'Floor: ': 'الدور: ',
  '3, Apartment: 12B': '3، شقة: 12B',
  'SEND': 'إرسال',
  'CANCEL': 'إلغاء',
  'We will contact the nearest hospital, police station to your current location':
      'سنتواصل مع أقرب مستشفى وقسم شرطة إلى موقعك الحالي',
  'Add Care Note': 'إضافة ملاحظة رعاية',
  'Write your note here...': 'اكتب ملاحظتك هنا...',
  'Post Note': 'نشر الملاحظة',
  'Just now': 'الآن',
  'Now': 'الآن',
  'Thursday, 30 May 2026': 'الخميس، 30 مايو 2026',
  'Wednesday, 29 Apr 2026': 'الأربعاء، 29 أبريل 2026',
  '3 PM': '3 مساءً',
  '11 AM': '11 صباحًا',
  '1 hr ago': 'منذ ساعة',
  '3 hrs ago': 'منذ 3 ساعات',
  'Dad ate his meal well today, and his appetite is noticeably improving. He asked to go for a walk in the garden.':
      'تناول أبي وجبته جيدًا اليوم، وشهيته تتحسن بشكل ملحوظ. طلب أن يذهب في نزهة في الحديقة.',
  'He felt a bit confused in the afternoon, possibly due to poor sleep last night. I gave him a warm cup of anise tea and he calmed down.':
      'شعر ببعض الارتباك بعد الظهر، ربما بسبب قلة النوم الليلة الماضية. أعطيته كوبًا دافئًا من اليانسون فهدأ.',
  'He forgot where he left his glasses this morning, but after a short search we found them. He felt better and started his day calmly.':
      'نسي أين ترك نظارته هذا الصباح، لكن بعد بحث قصير وجدناها. شعر بتحسن وبدأ يومه بهدوء.',
  'Like': 'إعجاب',
  'reactions': 'تفاعلات',
  'all': 'الكل',
  'Patient information': 'بيانات المريض',
  'your name': 'اسمك',
  'location': 'الموقع',
  'gender': 'النوع',
  'Year of birth': 'سنة الميلاد',
  'height': 'الطول',
  'body weight': 'الوزن',
  'Cancel': 'إلغاء',
  'Confirm': 'تأكيد',
  'Name': 'الاسم',
  'Enter your name': 'أدخل اسمك',
  'Enter your building': 'أدخل المبنى',
  'Enter your apartment': 'أدخل الشقة',
  'Enter your floor': 'أدخل الدور',
  'female': 'أنثى',
  'male': 'ذكر',
  'year of birth': 'سنة الميلاد',
  'height (cm)': 'الطول (سم)',
  'weight (kg)': 'الوزن (كجم)',
  'Enter your height': 'أدخل طولك',
  'Enter your weight': 'أدخل وزنك',
  'Language': 'اللغة',
  'Daily Routine': 'الروتين اليومي',
  'Daily Progress': 'التقدم اليومي',
  'done': 'تم',
  'Morning Tasks': 'مهام الصباح',
  'current Time: 10:00 AM': 'الوقت الحالي: 10:00 ص',
  'Upcoming': 'القادم',
  'Drink Water': 'اشرب الماء',
  'Medication': 'الدواء',
  'Eat Breakfast': 'تناول الإفطار',
  'Eat Lunch': 'تناول الغداء',
  'Scheduled: 9:30 AM': 'مجدول: 9:30 ص',
  'Completed at 9:30 AM': 'اكتمل في 9:30 ص',
  'Finish two full glass of water to stay hydrated.':
      'اشرب كوبين كاملين من الماء للحفاظ على الترطيب.',
  'Scheduled: 10:00 AM': 'مجدول: 10:00 ص',
  'Completed at 10:00 AM': 'اكتمل في 10:00 ص',
  'Time to take your medication. Please take 3 tablets of Panadol with water.':
      'حان وقت الدواء. يرجى تناول 3 أقراص بانادول مع الماء.',
  'Scheduled: 8:00 AM': 'مجدول: 8:00 ص',
  'Completed at 7:45 AM': 'اكتمل في 7:45 ص',
  'Scheduled: 12:30 PM': 'مجدول: 12:30 م',
  'Completed at 12:30 PM': 'اكتمل في 12:30 م',
  'NOT TIME YET': 'لم يحن الوقت',
  'DONE': 'تم',
  'Total': 'الإجمالي',
  'Connected': 'متصل',
  'Offline': 'غير متصل',
  'Active': 'نشط',
  'IMILAB W12 Watch': 'ساعة IMILAB W12',
  'Smart Watch': 'ساعة ذكية',
  'Search Watch': 'بحث عن الساعة',
  'Scanning...': 'جار البحث...',
  'Connecting...': 'جار الاتصال...',
  'Disconnect': 'قطع الاتصال',
  'Connect': 'اتصال',
  'Searching for IMILAB W12...': 'جار البحث عن IMILAB W12...',
  'Searching for supported watch...': 'جار البحث عن ساعة مدعومة...',
  'Searching for Bluetooth watches/devices...':
      'جار البحث عن ساعات/أجهزة بلوتوث...',
  'Bluetooth is off': 'البلوتوث مغلق',
  'Bluetooth permission needed': 'مطلوب إذن البلوتوث',
  'Connection error': 'خطأ في الاتصال',
  'No watch found': 'لم يتم العثور على الساعة',
  'No Bluetooth watch/device found': 'لم يتم العثور على ساعة/جهاز بلوتوث',
  'Tap scan to find your watch': 'اضغط بحث للعثور على ساعتك',
  'Tap scan to find any Bluetooth watch': 'اضغط بحث للعثور على أي ساعة بلوتوث',
  'Found devices': 'الأجهزة التي تم العثور عليها',
  'Battery': 'البطارية',
  'Heart Rate': 'نبض القلب',
  'Heart Rate (BPM)': 'معدل ضربات القلب',
  'Health Connect': 'Health Connect',
  'Read data': 'قراءة البيانات',
  'Read synced watch data': 'قراءة بيانات الساعة المتزامنة',
  'Health Connect permission needed': 'مطلوب إذن Health Connect',
  'Health Connect data loaded': 'تم تحميل بيانات Health Connect',
  'Allow Br. Memory to read Heart rate and Steps':
      'اسمح لتطبيق Br. Memory بقراءة نبض القلب والخطوات',
  'Could not read Health Connect data': 'تعذرت قراءة بيانات Health Connect',
  'Open Health Connect': 'فتح Health Connect',
  'Not available': 'غير متاح',
  'Refresh readings': 'تحديث القراءات',
  'Reading...': 'جار قراءة البيانات...',
  'Checking watch readings...': 'جار فحص قراءات الساعة...',
  'Could not read watch readings': 'تعذرت قراءة بيانات الساعة',
  'Could not subscribe to heart-rate readings':
      'تعذر الاشتراك في قراءات نبض القلب',
  'Health Connect is not available': 'Health Connect غير متاح على هذا الهاتف',
  'Allow Br. Memory to read Heart rate':
      'اسمح لتطبيق Br. Memory بقراءة نبض القلب',
  'No heart-rate data found in Health Connect':
      'لا توجد بيانات نبض في Health Connect',
  'Could not read Health Connect heart rate':
      'تعذرت قراءة نبض القلب من Health Connect',
  'AI fall model not connected': 'موديل السقوط غير متصل',
  'AI Fall Model': 'موديل السقوط AI',
  'Connected to AI fall model': 'متصل بموديل السقوط',
  'Start the Python fall model on the computer':
      'شغل موديل السقوط Python على الكمبيوتر',
  'Model command failed': 'تعذر إرسال الأمر للموديل',
  'Heart rate is not exposed by this watch over standard Bluetooth':
      'الساعة لا تعرض نبض القلب للتطبيق عبر البلوتوث القياسي',
  'Start heart-rate measurement on the watch, then refresh':
      'شغّل قياس النبض من الساعة ثم حدّث القراءات',
  'Start heart-rate measurement on the watch, then keep this screen open for 20 seconds':
      'شغّل قياس النبض من الساعة ثم اترك هذه الشاشة مفتوحة 20 ثانية',
  'Reading watch live data...': 'جار قراءة بيانات الساعة المباشرة...',
  'No watch reading yet': 'لا توجد قراءة من الساعة بعد',
  'Bedroom Sensor': 'حساس غرفة النوم',
  'Door Sensor': 'حساس الباب',
  'Living Room Sensor': 'حساس غرفة المعيشة',
  'Bathroom Sensor': 'حساس الحمام',
  'Last seen: ': 'آخر ظهور: ',
  'ID: ': 'المعرف: ',
  '2 min ago': 'منذ دقيقتين',
  '5 min ago': 'منذ 5 دقائق',
  '1 min ago': 'منذ دقيقة',
  '2 hours ago': 'منذ ساعتين',
  'Dad': 'الأب',
  'Omar': 'عمر',
  "Don't forget those who loved you without expecting anything in return.":
      'لا تنس من أحبوك دون انتظار أي مقابل.',
  'Hardware Sensors': 'حساسات الهاردوير',
  'Connected to ESP32': 'متصل بـ ESP32',
  'Connect phone to ESP32 Wi-Fi': 'وصل الموبايل بشبكة ESP32 Wi-Fi',
  'ESP32 not connected': 'ESP32 غير متصل',
  'Servo command failed': 'فشل أمر السيرفو',
  'Refresh': 'تحديث',
  'Flame': 'حساس اللهب',
  'Fire detected': 'تم رصد حريق',
  'Water found': 'تم رصد ماء',
  'Dry': 'جاف',
  'Temperature': 'درجة الحرارة',
  'Gas': 'حساس الغاز',
  'Ultrasonic': 'حساس المسافة',
  'Obstacle': 'جسم قريب',
  'Clear': 'واضح',
  'cm': 'سم',
  'MPU6050': 'حساس الحركة MPU6050',
  'LDR Sensor': 'حساس الضوء LDR',
  'Light detected': 'ضوء مكشوف',
  'Dark': 'ظلام',
  'Servo': 'السيرفو',
  'Servo angle control': 'مؤشر زاوية السيرفو',
  'deg': 'درجة',
  'Buzzer': 'الجرس',
  'On': 'يعمل',
  'Off': 'متوقف',
  'Alert: flame detected': 'تنبيه: تم رصد لهب',
  'Alert: gas detected': 'تنبيه: تم رصد غاز',
  'Alert: water detected': 'تنبيه: تم رصد مياه',
  'Sensor alert': 'تنبيه حساس',
  '0 deg': '0 درجة',
  '90 deg': '90 درجة',
  'Current GPS Location': 'الموقع الحالي على الخريطة',
  'Patient location': 'موقع المريض',
  'Loading location...': 'جاري تحميل الموقع...',
  'Loading current location...': 'جاري تحميل الموقع الحالي...',
  'Location permission required': 'مطلوب إذن الموقع',
  'Location permission permanently denied': 'تم رفض إذن الموقع نهائيًا',
  'Turn on location services': 'شغّل خدمات الموقع',
  'Open app settings': 'فتح إعدادات التطبيق',
  'Could not get current location': 'تعذر الحصول على الموقع الحالي',
  'Refresh location': 'تحديث الموقع',
  'Recenter': 'توسيط الخريطة',
  'Latitude': 'خط العرض',
  'Longitude': 'خط الطول',
  'Accuracy': 'الدقة',
  'm': 'متر',
  'Fall detected by model': 'تم رصد سقوط من الموديل',
  'Alert: fall detected by model': 'تنبيه: تم رصد سقوط من الموديل',
};
