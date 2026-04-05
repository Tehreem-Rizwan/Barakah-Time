import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Barakah Time',
      'home': 'Home',
      'quran': 'Quran',
      'pulse': 'Pulse',
      'settings': 'Settings',
      'prayer_times': 'Prayer Times',
      'next_prayer': 'Next Prayer',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'app_settings': 'App Settings',
      'preferences': 'Preferences',
      'support': 'Support',
      'notifications': 'Notifications',
      'location': 'Location',
      'language': 'Language',
      'calculation_method': 'Calculation Method',
      'quran_font_size': 'Quran Font Size',
      'rate_us': 'Rate us',
      'about': 'About',
      'save': 'Save',
      'cancel': 'Cancel',
      'english': 'English',
      'arabic': 'Arabic',
      'farsi': 'Farsi',
      'urdu': 'Urdu',
      'turkish': 'Turkish',
      'greeting': 'Assalamualaikum',
      'essential_tools': 'Essential Tools',
      'see_all': 'See All',
      'daily_ayats': 'Daily Ayats',
      'swipe_for_more': 'Swipe for more',
      'prayer_in': 'In',
      'spiritual_insight': 'Spiritual Insight',
      'weekly_activity': 'Weekly Activity',
      'streak': 'Day Streak!',
      'milestone': 'Next milestone at',
      'no_data': 'No data available',
      'days': 'days',
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'retry': 'Retry',
      'loading_location': 'Loading location...',
      'current_location': 'Current Location',
      'logged_to_pulse': 'logged to Spiritual Pulse! ✨',
      'daily_duas': 'Daily Duas',
      'search_duas': 'Search duas...',
      'no_duas_found': 'No duas found',
      'names_of_allah': '99 Names of Allah',
      'tasbeeh': 'Tasbeeh Counter',
      'total_dhikr': 'Total Dhikr',
      'reset': 'Reset',
      'zakat_calculator': 'Zakat Calculator',
      'hajj_guide': 'Hajj & Umrah Guide',
      'islamic_calendar': 'Islamic Calendar',
      'qibla_finder': 'Qibla Finder',
      'mosque_finder': 'Mosque Finder',
      'search_names': 'Search names...',
      'no_names_found': 'No names found',
      'subhanallah': 'SubhanAllah',
      'tasbeeh_tap_hint': 'Tap the circle to count',
      'tasbeeh_dhikr_logged': 'Dhikr logged! ✨',
      'total_zakat_payable': 'Total Zakat Payable',
      'cash_in_hand': 'Cash in Hand/Bank',
      'gold_value': 'Value of Gold',
      'silver_value': 'Value of Silver',
      'investments_shares': 'Investments/Shares',
      'calculate_zakat': 'Calculate Zakat',
      'zakat_note':
          'Note: Zakat is 2.5% of your total wealth that exceeds the Nisab threshold for a full lunar year.',
      'enter_amount': 'Enter amount...',
      'hajj_step1_title': 'Ihram',
      'hajj_step1_desc': 'Put on the Ihram and make your Niyyah (intention).',
      'hajj_step2_title': 'Mina',
      'hajj_step2_desc': 'Stay in Mina on the 8th of Dhul-Hijjah.',
      'hajj_step3_title': 'Arafat',
      'hajj_step3_desc':
          'Stand in Arafat on the 9th of Dhul-Hijjah (The peak of Hajj).',
      'hajj_step4_title': 'Muzdalifah',
      'hajj_step4_desc': 'Collect pebbles and stay overnight.',
      'hajj_step5_title': 'Ramy al-Jamarat',
      'hajj_step5_desc':
          'Stoning the Jamarat (the pillars representing devil).',
      'hajj_step6_title': 'Qurbani',
      'hajj_step6_desc': 'Hady (sacrifice of an animal).',
      'hajj_step7_title': 'Halq or Taqsir',
      'hajj_step7_desc': 'Shaving or cutting of hair.',
      'hajj_step8_title': 'Tawaf al-Ifadah',
      'hajj_step8_desc': 'Circumambulation around the Kaaba.',
      'hajj_step9_title': 'Sai',
      'hajj_step9_desc': 'Walking between Safa and Marwa.',
      'hijri_date_label': 'Hijri Date',
      'upcoming_events': 'Upcoming Islamic Events',
      'moon_sighting_note':
          'Islamic dates depend on moon sightings and may vary by region.',
      'hajj_season': 'Hajj Season',
      'eid_ul_adha': 'Eid ul-Adha',
      'islamic_new_year': 'Islamic New Year',
      'ashura': 'Ashura',
      'ramadan_begins': 'Ramadan Begins',
      'eid_ul_fitr': 'Eid ul-Fitr',
      'qibla_direction': 'Qibla Direction',
      'qibla_hint': 'Point your phone towards the Kaaba',
      'search_mosques': 'Search for mosques...',
      'note': 'Note',
    },
    'ar': {
      'app_name': 'وقت البركة',
      'home': 'الرئيسية',
      'quran': 'القرآن',
      'pulse': 'النبض',
      'settings': 'الإعدادات',
      'prayer_times': 'أوقات الصلاة',
      'next_prayer': 'الصلاة القادمة',
      'profile': 'الملف الشخصي',
      'edit_profile': 'تعديل الملف',
      'app_settings': 'إعدادات التطبيق',
      'preferences': 'التفضيلات',
      'support': 'الدعم',
      'notifications': 'التنبيهات',
      'location': 'الموقع',
      'language': 'اللغة',
      'calculation_method': 'طريقة الحساب',
      'quran_font_size': 'حجم خط القرآن',
      'rate_us': 'قيمنا',
      'about': 'حول',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'farsi': 'الفارسية',
      'urdu': 'الأوردو',
      'turkish': 'التركية',
      'greeting': 'السلام عليكم',
      'essential_tools': 'الأدوات الأساسية',
      'see_all': 'عرض الكل',
      'daily_ayats': 'آيات يومية',
      'swipe_for_more': 'اسحب للمزيد',
      'prayer_in': 'في غضون',
      'spiritual_insight': 'رؤية روحانية',
      'weekly_activity': 'النشاط الأسبوعي',
      'streak': 'أيام متتالية!',
      'milestone': 'المرحلة التالية عند',
      'no_data': 'لا توجد بيانات متاحة',
      'days': 'أيام',
      'fajr': 'الفجر',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
      'retry': 'إعادة المحاولة',
      'loading_location': 'جاري تحميل الموقع...',
      'current_location': 'الموقع الحالي',
      'logged_to_pulse': 'تم تسجيله في النبض الروحاني! ✨',
      'daily_duas': 'أدعية يومية',
      'search_duas': 'البحث عن الأدعية...',
      'no_duas_found': 'لم يتم العثور على أدعية',
      'names_of_allah': '٩٩ أسماء الله الحسنى',
      'tasbeeh': 'مسبحة',
      'total_dhikr': 'إجمالي الذكر',
      'reset': 'إعادة ضبط',
      'zakat_calculator': 'حاسبة الزكاة',
      'hajj_guide': 'دليل الحج والعمرة',
      'islamic_calendar': 'التقويم الهجري',
      'qibla_finder': 'بوصلة القبلة',
      'mosque_finder': 'البحث عن مساجد',
      'search_names': 'البحث عن الأسماء...',
      'no_names_found': 'لم يتم العثور على أسماء',
      'subhanallah': 'سبحان الله',
      'tasbeeh_tap_hint': 'انقر على الدائرة للعد',
      'tasbeeh_dhikr_logged': 'تم تسجيل الذكر! ✨',
      'total_zakat_payable': 'إجمالي الزكاة المستحقة',
      'cash_in_hand': 'النقد في اليد/البنك',
      'gold_value': 'قيمة الذهب',
      'silver_value': 'قيمة الفضة',
      'investments_shares': 'الاستثمارات/الأسهم',
      'calculate_zakat': 'حساب الزكاة',
      'zakat_note':
          'ملاحظة: الزكاة هي 2.5% من إجمالي ثروتك التي تتجاوز حد النصاب لسنة قمرية كاملة.',
      'enter_amount': 'أدخل المبلغ...',
      'hajj_step1_title': 'الإحرام',
      'hajj_step1_desc': 'لبس الإحرام وعقد النية.',
      'hajj_step2_title': 'منى',
      'hajj_step2_desc': 'المبيت في منى في اليوم الثامن من ذي الحجة.',
      'hajj_step3_title': 'عرفة',
      'hajj_step3_desc':
          'الوقوف بعرفة في اليوم التاسع من ذي الحجة (ركن الحج الأعظم).',
      'hajj_step4_title': 'مزدلفة',
      'hajj_step4_desc': 'جمع الجمار والمبيت فيها.',
      'hajj_step5_title': 'رمي الجمرات',
      'hajj_step5_desc': 'رمي الجمرات التي تمثل الشيطان.',
      'hajj_step6_title': 'الهدي',
      'hajj_step6_desc': 'ذبح الهدي (الأضحية).',
      'hajj_step7_title': 'الحلق أو التقصير',
      'hajj_step7_desc': 'حلق الرأس أو قص الشعر.',
      'hajj_step8_title': 'طواف الإفاضة',
      'hajj_step8_desc': 'الطواف حول الكعبة المشرفة.',
      'hajj_step9_title': 'السعي',
      'hajj_step9_desc': 'السعي بين الصفا والمروة.',
      'hijri_date_label': 'التاريخ الهجري',
      'upcoming_events': 'الأحداث الإسلامية القادمة',
      'moon_sighting_note':
          'تعتمد التواريخ الإسلامية على رؤية الهلال وقد تختلف حسب المنطقة.',
      'hajj_season': 'موسم الحج',
      'eid_ul_adha': 'عيد الأضحى',
      'islamic_new_year': 'رأس السنة الهجرية',
      'ashura': 'عاشوراء',
      'ramadan_begins': 'بداية رمضان',
      'eid_ul_fitr': 'عيد الفطر',
      'qibla_direction': 'اتجاه القبلة',
      'qibla_hint': 'وجه هاتفك نحو الكعبة',
      'search_mosques': 'البحث عن مساجد...',
      'note': 'ملاحظة',
    },
    'fa': {
      'app_name': 'وقت برکت',
      'home': 'خانه',
      'quran': 'قرآن',
      'pulse': 'پالس',
      'settings': 'تنظیمات',
      'prayer_times': 'اوقات شرعی',
      'next_prayer': 'نماز بعدی',
      'profile': 'پروفایل',
      'edit_profile': 'ویرایش پروفایل',
      'app_settings': 'تنظیمات برنامه',
      'preferences': 'ترجیحات',
      'support': 'پشتیبانی',
      'notifications': 'اعلان‌ها',
      'location': 'مکان',
      'language': 'زبان',
      'calculation_method': 'روش محاسبه',
      'quran_font_size': 'اندازه خط قرآن',
      'rate_us': 'امتیاز به ما',
      'about': 'درباره',
      'save': 'ذخیره',
      'cancel': 'لغو',
      'english': 'انگلیسی',
      'arabic': 'عربی',
      'farsi': 'فارسی',
      'urdu': 'اردو',
      'turkish': 'ترکی',
      'greeting': 'سلام علیکم',
      'essential_tools': 'ابزارهای ضروری',
      'see_all': 'مشاهده همه',
      'daily_ayats': 'آیات روزانه',
      'swipe_for_more': 'برای بیشتر بکشید',
      'prayer_in': 'در',
      'spiritual_insight': 'بینش معنوی',
      'weekly_activity': 'فعالیت هفتگی',
      'streak': 'روز پیاپی!',
      'milestone': 'هدف بعدی در',
      'no_data': 'داده‌ای در دسترس نیست',
      'days': 'روز',
      'fajr': 'فجر',
      'dhuhr': 'ظهر',
      'asr': 'عصر',
      'maghrib': 'مغرب',
      'isha': 'عشاء',
      'retry': 'دوباره',
      'loading_location': 'در حال بارگذاری مکان...',
      'current_location': 'مکان فعلی',
      'logged_to_pulse': 'در پالس معنوی ثبت شد! ✨',
      'daily_duas': 'دعاهای روزانه',
      'search_duas': 'جستجوی دعا...',
      'no_duas_found': 'دعایی یافت نشد',
      'names_of_allah': '۹۹ نام‌های نیکوی خداوند',
      'tasbeeh': 'تسبیح شمار',
      'total_dhikr': 'مجموع ذکرها',
      'reset': 'بازنشانی',
      'zakat_calculator': 'محاسبه زکات',
      'hajj_guide': 'راهنمای حج و عمره',
      'islamic_calendar': 'تقویم اسلامی',
      'qibla_finder': 'قبله نما',
      'mosque_finder': 'مسجد یاب',
      'search_names': 'جستجوی نام‌ها...',
      'no_names_found': 'نامی یافت نشد',
      'subhanallah': 'سبحان الله',
      'tasbeeh_tap_hint': 'برای شمارش روی دایره ضربه بزنید',
      'tasbeeh_dhikr_logged': 'ذکر ثبت شد! ✨',
      'total_zakat_payable': 'کل زکات پرداختی',
      'cash_in_hand': 'نقد در دست/بانک',
      'gold_value': 'ارزش طلا',
      'silver_value': 'ارزش نقره',
      'investments_shares': 'سرمایه‌گذاری‌ها/سهام',
      'calculate_zakat': 'محاسبه زکات',
      'zakat_note':
          'توجه: زکات ۲.۵٪ از کل دارایی شماست که بیش از حد نصاب برای یک سال قمری کامل باشد.',
      'enter_amount': 'مبلغ را وارد کنید...',
      'hajj_step1_title': 'احرام',
      'hajj_step1_desc': 'پوشیدن لباس احرام و بستن نیت.',
      'hajj_step2_title': 'منا',
      'hajj_step2_desc': 'اقامت در منا در روز هشتم ذی‌الحجه.',
      'hajj_step3_title': 'عرفات',
      'hajj_step3_desc': 'وقوف در عرفات در روز نهم ذی‌الحجه (اوج مراسم حج).',
      'hajj_step4_title': 'مزدلفه',
      'hajj_step4_desc': 'جمع‌آوری سنگریزه و اقامت شبانه.',
      'hajj_step5_title': 'رمی جمرات',
      'hajj_step5_desc': 'پرتاب سنگ به جمرات (ستون‌های نماد شیطان).',
      'hajj_step6_title': 'قربانی',
      'hajj_step6_desc': 'ذبح قربانی.',
      'hajj_step7_title': 'حلق یا تقصیر',
      'hajj_step7_desc': 'تراشیدن یا کوتاه کردن مو.',
      'hajj_step8_title': 'طواف افاضه',
      'hajj_step8_desc': 'طواف به دور کعبه.',
      'hajj_step9_title': 'سعی',
      'hajj_step9_desc': 'سعی بین صفا و مروه.',
      'hijri_date_label': 'تاریخ هجری',
      'upcoming_events': 'رویدادهای اسلامی آینده',
      'moon_sighting_note':
          'تاریخ‌های اسلامی به رویت ماه بستگی دارد و ممکن است در مناطق مختلف متفاوت باشد.',
      'hajj_season': 'فصل حج',
      'eid_ul_adha': 'عید قربان',
      'islamic_new_year': 'سال نو اسلامی',
      'ashura': 'عاشورا',
      'ramadan_begins': 'آغاز رمضان',
      'eid_ul_fitr': 'عید فطر',
      'qibla_direction': 'جهت قبله',
      'qibla_hint': 'گوشی خود را به سمت کعبه بگیرید',
      'search_mosques': 'جستجوی مسجد...',
      'note': 'توجه',
    },
    'ur': {
      'app_name': 'برکت ٹائم',
      'home': 'ہوم',
      'quran': 'قرآن',
      'pulse': 'نبض',
      'settings': 'ترتیبات',
      'prayer_times': 'نماز کے اوقات',
      'next_prayer': 'اگلی نماز',
      'profile': 'پروفائل',
      'edit_profile': 'پروفائل تبدیل کریں',
      'app_settings': 'ایپ ترتیبات',
      'preferences': 'ترجیحات',
      'support': 'سپورٹ',
      'notifications': 'اطلاعات',
      'location': 'مقام',
      'language': 'زبان',
      'calculation_method': 'طریقہ کار',
      'quran_font_size': 'قرآن کا فونٹ سائز',
      'rate_us': 'ہماری درجہ بندی کریں',
      'about': 'ہمارے بارے میں',
      'save': 'محفوظ کریں',
      'cancel': 'منسوخ کریں',
      'english': 'انگریزی',
      'arabic': 'عربی',
      'farsi': 'فارسی',
      'urdu': 'اردو',
      'turkish': 'ترکی',
      'greeting': 'السلام علیکم',
      'essential_tools': 'ضروری اوزار',
      'see_all': 'سب دیکھیں',
      'daily_ayats': 'روزانہ آیات',
      'swipe_for_more': 'مزید کے لیے سوائپ کریں',
      'prayer_in': 'میں',
      'spiritual_insight': 'روحانی بصیرت',
      'weekly_activity': 'ہفتہ وار سرگرمی',
      'streak': 'دن کا سلسلہ!',
      'milestone': 'اگلا سنگ میل',
      'no_data': 'کوئی ڈیٹا دستیاب نہیں',
      'days': 'دن',
      'fajr': 'فجر',
      'dhuhr': 'ظہر',
      'asr': 'عصر',
      'maghrib': 'مغرب',
      'isha': 'عشاء',
      'retry': 'دوبارہ کوشش کریں',
      'loading_location': 'مقام لوڈ ہو رہا ہے...',
      'current_location': 'موجودہ مقام',
      'logged_to_pulse': 'روحانی نبض میں محفوظ کر لیا گیا! ✨',
      'daily_duas': 'روزانہ دعائیں',
      'search_duas': 'دعائیں تلاش کریں...',
      'no_duas_found': 'کوئی دعا نہیں ملی',
      'names_of_allah': 'اللہ کے ۹۹ نام',
      'tasbeeh': 'تسبیح کاؤنٹر',
      'total_dhikr': 'کل ذکر',
      'reset': 'دوبارہ ترتیب دیں',
      'zakat_calculator': 'زکوٰۃ کیلکولیٹر',
      'hajj_guide': 'حج اور عمرہ گائیڈ',
      'islamic_calendar': 'اسلامی کیلنڈر',
      'qibla_finder': 'قبلہ نما',
      'mosque_finder': 'مسجد تلاش کریں',
      'search_names': 'نام تلاش کریں...',
      'no_names_found': 'کوئی نام نہیں ملا',
      'subhanallah': 'سبحان اللہ',
      'tasbeeh_tap_hint': 'گنتی کے لیے دائرے پر ٹیپ کریں',
      'tasbeeh_dhikr_logged': 'ذکر محفوظ کر لیا گیا! ✨',
      'total_zakat_payable': 'کل واجب الادا زکوٰۃ',
      'cash_in_hand': 'نقدی ہاتھ میں/بینک',
      'gold_value': 'سونے کی مالیت',
      'silver_value': 'چاندی کی مالیت',
      'investments_shares': 'سرمایہ کاری/شیئرز',
      'calculate_zakat': 'زکوٰۃ کا حساب لگائیں',
      'zakat_note':
          'نوٹ: زکوٰۃ آپ کی کل دولت کا 2.5% ہے جو کہ پورے قمری سال کے لیے نصاب کی حد سے زیادہ ہو۔',
      'enter_amount': 'رقم درج کریں...',
      'hajj_step1_title': 'احرام',
      'hajj_step1_desc': 'احرام باندھیں اور نیت کریں۔',
      'hajj_step2_title': 'منیٰ',
      'hajj_step2_desc': '8 ذوالحجہ کو منیٰ میں قیام کریں۔',
      'hajj_step3_title': 'عرفات',
      'hajj_step3_desc': '9 ذوالحجہ کو میدان عرفات میں قیام (حج کا رکن اعظم)۔',
      'hajj_step4_title': 'مزدلفہ',
      'hajj_step4_desc': ' کنکریاں جمع کریں اور رات قیام کریں۔',
      'hajj_step5_title': 'رمی جمرات',
      'hajj_step5_desc': 'جمرات کو کنکریاں مارنا (شیطان کو کنکریاں مارنا)۔',
      'hajj_step6_title': 'قربانی',
      'hajj_step6_desc': 'جانور کی قربانی (ہدی)۔',
      'hajj_step7_title': 'حلق یا تقصیر',
      'hajj_step7_desc': 'سر منڈوانا یا بال کٹوانا کٹوانا۔',
      'hajj_step8_title': 'طواف افاضہ',
      'hajj_step8_desc': 'خانہ کعبہ کا طواف کرنا۔',
      'hajj_step9_title': 'سعی',
      'hajj_step9_desc': 'صفا اور مروہ کے درمیان سعی کرنا۔',
      'hijri_date_label': 'ہجری تاریخ',
      'upcoming_events': 'آنے والے اسلامی واقعات',
      'moon_sighting_note':
          'اسلامی تاریخوں کا انحصار چاند کی رویت پر ہے اور یہ مختلف علاقوں میں مختلف ہو سکتی ہیں۔',
      'hajj_season': 'حج کا سیزن',
      'eid_ul_adha': 'عید الاضحی',
      'islamic_new_year': 'اسلامی نیا سال',
      'ashura': 'عاشورہ',
      'ramadan_begins': 'رمضان کا آغاز',
      'eid_ul_fitr': 'عید الفطر',
      'qibla_direction': 'قبلہ کی سمت',
      'qibla_hint': 'اپنے فون کو کعبہ کی طرف کریں',
      'search_mosques': 'مسجد تلاش کریں...',
      'note': 'نوٹ',
    },
    'tr': {
      'app_name': 'Bereket Vakti',
      'home': 'Ana Sayfa',
      'quran': 'Kur\'an',
      'pulse': 'Nabız',
      'settings': 'Ayarlar',
      'prayer_times': 'Namaz Vakitleri',
      'next_prayer': 'Sıraaki Namaz',
      'profile': 'Profil',
      'edit_profile': 'Profili Düzenle',
      'app_settings': 'Uygulama Ayarları',
      'preferences': 'Tercihler',
      'support': 'Destek',
      'notifications': 'Bildirimler',
      'location': 'Konum',
      'language': 'Dil',
      'calculation_method': 'Hesaplama Yöntemi',
      'quran_font_size': 'Kur\'an Yazı Boyutu',
      'rate_us': 'Bizi Oylayın',
      'about': 'Hakkında',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'english': 'İngilizce',
      'arabic': 'Arapça',
      'farsi': 'Farsça',
      'urdu': 'Urduca',
      'turkish': 'Türkçe',
      'greeting': 'Selamun Aleyküm',
      'essential_tools': 'Temel Araçlar',
      'see_all': 'Hepsini Gör',
      'daily_ayats': 'Günlük Ayetler',
      'swipe_for_more': 'Daha fazlası için kaydırın',
      'prayer_in': 'İçinde',
      'spiritual_insight': 'Manevi Bilgi',
      'weekly_activity': 'Haftalık Aktivite',
      'streak': 'Günlük Seri!',
      'milestone': 'Bir sonraki hedef',
      'no_data': 'Veri bulunamadı',
      'days': 'gün',
      'fajr': 'İmsak',
      'dhuhr': 'Öğle',
      'asr': 'İkindi',
      'maghrib': 'Akşam',
      'isha': 'Yatsı',
      'retry': 'Tekrar Dene',
      'loading_location': 'Konum yükleniyor...',
      'current_location': 'Mevcut Konum',
      'logged_to_pulse': 'Manevi Nabız\'a kaydedildi! ✨',
      'daily_duas': 'Günlük Dualar',
      'search_duas': 'Dua ara...',
      'no_duas_found': 'Dua bulunamadı',
      'names_of_allah': 'Allah\'ın 99 İsmi',
      'tasbeeh': 'Tesbih Sayacı',
      'total_dhikr': 'Toplam Zikir',
      'reset': 'Sıfırla',
      'zakat_calculator': 'Zekat Hesaplayıcı',
      'hajj_guide': 'Hac ve Umre Rehberi',
      'islamic_calendar': 'İslami Takvim',
      'qibla_finder': 'Kıble Bulucu',
      'mosque_finder': 'Cami Bulucu',
      'search_names': 'İsim ara...',
      'no_names_found': 'İsim bulunamadı',
      'subhanallah': 'Süphanallah',
      'tasbeeh_tap_hint': 'Saymak için daireye dokunun',
      'tasbeeh_dhikr_logged': 'Zikir kaydedildi! ✨',
      'total_zakat_payable': 'Toplam Ödenecek Zekat',
      'cash_in_hand': 'Eldeki Nakit/Banka',
      'gold_value': 'Altın Değeri',
      'silver_value': 'Gümüş Değeri',
      'investments_shares': 'Yatırımlar/Hisseler',
      'calculate_zakat': 'Zekat Hesapla',
      'zakat_note':
          'Not: Zekat, tam bir kameri yıl boyunca nisap eşiğini aşan toplam servetinizin %2,5\'udur.',
      'enter_amount': 'Miktarı girin...',
      'hajj_step1_title': 'İhram',
      'hajj_step1_desc': 'İhram giyin ve niyet edin.',
      'hajj_step2_title': 'Mina',
      'hajj_step2_desc': 'Zilhicce\'nin 8. günü Mina\'da kalın.',
      'hajj_step3_title': 'Arafat',
      'hajj_step3_desc':
          'Zilhicce\'nin 9. günü Arafat\'ta vakfeye durun (Haccın zirvesi).',
      'hajj_step4_title': 'Müzdelife',
      'hajj_step4_desc': 'Taş toplayın ve gece burada kalın.',
      'hajj_step5_title': 'Şeytan Taşlama',
      'hajj_step5_desc': 'Cemerat\'ta taşlama yapın.',
      'hajj_step6_title': 'Kurban',
      'hajj_step6_desc': 'Hedy (kurban kesimi).',
      'hajj_step7_title': 'Tıraş veya Kısaltma',
      'hajj_step7_desc': 'Saçları kazıtma veya kısaltma.',
      'hajj_step8_title': 'Ziyaret Tavafı',
      'hajj_step8_desc': 'Kabe etrafında tavaf yapılması.',
      'hajj_step9_title': 'Sa\'y',
      'hajj_step9_desc': 'Safa ve Merve arasında yürüyüş.',
      'hijri_date_label': 'Hicri Tarih',
      'upcoming_events': 'Gelecek İslami Etkinlikler',
      'moon_sighting_note':
          'İslami tarihler ayın görülmesine bağlıdır ve bölgeye göre farklılık gösterebilir.',
      'hajj_season': 'Hac Mevsimi',
      'eid_ul_adha': 'Kurban Bayramı',
      'islamic_new_year': 'Hicri Yılbaşı',
      'ashura': 'Aşure Günü',
      'ramadan_begins': 'Ramazan Başlangıcı',
      'eid_ul_fitr': 'Ramazan Bayramı',
      'qibla_direction': 'Kıble Yönü',
      'qibla_hint': 'Telefonunuzu Kabe\'ye doğru tutun',
      'search_mosques': 'Cami ara...',
      'note': 'Not',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get app_name => translate('app_name');
  String get home => translate('home');
  String get quran => translate('quran');
  String get pulse => translate('pulse');
  String get settings => translate('settings');
  String get prayer_times => translate('prayer_times');
  String get next_prayer => translate('next_prayer');
  String get profile => translate('profile');
  String get edit_profile => translate('edit_profile');
  String get app_settings => translate('app_settings');
  String get preferences => translate('preferences');
  String get support => translate('support');
  String get notifications => translate('notifications');
  String get location => translate('location');
  String get language => translate('language');
  String get calculation_method => translate('calculation_method');
  String get quran_font_size => translate('quran_font_size');
  String get rate_us => translate('rate_us');
  String get about => translate('about');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get farsi => translate('farsi');
  String get urdu => translate('urdu');
  String get turkish => translate('turkish');
  String get greeting => translate('greeting');
  String get essential_tools => translate('essential_tools');
  String get see_all => translate('see_all');
  String get daily_ayats => translate('daily_ayats');
  String get swipe_for_more => translate('swipe_for_more');
  String get prayer_in => translate('prayer_in');
  String get spiritual_insight => translate('spiritual_insight');
  String get weekly_activity => translate('weekly_activity');
  String get streak => translate('streak');
  String get milestone => translate('milestone');
  String get no_data => translate('no_data');
  String get days => translate('days');
  String get fajr => translate('fajr');
  String get dhuhr => translate('dhuhr');
  String get asr => translate('asr');
  String get maghrib => translate('maghrib');
  String get isha => translate('isha');
  String get retry => translate('retry');
  String get loading_location => translate('loading_location');
  String get current_location => translate('current_location');
  String get logged_to_pulse => translate('logged_to_pulse');
  String get daily_duas => translate('daily_duas');
  String get search_duas => translate('search_duas');
  String get no_duas_found => translate('no_duas_found');
  String get names_of_allah => translate('names_of_allah');
  String get tasbeeh => translate('tasbeeh');
  String get total_dhikr => translate('total_dhikr');
  String get reset => translate('reset');
  String get zakat_calculator => translate('zakat_calculator');
  String get hajj_guide => translate('hajj_guide');
  String get islamic_calendar => translate('islamic_calendar');
  String get qibla_finder => translate('qibla_finder');
  String get mosque_finder => translate('mosque_finder');
  String get search_names => translate('search_names');
  String get no_names_found => translate('no_names_found');
  String get subhanallah => translate('subhanallah');
  String get tasbeeh_tap_hint => translate('tasbeeh_tap_hint');
  String get tasbeeh_dhikr_logged => translate('tasbeeh_dhikr_logged');
  String get total_zakat_payable => translate('total_zakat_payable');
  String get cash_in_hand => translate('cash_in_hand');
  String get gold_value => translate('gold_value');
  String get silver_value => translate('silver_value');
  String get investments_shares => translate('investments_shares');
  String get calculate_zakat => translate('calculate_zakat');
  String get zakat_note => translate('zakat_note');
  String get enter_amount => translate('enter_amount');
  String get hajj_step1_title => translate('hajj_step1_title');
  String get hajj_step1_desc => translate('hajj_step1_desc');
  String get hajj_step2_title => translate('hajj_step2_title');
  String get hajj_step2_desc => translate('hajj_step2_desc');
  String get hajj_step3_title => translate('hajj_step3_title');
  String get hajj_step3_desc => translate('hajj_step3_desc');
  String get hajj_step4_title => translate('hajj_step4_title');
  String get hajj_step4_desc => translate('hajj_step4_desc');
  String get hajj_step5_title => translate('hajj_step5_title');
  String get hajj_step5_desc => translate('hajj_step5_desc');
  String get hajj_step6_title => translate('hajj_step6_title');
  String get hajj_step6_desc => translate('hajj_step6_desc');
  String get hajj_step7_title => translate('hajj_step7_title');
  String get hajj_step7_desc => translate('hajj_step7_desc');
  String get hajj_step8_title => translate('hajj_step8_title');
  String get hajj_step8_desc => translate('hajj_step8_desc');
  String get hajj_step9_title => translate('hajj_step9_title');
  String get hajj_step9_desc => translate('hajj_step9_desc');
  String get hijri_date_label => translate('hijri_date_label');
  String get upcoming_events => translate('upcoming_events');
  String get moon_sighting_note => translate('moon_sighting_note');
  String get hajj_season => translate('hajj_season');
  String get eid_ul_adha => translate('eid_ul_adha');
  String get islamic_new_year => translate('islamic_new_year');
  String get ashura => translate('ashura');
  String get ramadan_begins => translate('ramadan_begins');
  String get eid_ul_fitr => translate('eid_ul_fitr');
  String get qibla_direction => translate('qibla_direction');
  String get qibla_hint => translate('qibla_hint');
  String get search_mosques => translate('search_mosques');
  String get note => translate('note');

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fa', 'ur', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
