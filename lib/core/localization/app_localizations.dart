import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'pulse_today': 'Today',
      'pulse_today_prayers': 'Today\'s prayers',
      'badge_locked': 'Locked',
      'audio_error_voice_missing':
          "This phone has no voice for this language. Install it in phone Settings → Text-to-speech.",
      'quran_translation_language': 'Translation language',
      'quran_translation_same_as_app': 'Same as app language',
      'quran_translation_audio_note':
          'Urdu, English, Farsi and Turkish translations are read aloud by a person.',
      'audio_error_play': 'Could not play audio. New recitations need internet the first time; ones you have heard before play offline.',
      'audio_error_speech': 'Speech playback failed',
      'name_too_long': 'Name must be 100 characters or fewer',
      'reminders_need_notifications':
          'Turn on prayer notifications in Settings first.',
      'ramadan_title': 'Ramadan',
      'ramadan_day_of': 'Day {day} of {len}',
      'ramadan_starts_in': 'Starts in {n} days',
      'ramadan_qadr_tonight':
          'Tonight may be Laylatul Qadr. Spend it in worship and dua.',
      'ramadan_moon_adjust': 'Moon sighting adjustment (days)',
      'ramadan_need_location':
          'Load prayer times to see sehri and iftar times.',
      'ramadan_sehri_ends_in': 'Sehri ends in',
      'ramadan_iftar_in': 'Iftar in',
      'ramadan_sehri_ends': 'Sehri ends',
      'ramadan_iftar': 'Iftar',
      'ramadan_reminders': 'Sehri & iftar reminders',
      'ramadan_reminders_desc':
          '30 minutes before sehri ends, and at iftar time',
      'ramadan_duas': 'Ramadan duas',
      'ramadan_sehri_niyyah': 'Intention for fasting (sehri)',
      'ramadan_sehri_niyyah_meaning':
          'I intend to keep tomorrow\'s fast of the month of Ramadan.',
      'ramadan_iftar_dua': 'Dua for iftar',
      'ramadan_iftar_dua_meaning':
          'O Allah, I fasted for You, I believe in You, I put my trust in You, and I break my fast with Your provision.',
      'ramadan_iftar_dua2': 'After breaking the fast',
      'ramadan_iftar_dua2_meaning':
          'The thirst is gone, the veins are moistened, and the reward is certain, if Allah wills. (Abu Dawud)',
      'ramadan_qadr_dua': 'Dua for Laylatul Qadr',
      'ramadan_qadr_dua_meaning':
          'O Allah, You are Most Forgiving and You love forgiveness, so forgive me. (Tirmidhi)',
      'ramadan_log': 'Fasting log',
      'ramadan_fasted': 'Fasted',
      'ramadan_missed': 'Missed',
      'ramadan_taraweeh': 'Taraweeh',
      'ramadan_log_hint':
          'Tap a day to mark your fast and Taraweeh. Stars mark the odd nights of the last ten.',
      'ramadan_qaza_fasts': '{n} fasts to make up (qaza)',
      'ramadan_day': 'Day',
      'ramadan_not_set': 'Clear',
      'ramadan_prayed_taraweeh': 'Prayed Taraweeh',
      'ramadan_prepare': 'Get ready: plan your Quran, duas and charity.',
      'ramadan_sehri_reminder_title': 'Sehri ends in 30 minutes',
      'ramadan_sehri_reminder_body':
          'Sehri ends at {time}. Don\'t forget your intention.',
      'ramadan_iftar_reminder_title': 'It\'s iftar time',
      'ramadan_iftar_reminder_body':
          'Break your fast and make dua. Duas at iftar are accepted.',
      'memorial_title': 'Esaal-e-Sawab',
      'memorial_tool_subtitle': 'For the departed',
      'memorial_sign_in':
          'Sign in to create or join an Esaal-e-Sawab page for a loved one.',
      'memorial_intro':
          'Create a page for a loved one who passed away and share it on WhatsApp. Family and friends can take paras to complete a khatam, recite dhikr toward shared goals, and add good deeds for them.',
      'memorial_create': 'Create a page',
      'memorial_join': 'Join with a code',
      'memorial_none':
          'No pages yet. Create one, or join with a code someone shared.',
      'memorial_you_created': 'Created by you',
      'memorial_joined': 'Joined',
      'memorial_code_invalid': 'Enter the 8-character code',
      'memorial_code': 'Code',
      'memorial_join_button': 'Join',
      'memorial_name_required': 'Enter a name',
      'memorial_name': 'Name of the deceased',
      'memorial_subtitle': 'Relation or note (optional)',
      'memorial_subtitle_hint': 'e.g. Father of Ahmed',
      'memorial_death_date': 'Date of passing',
      'memorial_optional': 'Optional',
      'memorial_show_dates': 'Show remembrance days',
      'memorial_show_dates_desc':
          '3rd day, 10th day, 40th day and yearly anniversary',
      'memorial_goals': 'Dhikr goals',
      'memorial_goal': 'Goal',
      'memorial_error_not_found': 'No page found with this code.',
      'memorial_error_para_taken':
          'Someone just took this para. Please pick another.',
      'memorial_error_generic':
          'Something went wrong. Check your internet and try again.',
      'memorial_deleted': 'This page has been deleted.',
      'memorial_remove_from_list': 'Remove from my list',
      'memorial_created_hint':
          'Page created. Share it with family and friends.',
      'memorial_share': 'Share',
      'memorial_share_text':
          'Please join the Esaal-e-Sawab for {name}. Read a para of the Quran or recite dhikr for them in the Barakah Time app.\n\nCode: {code}\n\nGet the app: {link}',
      'memorial_para': 'Para {n}',
      'memorial_take_para_confirm':
          'You will read this para for the deceased. Others will see that you took it.',
      'memorial_take_para': 'Take this para',
      'memorial_para_read_by': 'Para {n} was read by {name}',
      'memorial_para_taken_by': 'Para {n} is being read by {name}',
      'memorial_para_yours': 'You are reading this para',
      'memorial_mark_read': 'I have read it',
      'memorial_release_para': 'Give it back',
      'memorial_khatam_done':
          'Khatam completed. Alhamdulillah! A new khatam has started.',
      'memorial_para_done': 'JazakAllah khair. May Allah accept it.',
      'memorial_how_many': 'How many times?',
      'memorial_added': 'Added. JazakAllah khair.',
      'memorial_delete': 'Delete page',
      'memorial_delete_confirm':
          'This deletes the page for everyone, including all progress. It cannot be undone.',
      'memorial_add_deed': 'Add a good deed or dua',
      'memorial_deed_hint': 'e.g. Gave food to 10 people, or a dua for them',
      'memorial_dates': 'Remembrance days',
      'memorial_activity': 'Activity',
      'memorial_code_copied': 'Code copied',
      'memorial_invite': 'Invite',
      'memorial_khatam_n': 'Khatam {n}',
      'memorial_khatams_completed': '{n} khatams completed',
      'memorial_khatam_hint': 'Tap a free para to read it for the deceased.',
      'memorial_free': 'Free',
      'memorial_yours': 'Yours',
      'memorial_taken': 'Taken',
      'memorial_read': 'Read',
      'memorial_add_count': 'Add',
      'memorial_remind_me': 'Remind me on these days',
      'memorial_feed_para': '{name} read Para {n}',
      'memorial_feed_khatam': 'Khatam {n} completed. Alhamdulillah!',
      'memorial_feed_dhikr': '{name} recited {dhikr} × {count}',
      'memorial_feed_empty': 'Nothing yet. Be the first to contribute.',
      'memorial_day3': '3rd day (Soyem)',
      'memorial_day10': '10th day',
      'memorial_day40': '40th day (Chehlum)',
      'memorial_barsi': 'Yearly anniversary (Barsi)',
      'memorial_reminder_title': '{day} of {name}',
      'memorial_reminder_body':
          'Remember {name} today with Quran, dua or charity.',
      'dhikr_kareema': 'Ayat-e-Kareema',
      'dhikr_darood': 'Darood Shareef',
      'dhikr_kalma': 'Kalma Tayyiba',
      'dhikr_ikhlas': 'Surah Ikhlas',
      'dhikr_yaseen': 'Surah Yaseen',
      'dhikr_istighfar': 'Istighfar',
      'widget_empty': 'Open Barakah Time to load prayer times',
      'promise_title': 'Our promise',
      'promise_no_ads': 'No ads, ever',
      'promise_no_sell': 'We never sell or share your data',
      'promise_no_tracking': 'No trackers or analytics',
      'promise_location':
          'Your location is used only for prayer times, Qibla and nearby mosques',
      'onboarding_privacy_title': 'No ads. Your data stays yours.',
      'onboarding_privacy_desc':
          'Barakah Time has no ads and no trackers, and we never sell your data. Your worship stays between you and Allah.',
      'qaza_tracker': 'Qaza Tracker',
      'witr': 'Witr',
      'qaza_intro_title': 'Make up missed prayers',
      'qaza_intro_body':
          'Estimate how many prayers you owe, then count them down one by one. Your progress is saved and synced to your account.',
      'qaza_calculate': 'Estimate missed prayers',
      'qaza_enter_manually': 'Enter counts manually',
      'qaza_remaining': 'Remaining',
      'qaza_made_up': 'Made up',
      'qaza_progress': '{p}% made up',
      'qaza_pray_one': 'Prayed one qaza',
      'qaza_logged': 'One {prayer} qaza made up',
      'qaza_edit_title': 'Remaining {prayer}',
      'qaza_invalid': 'Enter a number from 0 to 60000',
      'qaza_years': 'Years',
      'qaza_months': 'Months',
      'qaza_days': 'Days',
      'qaza_include_witr': 'Include Witr (Hanafi)',
      'qaza_calc_desc':
          'How long did you miss prayers? For example, from puberty until you started praying regularly.',
      'qaza_calc_result': 'Adds {n} of each prayer',
      'qaza_estimate_note':
          'A year is counted as 365 days to stay on the safe side. Ask a scholar if you are unsure.',
      'qaza_add': 'Add to tracker',
      'qaza_reset': 'Reset tracker',
      'qaza_reset_confirm':
          'This clears all counts and progress. It cannot be undone.',
      'qaza_all_done': 'All qaza prayers made up. Alhamdulillah!',
      'qaza_tool_subtitle': 'Missed prayers',
      // Auth / onboarding / profile / settings / about pages
      'app_tagline': 'Bring barakah to your time',
      'onboarding_pulse_title': 'Spiritual Pulse',
      'onboarding_pulse_desc':
          'Track your spiritual consistency and build lasting habits. Stay connected, stay consistent.',
      'onboarding_prayer_title': 'Never Miss a Prayer',
      'onboarding_prayer_desc':
          'Accurate prayer times, live countdowns and reminders tailored to your location.',
      'onboarding_inspiration_title': 'Daily Inspiration',
      'onboarding_inspiration_desc':
          'Find peace with daily ayat, the 99 Names of Allah, duas and more for your soul.',
      'onboarding_next': 'Next',
      'onboarding_get_started': 'Get Started',
      'auth_welcome_back': 'Welcome Back',
      'auth_sign_in_subtitle': 'Sign in to continue your spiritual journey',
      'auth_email_address': 'Email Address',
      'auth_password': 'Password',
      'auth_sign_in': 'Sign In',
      'auth_or': 'or',
      'auth_no_account': 'Don\'t have an account?',
      'auth_sign_up': 'Sign Up',
      'auth_create_account': 'Create Account',
      'auth_sign_up_subtitle': 'Join our community and grow together',
      'auth_full_name': 'Full Name',
      'auth_register': 'Register',
      'auth_have_account': 'Already have an account?',
      'auth_account_created_verify':
          'Account created! We sent a verification link to {email}.',
      'profile_saved_verses': 'Saved verses',
      'profile_saved_count': '{n} saved',
      'profile_activity_history': 'Activity history',
      'profile_last_activity': 'Last: {activity}',
      'profile_no_saved_verses':
          'No saved verses yet. Tap the bookmark on any ayah to save it here.',
      'profile_remove_verse': 'Remove from saved',
      'profile_undo': 'Undo',
      'profile_change_photo': 'Change photo',
      'profile_take_photo': 'Take photo',
      'profile_choose_gallery': 'Choose from gallery',
      'profile_guest_title': 'Welcome',
      'profile_yesterday': 'Yesterday',
      'settings_account': 'Account',
      'settings_prayer': 'Prayer',
      'settings_support_us': 'Support our work',
      'settings_version': 'Version {v}',
      'about_title': 'About Barakah Time',
      'about_description':
          'An Islamic companion for prayer times, Quran, dhikr and daily spiritual growth — designed to bring barakah to your time.',
      'about_credits': 'Credits & data sources',
      'about_quran_data': 'Quran text, translations & audio',
      'about_map_data': 'Map & place data',
      'about_map_license':
          '© OpenStreetMap contributors, available under the Open Database License (ODbL)',
      'about_prayer_calc': 'Prayer time calculation',
      'about_prayer_calc_source': 'adhan library (open source)',
      'about_privacy': 'Privacy Policy',
      'about_terms': 'Terms of Service',
      'about_licenses': 'Open-source licenses',
      'about_made_with_love': 'Made with ❤️ for the Ummah',
      'about_link_failed': 'Couldn\'t open the link. Please try again later.',
      'search_surahs': 'Search by name or number',
      'continue_reading': 'Continue reading',
      'no_surahs_found': 'No surahs match your search',
      'meccan': 'Meccan',
      'medinan': 'Medinan',
      'verse_saved': 'Verse saved',
      'verse_removed': 'Verse removed from saved',
      'save_verse': 'Save verse',
      'remove_saved_verse': 'Remove from saved',
      'share_ayah_heading': 'Ayah {ayah} of Surah {surah}',
      'copy': 'Copy',
      'copied': 'Copied to clipboard',
      'meaning': 'Meaning',
      'transliteration': 'Transliteration',
      'name_number': 'Name {n} of 99',
      'alhamdulillah': 'Alhamdulillah',
      'allahu_akbar': 'Allahu Akbar',
      'astaghfirullah': 'Astaghfirullah',
      'la_ilaha_illallah': 'La ilaha illallah',
      'tasbeeh_target': 'Target',
      'tasbeeh_custom': 'Custom',
      'tasbeeh_custom_target': 'Custom target',
      'tasbeeh_round': 'Round {n}',
      'tasbeeh_total': 'Total: {n}',
      'tasbeeh_target_reached': 'Target reached!',
      'tasbeeh_counter_semantics': 'Counter: {count}. Tap to count.',
      'tasbeeh_target_invalid': 'Enter a number from 1 to 9999',
      'zakat_currency': 'Currency (optional)',
      'zakat_currency_hint': 'e.g. USD, PKR, TRY',
      'distance_m': '{n} m',
      'distance_km': '{n} km',
      'osm_attribution': '© OpenStreetMap contributors',
      'dua_before_sleeping': 'Before Sleeping',
      'dua_waking_up': 'Waking Up',
      'dua_before_eating': 'Before Eating',
      'dua_after_eating': 'After Eating',
      'dua_entering_home': 'Entering Home',
      'dua_leaving_home': 'Leaving Home',
      'dua_entering_mosque': 'Entering Mosque',
      'dua_leaving_mosque': 'Leaving Mosque',
      'dua_for_parents': 'For Parents',
      'dua_for_knowledge': 'For Knowledge',
      'dua_forgiveness': 'For Forgiveness (Istighfar)',
      'dua_entering_washroom': 'Entering Washroom',
      'dua_leaving_washroom': 'Leaving Washroom',
      'dua_before_wudu': 'Before Wudu',
      'dua_after_wudu': 'After Wudu',
      'dua_traveling': 'Traveling',
      'dua_morning_evening': 'Morning/Evening',
      'dua_protection': 'For Protection',
      'dua_ayatul_kursi': 'Ayatul Kursi (After Prayer)',
      'dua_mirror': 'Looking in Mirror',
      'dua_wearing_clothes': 'Wearing Clothes',
      'clear_search': 'Clear search',
      'confirm': 'Confirm',
      'continue_with_apple': 'Continue with Apple',
      'continue_with_google': 'Continue with Google',
      'dismiss': 'Dismiss',
      'hide_password': 'Hide password',
      'loading': 'Loading…',
      'show_password': 'Show password',
      'something_went_wrong': 'Something went wrong. Please try again.',
      'type_to_confirm': 'Type {text} to confirm',
      'all_tools': 'All Tools',
      'ayah': 'Ayah',
      'ayahs': 'Ayahs',
      'calibrate_compass':
          'If the direction seems wrong, move your phone in a figure-8 to calibrate the compass.',
      'compass_unavailable':
          'Compass not available on this device — face North, then turn to the angle shown.',
      'could_not_open_maps': 'Could not open maps',
      'degrees_from_north': '{deg}° from North',
      'detecting_location': 'Detecting location...',
      'directions': 'Directions',
      'facing_qibla': 'You are facing the Qibla',
      'finding_mosques': 'Finding nearby mosques...',
      'in_days': 'in {n} days',
      'listen_translation': 'Listen to translation',
      'location_error_message':
          'Couldn\'t get your location. Enable location services and permission, then try again.',
      'mark_as_read': 'Mark as Read',
      'mosques_load_error':
          'Couldn\'t load nearby mosques. Check your internet connection.',
      'no_mosques_match': 'No mosques match your search',
      'no_mosques_nearby': 'No mosques found within 5 km',
      'now_playing': 'Now playing',
      'open_in_maps': 'Open in Maps',
      'pause': 'Pause',
      'play': 'Play',
      'play_surah': 'Play Surah',
      'quran_load_error':
          'Couldn\'t load the Quran. Check your internet connection and try again.',
      'reset_counter_message':
          'The counter will go back to 0. Your dhikr so far will be saved to Spiritual Pulse.',
      'reset_counter_title': 'Reset counter?',
      'share': 'Share',
      'stop': 'Stop',
      'surah_already_logged_today': 'Already logged today ✓',
      'surah_load_error':
          'Couldn\'t load this surah. Check your internet connection and try again.',
      'surah_logged': 'Surah {name} logged! ✨',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'translation': 'Translation',
      'unnamed_mosque': 'Mosque',
      'zakat_above_nisab': 'Above nisab ({nisab}) — zakat is due',
      'zakat_below_nisab': 'Below nisab ({nisab}) — no zakat due',
      'zakat_gold_nisab': 'Gold (87.48 g)',
      'zakat_gold_price': 'Current gold price per gram',
      'zakat_invalid_amount': 'Enter a valid positive number',
      'zakat_liabilities': 'Debts / liabilities due',
      'zakat_net_wealth': 'Net zakatable wealth',
      'zakat_nisab_standard': 'Nisab standard',
      'zakat_nisab_unknown': 'Enter the metal price below to check the nisab',
      'zakat_no_wealth': 'No zakatable wealth after debts — no zakat due',
      'zakat_silver_nisab': 'Silver (612.36 g)',
      'zakat_silver_price': 'Current silver price per gram',
      'mawlid': 'Mawlid an-Nabi',
      'isra_miraj': 'Isra\' and Mi\'raj',
      'shab_e_barat': 'Mid-Sha\'ban (Shab-e-Barat)',
      'laylat_al_qadr': 'Laylat al-Qadr (27th night)',
      'day_of_arafah': 'Day of Arafah',
      'name_required': 'Please enter your name.',
      'email_required': 'Please enter your email.',
      'invalid_email': 'Please enter a valid email address.',
      'password_required': 'Please enter your password.',
      'password_too_short': 'Password must be at least 6 characters.',
      'passwords_do_not_match': 'Passwords do not match.',
      'confirm_password': 'Confirm Password',
      'err_user_not_found': 'No account found with this email.',
      'err_wrong_credentials': 'Incorrect email or password.',
      'err_email_in_use': 'An account with this email already exists.',
      'err_network': 'Network error. Check your connection.',
      'err_too_many_requests': 'Too many attempts. Try again later.',
      'err_recent_login':
          'For security, please sign out and sign in again before changing your email.',
      'err_upload_failed': 'Failed to upload photo. Please try again.',
      'err_profile_update_failed':
          'Failed to update profile. Please try again.',
      'err_google_failed': 'Google Sign-In failed. Please try again.',
      'profile_updated': 'Profile updated.',
      'photo_updated': 'Profile photo updated.',
      'verification_email_sent':
          'A verification link was sent to your new email. Your email will update once you confirm it.',
      'forgot_password': 'Forgot Password?',
      'reset_password': 'Reset Password',
      'reset_password_hint':
          'Enter your email and we\'ll send you a link to reset your password.',
      'send_link': 'Send Link',
      'reset_email_sent': 'Password reset email sent. Check your inbox.',
      'email': 'Email',
      'name': 'Name',
      'photo_permission_denied':
          'Photo access denied. Please allow access in your device settings.',
      'photo_pick_failed': 'Could not open your photos. Please try again.',
      'member_since': 'Member since',
      'my_profile': 'My Profile',
      'points': 'Points',
      'badges': 'Badges',
      'sign_out': 'Sign Out',
      'sign_out_confirm': 'Are you sure you want to sign out?',
      'notifications_subtitle': 'Adhan, reminders & alerts',
      'location_settings': 'Location Settings',
      'auto_location': 'Auto Location (GPS)',
      'manual_location': 'Manual Location',
      'location_required': 'Please enter a city.',
      'rate_now': 'Rate Now',
      'later': 'Later',
      'rate_us_message':
          'If you enjoy Barakah Time, please take a moment to rate us! ✨',
      'app_store_coming_soon':
          'Barakah Time is coming soon to the App Store. Thank you for your support!',
      'store_open_failed': 'Couldn\'t open the store. Please try again later.',
      'close': 'Close',
      'skip': 'Skip',
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
      'asr_calculation': 'Asr Calculation',
      'asr_shafi': 'Standard (Shafi\'i, Maliki, Hanbali)',
      'asr_hanafi': 'Hanafi',
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
      'sunrise': 'Sunrise',
      'tomorrow_fajr': 'Tomorrow\'s Fajr',
      'location_not_found':
          'Couldn\'t find "{city}". Try a different spelling or add the country.',
      'location_services_disabled': 'Location services are turned off',
      'location_permission_denied':
          'Location permission is needed to show prayer times for where you are.',
      'location_permission_denied_forever':
          'Location permission is blocked. Enable it in app settings, or set a city manually.',
      'location_timeout': 'Couldn\'t get your location in time.',
      'location_access_required': 'Location Access Required',
      'open_settings': 'Open Settings',
      'grant_access_retry': 'Grant Access & Retry',
      'set_manual_location_hint': 'Or set a city manually in Settings.',
      'locating': 'Locating...',
      'location_unavailable': 'Location unavailable',
      'prayer_not_started': '{prayer} time hasn\'t started yet.',
      'prayer_already_logged': '{prayer} is already logged today.',
      'prayer_notification_title': 'Time for {prayer}',
      'prayer_notification_body': 'It\'s time to pray {prayer}.',
      'pulse_load_failed': 'Couldn\'t load your spiritual pulse.',
      'names_99_short': '99 Names',
      'duas_short': 'Duas',
      'tasbeeh_short': 'Tasbeeh',
      'badge_first_step': 'First Step',
      'badge_first_step_desc': 'Logged your first activity',
      'badge_streak_7': '7 Day Streak',
      'badge_streak_7_desc': 'Active 7 days in a row',
      'badge_streak_30': 'Monthly Master',
      'badge_streak_30_desc': 'Active 30 days in a row',
      'badge_streak_100': 'Steadfast',
      'badge_streak_100_desc': 'Active 100 days in a row',
      'badge_daily_achiever': 'Daily Achiever',
      'badge_daily_achiever_desc': 'Reached 100 points in one day',
      'badge_spiritual_veteran': 'Spiritual Veteran',
      'badge_spiritual_veteran_desc': 'Logged 50 activities',
      'badge_points_1000': '1,000 Points',
      'badge_points_1000_desc': 'Earned 1,000 lifetime points',
      'no_badges_yet': 'Keep using the app to earn badges!',
      'badges_earned': '{n} badges earned',
      'motivation_achieved':
          'MashaAllah! You\'ve achieved your spiritual goals for today. ✨',
      'motivation_almost':
          'Great progress! Just a little more to hit your target. 🚀',
      'motivation_halfway': 'You\'re halfway through! Keep up the momentum. 💪',
      'motivation_started': 'Good start! Keep moving towards your goals. ⚡',
      'motivation_start':
          'Start your spiritual journey for today. Every step counts! 🌱',
      'method_mwl': 'Muslim World League',
      'method_karachi': 'University of Islamic Sciences, Karachi',
      'method_isna': 'Islamic Society of North America (ISNA)',
      'method_umm_al_qura': 'Umm al-Qura University, Makkah',
      'method_egyptian': 'Egyptian General Authority of Survey',
      'method_dubai': 'Dubai (UAE)',
      'method_qatar': 'Qatar',
      'method_kuwait': 'Kuwait',
      'method_turkey': 'Diyanet (Turkey)',
      'method_tehran': 'Institute of Geophysics, University of Tehran',
      'method_singapore': 'Singapore, Malaysia & Indonesia',
      'method_moonsighting': 'Moonsighting Committee Worldwide',
      'unknown_city': 'Unknown location',
      'daily_challenges': 'Today\'s challenges',
      'challenges_hint': 'They complete themselves as you use the app',
      'challenge_prayers': 'Pray all five prayers',
      'challenge_quran': 'Read from the Quran',
      'challenge_dhikr': 'Do 33 dhikr on the Tasbeeh',
      'challenges_all_done': 'MashaAllah! All of today\'s challenges are done',
      'perfect_days_week': 'Perfect days this week: {n}/7',
      'quran_font': 'Quran font',
      'quran_font_note': 'Each font downloads once, the first time you use it.',
      'night_rec_title': 'Before you sleep',
      'night_rec_subtitle': 'From the Sunnah of the Prophet ﷺ',
      'friday_rec_title': 'Jummah Mubarak',
      'friday_rec_subtitle': 'Read Surah Al-Kahf on Friday',
      'rec_ayat_kursi': 'Ayat al-Kursi',
      'rec_baqarah_end': 'Last two ayahs of Al-Baqarah',
      'rec_mulk': 'Surah Al-Mulk',
      'rec_quls': 'The four Quls',
      'rec_waqiah': 'Surah Al-Waqiah',
      'rec_muzzammil': 'Surah Al-Muzzammil',
      'rec_kahf': 'Surah Al-Kahf',
      'rec_also_common': 'Also commonly read',
      'mark_done': 'Mark as done',
      'mark_not_done': 'Mark as not done',
      'night_reminder': 'Night recitations reminder',
      'night_reminder_desc': 'An hour after Isha',
      'kahf_reminder': 'Surah Al-Kahf on Friday',
      'kahf_reminder_desc': 'Friday morning',
      'night_reminder_title': 'Before you sleep 🌙',
      'night_reminder_body': 'Ayat al-Kursi, Surah Al-Mulk and the Quls',
      'kahf_reminder_title': 'Jummah Mubarak',
      'kahf_reminder_body': 'Remember to read Surah Al-Kahf today',
      'playback_speed': 'Playback speed',
      'mushaf': 'Mushaf',
      'page_n': 'Page {n}',
      'juz_n': 'Juz {n}',
      'mushaf_tap_hint': 'Tap an ayah to see its translation, play or save it',
      'play_from_here': 'Play from here',
      'send_feedback': 'Send feedback',
      'send_feedback_desc': 'Report a problem or suggest an idea',
      'feedback_no_email_app': 'No email app found. Write to us at {email}',
      'adhan_help': 'Adhan late or not coming?',
      'adhan_help_desc': 'Phone settings that can block reminders',
      'adhan_help_body': 'Some phones (for example Vivo, Oppo, Xiaomi, Infinix and Samsung) stop apps in the background to save battery, which can delay or block the adhan.\n\n1. Open app settings below.\n2. Battery: choose "Unrestricted" or "No restrictions".\n3. If your phone has "Autostart" or "Background activity", turn it on for Barakah Time.\n4. Make sure notifications are allowed.\n\nAfter that, open Barakah Time once so it can set the reminders again.',
      'refresh_location': 'Update location',
      'location_updated': 'Location updated',
      'default_user_name': 'Barakah User',
      'sign_in_with_apple': 'Sign in with Apple',
      'continue_as_guest': 'Not now',
      'guest_mode_notice':
          'Everything works without an account. Sign in only if you want to back up your progress and use it on other devices.',
      'sign_in_to_sync': 'Sign in to sync',
      'auth_unavailable_notice':
          'Sign-in is unavailable right now. You can keep using the app; your data stays on this device.',
      'err_auth_unavailable':
          'Sign-in is unavailable right now. Check your connection and restart the app.',
      'err_apple_failed': 'Sign in with Apple failed. Please try again.',
      'err_user_disabled': 'This account has been disabled.',
      'err_account_exists_different_provider':
          'An account already exists with this email using a different sign-in method.',
      'err_user_mismatch':
          'Please sign in with the same account you are deleting.',
      'session_expired': 'You have been signed out. Please sign in again.',
      'email_not_verified':
          'Your email is not verified yet. Check your inbox for the verification link.',
      'resend_verification': 'Resend verification email',
      'verification_link_resent': 'Verification email sent. Check your inbox.',
      'delete_account': 'Delete account',
      'delete_confirm_word': 'DELETE',
      'delete_account_confirm_title': 'Delete your account?',
      'delete_account_confirm_message':
          'This permanently deletes your account, progress, badges, saved verses and profile photo. This cannot be undone.',
      'reauth_required_delete':
          'For security, please confirm your sign-in to delete your account.',
      'confirm_with_password': 'Enter your password to continue',
      'confirm_with_provider': 'Confirm with {provider}',
      'account_deleted': 'Your account has been deleted.',
      'err_delete_account_failed':
          'Could not delete your account. Please try again.',
      'lifetime_points': 'Lifetime points',
      'longest_streak': 'Longest streak',
      'adhan_sound': 'Adhan sound',
      'adhan_sound_desc': 'Play the adhan for prayer reminders',
      'adjust_times': 'Adjust prayer times',
      'app_theme': 'Theme',
      'theme_system': 'System default',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'adjust_times_desc': 'Shift each prayer to match your mosque',
      'adjust_times_none': 'No changes',
      'minutes_short': '{n} min',
      'adjust_times_note':
          'Times are shifted from the calculated time. Use this only if your local mosque differs.',
      'exact_alarms_hint':
          'Allow "Alarms & reminders" so prayer reminders arrive exactly on time.',
      'notifications_permission_revoked':
          'Notification permission was turned off in system settings, so prayer reminders were disabled.',
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'assalamualaikum': 'Assalamualaikum',
      'hijri_year_suffix': 'AH',
      'hijri_month_1': 'Muharram',
      'hijri_month_2': 'Safar',
      'hijri_month_3': 'Rabi al-Awwal',
      'hijri_month_4': 'Rabi al-Thani',
      'hijri_month_5': 'Jumada al-Ula',
      'hijri_month_6': 'Jumada al-Akhirah',
      'hijri_month_7': 'Rajab',
      'hijri_month_8': 'Sha\'ban',
      'hijri_month_9': 'Ramadan',
      'hijri_month_10': 'Shawwal',
      'hijri_month_11': 'Dhu al-Qi\'dah',
      'hijri_month_12': 'Dhu al-Hijjah',
      'qibla_short': 'Qibla',
      'calendar_short': 'Calendar',
      'more': 'More',
      'read_full_ayah': 'Read full ayah',
      'shared_from_app': 'Shared from Barakah Time',
      'pulse_share_text':
          'My Barakah Time progress: {streak}-day streak and {points} points this week.',
      'points_this_week': 'Points this week',
      'current_streak': 'Current streak',
      'day_streak_count': '{n}-day streak',
      'weekday_points': '{day}: {n} points',
      'recent_activity': 'Recent activity',
      'no_recent_activity':
          'No activity yet. Log a prayer, read the Quran or do dhikr to get started.',
      'activity_prayer': '{prayer} prayer',
      'activity_quran': 'Quran reading',
      'activity_dhikr': 'Dhikr',
      'activity_other': 'Activity',
      'points_gained': '+{n} points',
      'prayer_logged_semantics': '{prayer} logged',
      'log_prayer_semantics': 'Log {prayer}',
      'prayer_in_label': '{prayer} in',
      'cardinal_n': 'N',
      'cardinal_e': 'E',
      'cardinal_s': 'S',
      'cardinal_w': 'W',
      'qibla_semantics_right': 'Qibla is {deg}° to your right',
      'qibla_semantics_left': 'Qibla is {deg}° to your left',
      'qibla_semantics_ahead': 'Qibla is straight ahead',
      'qibla_compass': 'Qibla compass',
      'logged': 'Logged',
    },
    'ar': {
      'pulse_today': 'اليوم',
      'pulse_today_prayers': 'صلوات اليوم',
      'badge_locked': 'مقفل',
      'audio_error_voice_missing':
          "لا يوجد صوت لهذه اللغة على الهاتف. ثبّته من الإعدادات ← تحويل النص إلى كلام.",
      'quran_translation_language': 'لغة الترجمة',
      'quran_translation_same_as_app': 'نفس لغة التطبيق',
      'quran_translation_audio_note':
          'تُقرأ الترجمات الأردية والإنجليزية والفارسية والتركية بصوت قارئ بشري.',
      'audio_error_play': 'تعذّر تشغيل الصوت. تحتاج التلاوات الجديدة إلى الإنترنت في المرة الأولى، أما ما استمعت إليه من قبل فيعمل دون اتصال.',
      'audio_error_speech': 'تعذّر تشغيل القراءة الصوتية',
      'name_too_long': 'يجب ألا يتجاوز الاسم 100 حرف',
      'reminders_need_notifications': 'فعّل إشعارات الصلاة من الإعدادات أولًا.',
      'ramadan_title': 'رمضان',
      'ramadan_day_of': 'اليوم {day} من {len}',
      'ramadan_starts_in': 'يبدأ بعد {n} يومًا',
      'ramadan_qadr_tonight':
          'قد تكون الليلة ليلة القدر. اغتنمها بالعبادة والدعاء.',
      'ramadan_moon_adjust': 'تعديل رؤية الهلال (أيام)',
      'ramadan_need_location': 'حمّل مواقيت الصلاة لرؤية وقتي السحور والإفطار.',
      'ramadan_sehri_ends_in': 'ينتهي السحور بعد',
      'ramadan_iftar_in': 'الإفطار بعد',
      'ramadan_sehri_ends': 'نهاية السحور',
      'ramadan_iftar': 'الإفطار',
      'ramadan_reminders': 'تذكير السحور والإفطار',
      'ramadan_reminders_desc': 'قبل نهاية السحور بـ30 دقيقة، وعند الإفطار',
      'ramadan_duas': 'أدعية رمضان',
      'ramadan_sehri_niyyah': 'نية الصيام (السحور)',
      'ramadan_sehri_niyyah_meaning': 'نويت صيام غدٍ من شهر رمضان.',
      'ramadan_iftar_dua': 'دعاء الإفطار',
      'ramadan_iftar_dua_meaning':
          'اللهم لك صمت، وبك آمنت، وعليك توكلت، وعلى رزقك أفطرت.',
      'ramadan_iftar_dua2': 'بعد الإفطار',
      'ramadan_iftar_dua2_meaning':
          'ذهب الظمأ وابتلت العروق وثبت الأجر إن شاء الله. (أبو داود)',
      'ramadan_qadr_dua': 'دعاء ليلة القدر',
      'ramadan_qadr_dua_meaning': 'اللهم إنك عفو تحب العفو فاعف عني. (الترمذي)',
      'ramadan_log': 'سجل الصيام',
      'ramadan_fasted': 'صمت',
      'ramadan_missed': 'فاتني',
      'ramadan_taraweeh': 'التراويح',
      'ramadan_log_hint':
          'اضغط على اليوم لتسجيل الصيام والتراويح. النجوم تشير إلى الليالي الوتر من العشر الأواخر.',
      'ramadan_qaza_fasts': '{n} أيام للقضاء',
      'ramadan_day': 'اليوم',
      'ramadan_not_set': 'مسح',
      'ramadan_prayed_taraweeh': 'صليت التراويح',
      'ramadan_prepare': 'استعد: خطط لقراءة القرآن والدعاء والصدقة.',
      'ramadan_sehri_reminder_title': 'ينتهي السحور بعد 30 دقيقة',
      'ramadan_sehri_reminder_body':
          'ينتهي السحور الساعة {time}. لا تنسَ النية.',
      'ramadan_iftar_reminder_title': 'حان وقت الإفطار',
      'ramadan_iftar_reminder_body':
          'أفطر وادعُ، فللصائم عند فطره دعوة لا ترد.',
      'memorial_title': 'إيصال الثواب',
      'memorial_tool_subtitle': 'للأموات',
      'memorial_sign_in':
          'سجّل الدخول لإنشاء صفحة إيصال ثواب لعزيز أو الانضمام إليها.',
      'memorial_intro':
          'أنشئ صفحة لعزيز توفي وشاركها عبر واتساب. يمكن للأهل والأصدقاء أخذ أجزاء لإتمام ختمة، وقراءة الأذكار نحو أهداف مشتركة، وإضافة أعمال صالحة له.',
      'memorial_create': 'إنشاء صفحة',
      'memorial_join': 'الانضمام برمز',
      'memorial_none': 'لا توجد صفحات بعد. أنشئ صفحة أو انضم برمز أرسله أحدهم.',
      'memorial_you_created': 'أنشأتها أنت',
      'memorial_joined': 'منضم',
      'memorial_code_invalid': 'أدخل الرمز المكوّن من 8 أحرف',
      'memorial_code': 'الرمز',
      'memorial_join_button': 'انضمام',
      'memorial_name_required': 'أدخل الاسم',
      'memorial_name': 'اسم المتوفى',
      'memorial_subtitle': 'صلة القرابة أو ملاحظة (اختياري)',
      'memorial_subtitle_hint': 'مثلًا: والد أحمد',
      'memorial_death_date': 'تاريخ الوفاة',
      'memorial_optional': 'اختياري',
      'memorial_show_dates': 'عرض أيام الذكرى',
      'memorial_show_dates_desc':
          'اليوم الثالث والعاشر والأربعون والذكرى السنوية',
      'memorial_goals': 'أهداف الذكر',
      'memorial_goal': 'الهدف',
      'memorial_error_not_found': 'لا توجد صفحة بهذا الرمز.',
      'memorial_error_para_taken': 'أخذ أحدهم هذا الجزء للتو. اختر جزءًا آخر.',
      'memorial_error_generic': 'حدث خطأ. تحقق من الإنترنت وحاول مجددًا.',
      'memorial_deleted': 'تم حذف هذه الصفحة.',
      'memorial_remove_from_list': 'إزالة من قائمتي',
      'memorial_created_hint': 'تم إنشاء الصفحة. شاركها مع الأهل والأصدقاء.',
      'memorial_share': 'مشاركة',
      'memorial_share_text':
          'شارك في إيصال الثواب إلى {name}. اقرأ جزءًا من القرآن أو اذكر الله له في تطبيق Barakah Time.\n\nالرمز: {code}\n\nحمّل التطبيق: {link}',
      'memorial_para': 'الجزء {n}',
      'memorial_take_para_confirm':
          'ستقرأ هذا الجزء للمتوفى، وسيرى الآخرون أنك أخذته.',
      'memorial_take_para': 'خذ هذا الجزء',
      'memorial_para_read_by': 'قرأ {name} الجزء {n}',
      'memorial_para_taken_by': 'يقرأ {name} الجزء {n}',
      'memorial_para_yours': 'أنت تقرأ هذا الجزء',
      'memorial_mark_read': 'قرأته',
      'memorial_release_para': 'إرجاعه',
      'memorial_khatam_done': 'اكتملت الختمة. الحمد لله! بدأت ختمة جديدة.',
      'memorial_para_done': 'جزاك الله خيرًا. تقبل الله.',
      'memorial_how_many': 'كم مرة؟',
      'memorial_added': 'تمت الإضافة. جزاك الله خيرًا.',
      'memorial_delete': 'حذف الصفحة',
      'memorial_delete_confirm':
          'سيتم حذف الصفحة للجميع مع كل التقدم. لا يمكن التراجع.',
      'memorial_add_deed': 'أضف عملًا صالحًا أو دعاء',
      'memorial_deed_hint': 'مثلًا: أطعمت 10 أشخاص، أو دعاء له',
      'memorial_dates': 'أيام الذكرى',
      'memorial_activity': 'النشاط',
      'memorial_code_copied': 'تم نسخ الرمز',
      'memorial_invite': 'دعوة',
      'memorial_khatam_n': 'الختمة {n}',
      'memorial_khatams_completed': 'اكتملت {n} ختمات',
      'memorial_khatam_hint': 'اضغط على جزء متاح لتقرأه للمتوفى.',
      'memorial_free': 'متاح',
      'memorial_yours': 'لك',
      'memorial_taken': 'مأخوذ',
      'memorial_read': 'مقروء',
      'memorial_add_count': 'إضافة',
      'memorial_remind_me': 'ذكّرني في هذه الأيام',
      'memorial_feed_para': 'قرأ {name} الجزء {n}',
      'memorial_feed_khatam': 'اكتملت الختمة {n}. الحمد لله!',
      'memorial_feed_dhikr': 'قرأ {name} {dhikr} × {count}',
      'memorial_feed_empty': 'لا شيء بعد. كن أول من يشارك.',
      'memorial_day3': 'اليوم الثالث',
      'memorial_day10': 'اليوم العاشر',
      'memorial_day40': 'اليوم الأربعون',
      'memorial_barsi': 'الذكرى السنوية',
      'memorial_reminder_title': '{day} لـ {name}',
      'memorial_reminder_body':
          'اذكر {name} اليوم بالقرآن أو الدعاء أو الصدقة.',
      'dhikr_kareema': 'الآية الكريمة',
      'dhikr_darood': 'الصلاة على النبي ﷺ',
      'dhikr_kalma': 'كلمة التوحيد',
      'dhikr_ikhlas': 'سورة الإخلاص',
      'dhikr_yaseen': 'سورة يس',
      'dhikr_istighfar': 'الاستغفار',
      'widget_empty': 'افتح Barakah Time لتحميل مواقيت الصلاة',
      'promise_title': 'وعدنا',
      'promise_no_ads': 'بلا إعلانات أبدًا',
      'promise_no_sell': 'لا نبيع بياناتك ولا نشاركها أبدًا',
      'promise_no_tracking': 'بلا أدوات تتبع أو تحليلات',
      'promise_location':
          'يُستخدم موقعك فقط لمواقيت الصلاة والقبلة والمساجد القريبة',
      'onboarding_privacy_title': 'بلا إعلانات. بياناتك ملكك.',
      'onboarding_privacy_desc':
          'لا يحتوي Barakah Time على إعلانات أو أدوات تتبع، ولا نبيع بياناتك أبدًا. عبادتك بينك وبين الله.',
      'qaza_tracker': 'متتبع القضاء',
      'witr': 'الوتر',
      'qaza_intro_title': 'اقضِ الصلوات الفائتة',
      'qaza_intro_body':
          'قدّر عدد الصلوات التي فاتتك، ثم اقضها واحدة تلو الأخرى. يُحفظ تقدمك ويُزامن مع حسابك.',
      'qaza_calculate': 'تقدير الصلوات الفائتة',
      'qaza_enter_manually': 'إدخال الأعداد يدويًا',
      'qaza_remaining': 'المتبقي',
      'qaza_made_up': 'تم قضاؤه',
      'qaza_progress': 'تم قضاء {p}%',
      'qaza_pray_one': 'قضيت صلاة',
      'qaza_logged': 'تم قضاء صلاة {prayer} واحدة',
      'qaza_edit_title': 'المتبقي من {prayer}',
      'qaza_invalid': 'أدخل رقمًا من 0 إلى 60000',
      'qaza_years': 'سنوات',
      'qaza_months': 'أشهر',
      'qaza_days': 'أيام',
      'qaza_include_witr': 'تضمين الوتر (الحنفي)',
      'qaza_calc_desc':
          'كم من الوقت فاتتك الصلوات؟ مثلًا من البلوغ حتى بدأت المحافظة على الصلاة.',
      'qaza_calc_result': 'يضيف {n} من كل صلاة',
      'qaza_estimate_note':
          'تُحسب السنة 365 يومًا احتياطًا. اسأل عالمًا إن لم تكن متأكدًا.',
      'qaza_add': 'إضافة إلى المتتبع',
      'qaza_reset': 'إعادة تعيين المتتبع',
      'qaza_reset_confirm':
          'سيؤدي هذا إلى مسح جميع الأعداد والتقدم. لا يمكن التراجع.',
      'qaza_all_done': 'تم قضاء جميع الصلوات. الحمد لله!',
      'qaza_tool_subtitle': 'الصلوات الفائتة',
      // Auth / onboarding / profile / settings / about pages
      'app_tagline': 'اجعل البركة في وقتك',
      'onboarding_pulse_title': 'النبض الروحي',
      'onboarding_pulse_desc':
          'تابع استمرارك الروحي وابنِ عادات دائمة. ابقَ متصلاً وثابتاً.',
      'onboarding_prayer_title': 'لا تفوّت أي صلاة',
      'onboarding_prayer_desc':
          'مواقيت صلاة دقيقة وعدّ تنازلي مباشر وتذكيرات مخصّصة لموقعك.',
      'onboarding_inspiration_title': 'إلهام يومي',
      'onboarding_inspiration_desc':
          'اعثر على السكينة مع آيات يومية وأسماء الله الحسنى والأدعية والمزيد لروحك.',
      'onboarding_next': 'التالي',
      'onboarding_get_started': 'ابدأ الآن',
      'auth_welcome_back': 'مرحباً بعودتك',
      'auth_sign_in_subtitle': 'سجّل الدخول لمواصلة رحلتك الروحية',
      'auth_email_address': 'البريد الإلكتروني',
      'auth_password': 'كلمة المرور',
      'auth_sign_in': 'تسجيل الدخول',
      'auth_or': 'أو',
      'auth_no_account': 'ليس لديك حساب؟',
      'auth_sign_up': 'إنشاء حساب',
      'auth_create_account': 'إنشاء حساب جديد',
      'auth_sign_up_subtitle': 'انضم إلى مجتمعنا ولننمُ معاً',
      'auth_full_name': 'الاسم الكامل',
      'auth_register': 'تسجيل',
      'auth_have_account': 'لديك حساب بالفعل؟',
      'auth_account_created_verify':
          'تم إنشاء الحساب! أرسلنا رابط التحقق إلى {email}.',
      'profile_saved_verses': 'الآيات المحفوظة',
      'profile_saved_count': '{n} محفوظة',
      'profile_activity_history': 'سجل النشاط',
      'profile_last_activity': 'آخر نشاط: {activity}',
      'profile_no_saved_verses':
          'لا توجد آيات محفوظة بعد. اضغط على علامة الحفظ بجانب أي آية لحفظها هنا.',
      'profile_remove_verse': 'إزالة من المحفوظات',
      'profile_undo': 'تراجع',
      'profile_change_photo': 'تغيير الصورة',
      'profile_take_photo': 'التقاط صورة',
      'profile_choose_gallery': 'اختيار من المعرض',
      'profile_guest_title': 'مرحباً بك',
      'profile_yesterday': 'أمس',
      'settings_account': 'الحساب',
      'settings_prayer': 'الصلاة',
      'settings_support_us': 'ادعم عملنا',
      'settings_version': 'الإصدار {v}',
      'about_title': 'حول وقت البركة',
      'about_description':
          'رفيق إسلامي لمواقيت الصلاة والقرآن والذكر والنمو الروحي اليومي، صُمّم ليجلب البركة إلى وقتك.',
      'about_credits': 'الشكر ومصادر البيانات',
      'about_quran_data': 'نص القرآن والترجمات والتلاوات',
      'about_map_data': 'بيانات الخرائط والأماكن',
      'about_map_license':
          '© المساهمون في OpenStreetMap، متاحة بموجب رخصة قاعدة البيانات المفتوحة (ODbL)',
      'about_prayer_calc': 'حساب مواقيت الصلاة',
      'about_prayer_calc_source': 'مكتبة adhan (مفتوحة المصدر)',
      'about_privacy': 'سياسة الخصوصية',
      'about_terms': 'شروط الخدمة',
      'about_licenses': 'تراخيص البرمجيات المفتوحة',
      'about_made_with_love': 'صُنع بـ ❤️ للأمة',
      'about_link_failed': 'تعذّر فتح الرابط. حاول لاحقاً.',
      'search_surahs': 'ابحث بالاسم أو الرقم',
      'continue_reading': 'متابعة القراءة',
      'no_surahs_found': 'لا توجد سور مطابقة لبحثك',
      'meccan': 'مكية',
      'medinan': 'مدنية',
      'verse_saved': 'تم حفظ الآية',
      'verse_removed': 'تمت إزالة الآية من المحفوظات',
      'save_verse': 'حفظ الآية',
      'remove_saved_verse': 'إزالة من المحفوظات',
      'share_ayah_heading': 'الآية {ayah} من سورة {surah}',
      'copy': 'نسخ',
      'copied': 'تم النسخ',
      'meaning': 'المعنى',
      'transliteration': 'النطق',
      'name_number': 'الاسم {n} من 99',
      'alhamdulillah': 'الحمد لله',
      'allahu_akbar': 'الله أكبر',
      'astaghfirullah': 'أستغفر الله',
      'la_ilaha_illallah': 'لا إله إلا الله',
      'tasbeeh_target': 'الهدف',
      'tasbeeh_custom': 'مخصص',
      'tasbeeh_custom_target': 'هدف مخصص',
      'tasbeeh_round': 'الجولة {n}',
      'tasbeeh_total': 'المجموع: {n}',
      'tasbeeh_target_reached': 'تم بلوغ الهدف!',
      'tasbeeh_counter_semantics': 'العداد: {count}. انقر للعد.',
      'tasbeeh_target_invalid': 'أدخل رقماً من 1 إلى 9999',
      'zakat_currency': 'العملة (اختياري)',
      'zakat_currency_hint': 'مثال: USD، SAR، EGP',
      'distance_m': '{n} م',
      'distance_km': '{n} كم',
      'osm_attribution': '© OpenStreetMap contributors',
      'dua_before_sleeping': 'قبل النوم',
      'dua_waking_up': 'عند الاستيقاظ',
      'dua_before_eating': 'قبل الطعام',
      'dua_after_eating': 'بعد الطعام',
      'dua_entering_home': 'عند دخول المنزل',
      'dua_leaving_home': 'عند الخروج من المنزل',
      'dua_entering_mosque': 'عند دخول المسجد',
      'dua_leaving_mosque': 'عند الخروج من المسجد',
      'dua_for_parents': 'للوالدين',
      'dua_for_knowledge': 'لطلب العلم',
      'dua_forgiveness': 'الاستغفار',
      'dua_entering_washroom': 'عند دخول الخلاء',
      'dua_leaving_washroom': 'عند الخروج من الخلاء',
      'dua_before_wudu': 'قبل الوضوء',
      'dua_after_wudu': 'بعد الوضوء',
      'dua_traveling': 'دعاء السفر',
      'dua_morning_evening': 'أذكار الصباح والمساء',
      'dua_protection': 'للحفظ',
      'dua_ayatul_kursi': 'آية الكرسي (بعد الصلاة)',
      'dua_mirror': 'عند النظر في المرآة',
      'dua_wearing_clothes': 'عند لبس الثوب',
      'clear_search': 'مسح البحث',
      'confirm': 'تأكيد',
      'continue_with_apple': 'المتابعة باستخدام Apple',
      'continue_with_google': 'المتابعة باستخدام Google',
      'dismiss': 'إغلاق',
      'hide_password': 'إخفاء كلمة المرور',
      'loading': 'جارٍ التحميل…',
      'show_password': 'إظهار كلمة المرور',
      'something_went_wrong': 'حدث خطأ ما. حاول مرة أخرى.',
      'type_to_confirm': 'اكتب {text} للتأكيد',
      'all_tools': 'جميع الأدوات',
      'ayah': 'آية',
      'ayahs': 'آيات',
      'calibrate_compass':
          'إذا بدا الاتجاه خاطئًا، حرّك هاتفك على شكل الرقم 8 لمعايرة البوصلة.',
      'compass_unavailable':
          'البوصلة غير متوفرة على هذا الجهاز — اتجه إلى الشمال ثم استدر بالزاوية الموضحة.',
      'could_not_open_maps': 'تعذّر فتح الخرائط',
      'degrees_from_north': '{deg}° من الشمال',
      'detecting_location': 'جارٍ تحديد الموقع...',
      'directions': 'الاتجاهات',
      'facing_qibla': 'أنت تواجه القبلة',
      'finding_mosques': 'جارٍ البحث عن المساجد القريبة...',
      'in_days': 'بعد {n} يوم',
      'listen_translation': 'استمع إلى الترجمة',
      'location_error_message':
          'تعذّر تحديد موقعك. فعّل خدمات الموقع والإذن ثم حاول مرة أخرى.',
      'mark_as_read': 'تحديد كمقروءة',
      'mosques_load_error':
          'تعذّر تحميل المساجد القريبة. تحقق من اتصالك بالإنترنت.',
      'no_mosques_match': 'لا توجد مساجد مطابقة لبحثك',
      'no_mosques_nearby': 'لم يتم العثور على مساجد ضمن 5 كم',
      'now_playing': 'قيد التشغيل',
      'open_in_maps': 'فتح في الخرائط',
      'pause': 'إيقاف مؤقت',
      'play': 'تشغيل',
      'play_surah': 'تشغيل السورة',
      'quran_load_error':
          'تعذّر تحميل القرآن. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      'reset_counter_message':
          'سيعود العداد إلى 0. سيتم حفظ ذكرك حتى الآن في النبض الروحي.',
      'reset_counter_title': 'إعادة ضبط العداد؟',
      'share': 'مشاركة',
      'stop': 'إيقاف',
      'surah_already_logged_today': 'تم التسجيل اليوم بالفعل ✓',
      'surah_load_error':
          'تعذّر تحميل هذه السورة. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      'surah_logged': 'تم تسجيل سورة {name}! ✨',
      'today': 'اليوم',
      'tomorrow': 'غدًا',
      'translation': 'الترجمة',
      'unnamed_mosque': 'مسجد',
      'zakat_above_nisab': 'فوق النصاب ({nisab}) — تجب الزكاة',
      'zakat_below_nisab': 'أقل من النصاب ({nisab}) — لا زكاة واجبة',
      'zakat_gold_nisab': 'الذهب (87.48 غ)',
      'zakat_gold_price': 'سعر غرام الذهب الحالي',
      'zakat_invalid_amount': 'أدخل رقمًا موجبًا صحيحًا',
      'zakat_liabilities': 'الديون / الالتزامات المستحقة',
      'zakat_net_wealth': 'صافي المال الخاضع للزكاة',
      'zakat_nisab_standard': 'معيار النصاب',
      'zakat_nisab_unknown': 'أدخل سعر المعدن أدناه للتحقق من النصاب',
      'zakat_no_wealth': 'لا يوجد مال خاضع للزكاة بعد الديون — لا زكاة واجبة',
      'zakat_silver_nisab': 'الفضة (612.36 غ)',
      'zakat_silver_price': 'سعر غرام الفضة الحالي',
      'mawlid': 'المولد النبوي',
      'isra_miraj': 'الإسراء والمعراج',
      'shab_e_barat': 'ليلة النصف من شعبان',
      'laylat_al_qadr': 'ليلة القدر (ليلة 27)',
      'day_of_arafah': 'يوم عرفة',
      'name_required': 'يرجى إدخال اسمك.',
      'email_required': 'يرجى إدخال بريدك الإلكتروني.',
      'invalid_email': 'يرجى إدخال بريد إلكتروني صالح.',
      'password_required': 'يرجى إدخال كلمة المرور.',
      'password_too_short': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.',
      'passwords_do_not_match': 'كلمتا المرور غير متطابقتين.',
      'confirm_password': 'تأكيد كلمة المرور',
      'err_user_not_found': 'لا يوجد حساب بهذا البريد الإلكتروني.',
      'err_wrong_credentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      'err_email_in_use': 'يوجد حساب بهذا البريد الإلكتروني بالفعل.',
      'err_network': 'خطأ في الشبكة. تحقق من اتصالك.',
      'err_too_many_requests': 'محاولات كثيرة جداً. حاول لاحقاً.',
      'err_recent_login':
          'لأسباب أمنية، يرجى تسجيل الخروج ثم الدخول مجدداً قبل تغيير بريدك الإلكتروني.',
      'err_upload_failed': 'فشل رفع الصورة. حاول مرة أخرى.',
      'err_profile_update_failed': 'فشل تحديث الملف الشخصي. حاول مرة أخرى.',
      'err_google_failed': 'فشل تسجيل الدخول عبر Google. حاول مرة أخرى.',
      'profile_updated': 'تم تحديث الملف الشخصي.',
      'photo_updated': 'تم تحديث صورة الملف الشخصي.',
      'verification_email_sent':
          'تم إرسال رابط تحقق إلى بريدك الجديد. سيتم تحديث بريدك بعد التأكيد.',
      'forgot_password': 'نسيت كلمة المرور؟',
      'reset_password': 'إعادة تعيين كلمة المرور',
      'reset_password_hint':
          'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.',
      'send_link': 'إرسال الرابط',
      'reset_email_sent':
          'تم إرسال رسالة إعادة تعيين كلمة المرور. تحقق من بريدك.',
      'email': 'البريد الإلكتروني',
      'name': 'الاسم',
      'photo_permission_denied':
          'تم رفض الوصول إلى الصور. يرجى السماح بالوصول من إعدادات الجهاز.',
      'photo_pick_failed': 'تعذر فتح الصور. حاول مرة أخرى.',
      'member_since': 'عضو منذ',
      'my_profile': 'ملفي الشخصي',
      'points': 'النقاط',
      'badges': 'الأوسمة',
      'sign_out': 'تسجيل الخروج',
      'sign_out_confirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'notifications_subtitle': 'الأذان والتذكيرات والتنبيهات',
      'location_settings': 'إعدادات الموقع',
      'auto_location': 'الموقع التلقائي (GPS)',
      'manual_location': 'الموقع اليدوي',
      'location_required': 'يرجى إدخال مدينة.',
      'rate_now': 'قيّم الآن',
      'later': 'لاحقاً',
      'rate_us_message': 'إذا أعجبك تطبيق بركة تايم، يرجى تقييمنا! ✨',
      'app_store_coming_soon':
          'بركة تايم سيتوفر قريباً على App Store. شكراً لدعمك!',
      'store_open_failed': 'تعذر فتح المتجر. حاول لاحقاً.',
      'close': 'إغلاق',
      'skip': 'تخطي',
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
      'asr_calculation': 'حساب العصر',
      'asr_shafi': 'الجمهور (شافعي، مالكي، حنبلي)',
      'asr_hanafi': 'حنفي',
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
      'sunrise': 'الشروق',
      'tomorrow_fajr': 'فجر الغد',
      'location_not_found':
          'تعذر العثور على "{city}". جرّب تهجئة أخرى أو أضف اسم الدولة.',
      'location_services_disabled': 'خدمات الموقع متوقفة',
      'location_permission_denied':
          'نحتاج إذن الموقع لعرض أوقات الصلاة في مكانك.',
      'location_permission_denied_forever':
          'إذن الموقع محظور. فعّله من إعدادات التطبيق أو حدّد المدينة يدويًا.',
      'location_timeout': 'تعذر تحديد موقعك في الوقت المناسب.',
      'location_access_required': 'مطلوب الوصول إلى الموقع',
      'open_settings': 'فتح الإعدادات',
      'grant_access_retry': 'السماح وإعادة المحاولة',
      'set_manual_location_hint': 'أو حدّد المدينة يدويًا من الإعدادات.',
      'locating': 'جارٍ تحديد الموقع...',
      'location_unavailable': 'الموقع غير متاح',
      'prayer_not_started': 'لم يحن وقت {prayer} بعد.',
      'prayer_already_logged': 'تم تسجيل {prayer} اليوم بالفعل.',
      'prayer_notification_title': 'حان وقت {prayer}',
      'prayer_notification_body': 'حان الآن وقت صلاة {prayer}.',
      'pulse_load_failed': 'تعذر تحميل نبضك الروحي.',
      'names_99_short': 'الأسماء الحسنى',
      'duas_short': 'الأدعية',
      'tasbeeh_short': 'التسبيح',
      'badge_first_step': 'الخطوة الأولى',
      'badge_first_step_desc': 'سجّلت أول نشاط لك',
      'badge_streak_7': 'سلسلة ٧ أيام',
      'badge_streak_7_desc': 'نشِط ٧ أيام متتالية',
      'badge_streak_30': 'بطل الشهر',
      'badge_streak_30_desc': 'نشِط ٣٠ يومًا متتاليًا',
      'badge_streak_100': 'الثابت',
      'badge_streak_100_desc': 'نشِط ١٠٠ يوم متتالية',
      'badge_daily_achiever': 'منجز اليوم',
      'badge_daily_achiever_desc': 'حققت ١٠٠ نقطة في يوم واحد',
      'badge_spiritual_veteran': 'المواظب',
      'badge_spiritual_veteran_desc': 'سجّلت ٥٠ نشاطًا',
      'badge_points_1000': '١٠٠٠ نقطة',
      'badge_points_1000_desc': 'جمعت ١٠٠٠ نقطة إجمالًا',
      'no_badges_yet': 'استمر في استخدام التطبيق لتحصل على الأوسمة!',
      'badges_earned': '{n} أوسمة مكتسبة',
      'motivation_achieved':
          'ما شاء الله! لقد حققت أهدافك الروحية لهذا اليوم. ✨',
      'motivation_almost': 'تقدّم رائع! بقي القليل لتبلغ هدفك. 🚀',
      'motivation_halfway': 'أنت في منتصف الطريق! حافظ على همّتك. 💪',
      'motivation_started': 'بداية طيبة! واصل التقدّم نحو أهدافك. ⚡',
      'motivation_start': 'ابدأ رحلتك الروحية لهذا اليوم. كل خطوة لها أثر! 🌱',
      'method_mwl': 'رابطة العالم الإسلامي',
      'method_karachi': 'جامعة العلوم الإسلامية، كراتشي',
      'method_isna': 'الجمعية الإسلامية لأمريكا الشمالية',
      'method_umm_al_qura': 'جامعة أم القرى، مكة المكرمة',
      'method_egyptian': 'الهيئة المصرية العامة للمساحة',
      'method_dubai': 'دبي (الإمارات)',
      'method_qatar': 'قطر',
      'method_kuwait': 'الكويت',
      'method_turkey': 'رئاسة الشؤون الدينية (تركيا)',
      'method_tehran': 'معهد الجيوفيزياء، جامعة طهران',
      'method_singapore': 'سنغافورة وماليزيا وإندونيسيا',
      'method_moonsighting': 'لجنة رؤية الهلال العالمية',
      'unknown_city': 'موقع غير معروف',
      'daily_challenges': 'تحديات اليوم',
      'challenges_hint': 'تكتمل تلقائياً أثناء استخدامك للتطبيق',
      'challenge_prayers': 'صلِّ الصلوات الخمس',
      'challenge_quran': 'اقرأ من القرآن',
      'challenge_dhikr': 'سبّح ٣٣ مرة في المسبحة',
      'challenges_all_done': 'ما شاء الله! أكملت كل تحديات اليوم',
      'perfect_days_week': 'الأيام المكتملة هذا الأسبوع: {n}/7',
      'quran_font': 'خط القرآن',
      'quran_font_note': 'يُنزَّل كل خط مرة واحدة عند أول استخدام.',
      'night_rec_title': 'قبل النوم',
      'night_rec_subtitle': 'من سنة النبي ﷺ',
      'friday_rec_title': 'جمعة مباركة',
      'friday_rec_subtitle': 'اقرأ سورة الكهف يوم الجمعة',
      'rec_ayat_kursi': 'آية الكرسي',
      'rec_baqarah_end': 'آخر آيتين من سورة البقرة',
      'rec_mulk': 'سورة الملك',
      'rec_quls': 'المعوذات وسورة الكافرون',
      'rec_waqiah': 'سورة الواقعة',
      'rec_muzzammil': 'سورة المزمل',
      'rec_kahf': 'سورة الكهف',
      'rec_also_common': 'يقرؤها كثيرون أيضاً',
      'mark_done': 'تم',
      'mark_not_done': 'لم يتم',
      'night_reminder': 'تذكير أذكار الليل',
      'night_reminder_desc': 'بعد العشاء بساعة',
      'kahf_reminder': 'سورة الكهف يوم الجمعة',
      'kahf_reminder_desc': 'صباح الجمعة',
      'night_reminder_title': 'قبل النوم 🌙',
      'night_reminder_body': 'آية الكرسي وسورة الملك والمعوذات',
      'kahf_reminder_title': 'جمعة مباركة',
      'kahf_reminder_body': 'لا تنس قراءة سورة الكهف اليوم',
      'playback_speed': 'سرعة التشغيل',
      'mushaf': 'المصحف',
      'page_n': 'صفحة {n}',
      'juz_n': 'الجزء {n}',
      'mushaf_tap_hint': 'اضغط على آية لعرض ترجمتها أو تشغيلها أو حفظها',
      'play_from_here': 'تشغيل من هنا',
      'send_feedback': 'إرسال ملاحظات',
      'send_feedback_desc': 'أبلغ عن مشكلة أو اقترح فكرة',
      'feedback_no_email_app': 'لا يوجد تطبيق بريد. راسلنا على {email}',
      'adhan_help': 'الأذان متأخر أو لا يصل؟',
      'adhan_help_desc': 'إعدادات الهاتف التي قد تمنع التنبيهات',
      'adhan_help_body': 'بعض الهواتف (مثل Vivo وOppo وXiaomi وInfinix وSamsung) توقف التطبيقات في الخلفية لتوفير البطارية، وقد يؤخر ذلك الأذان أو يمنعه.\n\n1. افتح إعدادات التطبيق من الزر أدناه.\n2. البطارية: اختر «غير مقيد» أو «بلا قيود».\n3. إذا كان في هاتفك خيار «التشغيل التلقائي» أو «النشاط في الخلفية» ففعّله لتطبيق Barakah Time.\n4. تأكد من السماح بالإشعارات.\n\nبعد ذلك افتح Barakah Time مرة واحدة ليعيد ضبط التنبيهات.',
      'refresh_location': 'تحديث الموقع',
      'location_updated': 'تم تحديث الموقع',
      'default_user_name': 'مستخدم بركة',
      'sign_in_with_apple': 'تسجيل الدخول باستخدام Apple',
      'continue_as_guest': 'ليس الآن',
      'guest_mode_notice':
          'كل الميزات تعمل بدون حساب. سجّل الدخول فقط إذا أردت حفظ تقدّمك واستخدامه على أجهزة أخرى.',
      'sign_in_to_sync': 'سجّل الدخول للمزامنة',
      'auth_unavailable_notice':
          'تسجيل الدخول غير متاح حاليًا. يمكنك متابعة استخدام التطبيق وستبقى بياناتك على هذا الجهاز.',
      'err_auth_unavailable':
          'تسجيل الدخول غير متاح حاليًا. تحقّق من اتصالك وأعد تشغيل التطبيق.',
      'err_apple_failed': 'فشل تسجيل الدخول باستخدام Apple. حاول مرة أخرى.',
      'err_user_disabled': 'تم تعطيل هذا الحساب.',
      'err_account_exists_different_provider':
          'يوجد حساب بهذا البريد بطريقة تسجيل دخول مختلفة.',
      'err_user_mismatch': 'يرجى تسجيل الدخول بالحساب نفسه الذي تريد حذفه.',
      'session_expired': 'تم تسجيل خروجك. يرجى تسجيل الدخول مرة أخرى.',
      'email_not_verified':
          'لم يتم التحقق من بريدك بعد. تحقّق من صندوق الوارد لرابط التحقق.',
      'resend_verification': 'إعادة إرسال رسالة التحقق',
      'verification_link_resent': 'تم إرسال رسالة التحقق. تحقّق من بريدك.',
      'delete_account': 'حذف الحساب',
      'delete_confirm_word': 'حذف',
      'delete_account_confirm_title': 'حذف حسابك؟',
      'delete_account_confirm_message':
          'سيؤدي هذا إلى حذف حسابك وتقدّمك وأوسمتك والآيات المحفوظة وصورتك نهائيًا. لا يمكن التراجع عن ذلك.',
      'reauth_required_delete':
          'لأسباب أمنية، يرجى تأكيد تسجيل دخولك لحذف حسابك.',
      'confirm_with_password': 'أدخل كلمة المرور للمتابعة',
      'confirm_with_provider': 'التأكيد عبر {provider}',
      'account_deleted': 'تم حذف حسابك.',
      'err_delete_account_failed': 'تعذّر حذف حسابك. حاول مرة أخرى.',
      'lifetime_points': 'إجمالي النقاط',
      'longest_streak': 'أطول سلسلة',
      'adhan_sound': 'صوت الأذان',
      'adhan_sound_desc': 'تشغيل الأذان مع تذكيرات الصلاة',
      'adjust_times': 'ضبط أوقات الصلاة',
      'app_theme': 'المظهر',
      'theme_system': 'حسب النظام',
      'theme_light': 'فاتح',
      'theme_dark': 'داكن',
      'adjust_times_desc': 'قدّم أو أخّر كل صلاة لتطابق مسجدك',
      'adjust_times_none': 'بدون تغيير',
      'minutes_short': '{n} د',
      'adjust_times_note':
          'تُزاح الأوقات عن الوقت المحسوب. استخدم هذا فقط إذا كان مسجدك المحلي مختلفاً.',
      'exact_alarms_hint':
          'اسمح بـ"المنبّهات والتذكيرات" لتصل تذكيرات الصلاة في وقتها تمامًا.',
      'notifications_permission_revoked':
          'تم إيقاف إذن الإشعارات من إعدادات النظام، لذا عُطّلت تذكيرات الصلاة.',
      'good_morning': 'صباح الخير',
      'good_afternoon': 'طاب يومك',
      'good_evening': 'مساء الخير',
      'assalamualaikum': 'السلام عليكم',
      'hijri_year_suffix': 'هـ',
      'hijri_month_1': 'محرم',
      'hijri_month_2': 'صفر',
      'hijri_month_3': 'ربيع الأول',
      'hijri_month_4': 'ربيع الآخر',
      'hijri_month_5': 'جمادى الأولى',
      'hijri_month_6': 'جمادى الآخرة',
      'hijri_month_7': 'رجب',
      'hijri_month_8': 'شعبان',
      'hijri_month_9': 'رمضان',
      'hijri_month_10': 'شوال',
      'hijri_month_11': 'ذو القعدة',
      'hijri_month_12': 'ذو الحجة',
      'qibla_short': 'القبلة',
      'calendar_short': 'التقويم',
      'more': 'المزيد',
      'read_full_ayah': 'اقرأ الآية كاملة',
      'shared_from_app': 'تمت المشاركة من تطبيق بركة تايم',
      'pulse_share_text':
          'تقدّمي في بركة تايم: سلسلة {streak} يوم و{points} نقطة هذا الأسبوع.',
      'points_this_week': 'نقاط هذا الأسبوع',
      'current_streak': 'السلسلة الحالية',
      'day_streak_count': 'سلسلة {n} يوم',
      'weekday_points': '{day}: {n} نقطة',
      'recent_activity': 'النشاط الأخير',
      'no_recent_activity':
          'لا يوجد نشاط بعد. سجّل صلاة أو اقرأ القرآن أو اذكر الله لتبدأ.',
      'activity_prayer': 'صلاة {prayer}',
      'activity_quran': 'قراءة القرآن',
      'activity_dhikr': 'ذكر',
      'activity_other': 'نشاط',
      'points_gained': '+{n} نقطة',
      'prayer_logged_semantics': 'تم تسجيل {prayer}',
      'log_prayer_semantics': 'سجّل {prayer}',
      'prayer_in_label': '{prayer} بعد',
      'cardinal_n': 'شمال',
      'cardinal_e': 'شرق',
      'cardinal_s': 'جنوب',
      'cardinal_w': 'غرب',
      'qibla_semantics_right': 'القبلة على بُعد {deg}° إلى يمينك',
      'qibla_semantics_left': 'القبلة على بُعد {deg}° إلى يسارك',
      'qibla_semantics_ahead': 'القبلة أمامك مباشرة',
      'qibla_compass': 'بوصلة القبلة',
      'logged': 'مُسجَّلة',
    },
    'fa': {
      'pulse_today': 'امروز',
      'pulse_today_prayers': 'نمازهای امروز',
      'badge_locked': 'قفل',
      'audio_error_voice_missing':
          "گوشی صدای این زبان را ندارد. آن را از تنظیمات ← تبدیل متن به گفتار نصب کنید.",
      'quran_translation_language': 'زبان ترجمه',
      'quran_translation_same_as_app': 'همان زبان برنامه',
      'quran_translation_audio_note':
          'ترجمه‌های اردو، انگلیسی، فارسی و ترکی با صدای یک قاری خوانده می‌شود.',
      'audio_error_play': 'پخش صدا ممکن نشد. تلاوت‌های جدید بار اول به اینترنت نیاز دارند؛ آنچه قبلاً شنیده‌اید بدون اینترنت هم پخش می‌شود.',
      'audio_error_speech': 'پخش گفتار ناموفق بود',
      'name_too_long': 'نام باید حداکثر ۱۰۰ نویسه باشد',
      'reminders_need_notifications':
          'ابتدا اعلان‌های نماز را در تنظیمات روشن کنید.',
      'ramadan_title': 'رمضان',
      'ramadan_day_of': 'روز {day} از {len}',
      'ramadan_starts_in': '{n} روز تا شروع',
      'ramadan_qadr_tonight':
          'امشب ممکن است شب قدر باشد. آن را با عبادت و دعا بگذرانید.',
      'ramadan_moon_adjust': 'تنظیم رؤیت هلال (روز)',
      'ramadan_need_location':
          'برای دیدن زمان سحر و افطار، اوقات نماز را بارگیری کنید.',
      'ramadan_sehri_ends_in': 'پایان سحر تا',
      'ramadan_iftar_in': 'افطار تا',
      'ramadan_sehri_ends': 'پایان سحر',
      'ramadan_iftar': 'افطار',
      'ramadan_reminders': 'یادآوری سحر و افطار',
      'ramadan_reminders_desc': '۳۰ دقیقه پیش از پایان سحر، و هنگام افطار',
      'ramadan_duas': 'دعاهای رمضان',
      'ramadan_sehri_niyyah': 'نیت روزه (سحر)',
      'ramadan_sehri_niyyah_meaning':
          'نیت می‌کنم روزه فردا از ماه رمضان را بگیرم.',
      'ramadan_iftar_dua': 'دعای افطار',
      'ramadan_iftar_dua_meaning':
          'خدایا برای تو روزه گرفتم، به تو ایمان آوردم، بر تو توکل کردم و با روزی تو افطار کردم.',
      'ramadan_iftar_dua2': 'پس از افطار',
      'ramadan_iftar_dua2_meaning':
          'تشنگی رفت، رگ‌ها تر شد و پاداش ثابت شد، اگر خدا بخواهد. (ابوداود)',
      'ramadan_qadr_dua': 'دعای شب قدر',
      'ramadan_qadr_dua_meaning':
          'خدایا تو بخشنده‌ای و بخشش را دوست داری، پس مرا ببخش. (ترمذی)',
      'ramadan_log': 'ثبت روزه‌ها',
      'ramadan_fasted': 'روزه گرفتم',
      'ramadan_missed': 'قضا',
      'ramadan_taraweeh': 'تراویح',
      'ramadan_log_hint':
          'برای ثبت روزه و تراویح روی روز بزنید. ستاره‌ها شب‌های فرد دهه آخر هستند.',
      'ramadan_qaza_fasts': '{n} روزه قضا',
      'ramadan_day': 'روز',
      'ramadan_not_set': 'پاک کردن',
      'ramadan_prayed_taraweeh': 'تراویح خواندم',
      'ramadan_prepare': 'آماده شوید: برای قرآن، دعا و صدقه برنامه بریزید.',
      'ramadan_sehri_reminder_title': 'سحر ۳۰ دقیقه دیگر تمام می‌شود',
      'ramadan_sehri_reminder_body':
          'سحر ساعت {time} تمام می‌شود. نیت را فراموش نکنید.',
      'ramadan_iftar_reminder_title': 'وقت افطار است',
      'ramadan_iftar_reminder_body':
          'روزه را باز کنید و دعا کنید؛ دعای روزه‌دار هنگام افطار رد نمی‌شود.',
      'memorial_title': 'ایصال ثواب',
      'memorial_tool_subtitle': 'برای درگذشتگان',
      'memorial_sign_in':
          'برای ساختن یا پیوستن به صفحه ایصال ثواب یک عزیز وارد شوید.',
      'memorial_intro':
          'برای عزیزی که درگذشته صفحه‌ای بسازید و در واتس‌اپ به اشتراک بگذارید. خانواده و دوستان می‌توانند جزء بگیرند تا ختم قرآن کامل شود، برای اهداف مشترک ذکر بگویند و کارهای نیک برایش ثبت کنند.',
      'memorial_create': 'ساختن صفحه',
      'memorial_join': 'پیوستن با کد',
      'memorial_none':
          'هنوز صفحه‌ای نیست. یکی بسازید یا با کدی که برایتان فرستاده‌اند بپیوندید.',
      'memorial_you_created': 'ساخته شما',
      'memorial_joined': 'عضو',
      'memorial_code_invalid': 'کد ۸ حرفی را وارد کنید',
      'memorial_code': 'کد',
      'memorial_join_button': 'پیوستن',
      'memorial_name_required': 'نام را وارد کنید',
      'memorial_name': 'نام درگذشته',
      'memorial_subtitle': 'نسبت یا یادداشت (اختیاری)',
      'memorial_subtitle_hint': 'مثلاً پدر احمد',
      'memorial_death_date': 'تاریخ درگذشت',
      'memorial_optional': 'اختیاری',
      'memorial_show_dates': 'نمایش روزهای یادبود',
      'memorial_show_dates_desc': 'سوم، دهم، چهلم و سالگرد',
      'memorial_goals': 'اهداف ذکر',
      'memorial_goal': 'هدف',
      'memorial_error_not_found': 'صفحه‌ای با این کد پیدا نشد.',
      'memorial_error_para_taken':
          'کسی همین الان این جزء را گرفت. جزء دیگری انتخاب کنید.',
      'memorial_error_generic':
          'مشکلی پیش آمد. اینترنت را بررسی کنید و دوباره تلاش کنید.',
      'memorial_deleted': 'این صفحه حذف شده است.',
      'memorial_remove_from_list': 'حذف از فهرست من',
      'memorial_created_hint':
          'صفحه ساخته شد. آن را با خانواده و دوستان به اشتراک بگذارید.',
      'memorial_share': 'اشتراک',
      'memorial_share_text':
          'در ایصال ثواب برای {name} شرکت کنید. در برنامه Barakah Time یک جزء قرآن بخوانید یا برایش ذکر بگویید.\n\nکد: {code}\n\nدریافت برنامه: {link}',
      'memorial_para': 'جزء {n}',
      'memorial_take_para_confirm':
          'این جزء را برای درگذشته می‌خوانید. دیگران می‌بینند که شما آن را گرفته‌اید.',
      'memorial_take_para': 'گرفتن این جزء',
      'memorial_para_read_by': 'جزء {n} را {name} خواند',
      'memorial_para_taken_by': 'جزء {n} را {name} می‌خواند',
      'memorial_para_yours': 'شما این جزء را می‌خوانید',
      'memorial_mark_read': 'خواندم',
      'memorial_release_para': 'پس دادن',
      'memorial_khatam_done': 'ختم کامل شد. الحمدلله! ختم تازه‌ای شروع شد.',
      'memorial_para_done': 'جزاک الله خیر. خدا قبول کند.',
      'memorial_how_many': 'چند بار؟',
      'memorial_added': 'افزوده شد. جزاک الله خیر.',
      'memorial_delete': 'حذف صفحه',
      'memorial_delete_confirm':
          'این صفحه برای همه با تمام پیشرفت حذف می‌شود. قابل بازگشت نیست.',
      'memorial_add_deed': 'افزودن کار نیک یا دعا',
      'memorial_deed_hint': 'مثلاً به ۱۰ نفر غذا دادم، یا دعایی برایش',
      'memorial_dates': 'روزهای یادبود',
      'memorial_activity': 'فعالیت',
      'memorial_code_copied': 'کد کپی شد',
      'memorial_invite': 'دعوت',
      'memorial_khatam_n': 'ختم {n}',
      'memorial_khatams_completed': '{n} ختم کامل شد',
      'memorial_khatam_hint':
          'روی یک جزء آزاد بزنید تا آن را برای درگذشته بخوانید.',
      'memorial_free': 'آزاد',
      'memorial_yours': 'مال شما',
      'memorial_taken': 'گرفته‌شده',
      'memorial_read': 'خوانده‌شده',
      'memorial_add_count': 'افزودن',
      'memorial_remind_me': 'در این روزها یادآوری کن',
      'memorial_feed_para': '{name} جزء {n} را خواند',
      'memorial_feed_khatam': 'ختم {n} کامل شد. الحمدلله!',
      'memorial_feed_dhikr': '{name} {dhikr} را {count} بار خواند',
      'memorial_feed_empty': 'هنوز چیزی نیست. اولین نفر باشید.',
      'memorial_day3': 'سوم',
      'memorial_day10': 'دهم',
      'memorial_day40': 'چهلم',
      'memorial_barsi': 'سالگرد',
      'memorial_reminder_title': '{day} {name}',
      'memorial_reminder_body':
          'امروز {name} را با قرآن، دعا یا صدقه یاد کنید.',
      'dhikr_kareema': 'آیه کریمه',
      'dhikr_darood': 'صلوات',
      'dhikr_kalma': 'کلمه طیبه',
      'dhikr_ikhlas': 'سوره اخلاص',
      'dhikr_yaseen': 'سوره یس',
      'dhikr_istighfar': 'استغفار',
      'widget_empty': 'برای بارگیری اوقات نماز Barakah Time را باز کنید',
      'promise_title': 'تعهد ما',
      'promise_no_ads': 'هرگز تبلیغ نداریم',
      'promise_no_sell':
          'هرگز داده‌های شما را نمی‌فروشیم یا به اشتراک نمی‌گذاریم',
      'promise_no_tracking': 'بدون ردیاب و تحلیل‌گر',
      'promise_location':
          'موقعیت شما فقط برای اوقات نماز، قبله و مساجد نزدیک استفاده می‌شود',
      'onboarding_privacy_title': 'بدون تبلیغ. داده‌های شما مال شماست.',
      'onboarding_privacy_desc':
          'Barakah Time تبلیغ و ردیاب ندارد و ما هرگز داده‌های شما را نمی‌فروشیم. عبادت شما میان شما و خداست.',
      'qaza_tracker': 'ردیاب نماز قضا',
      'witr': 'وتر',
      'qaza_intro_title': 'نمازهای قضا را جبران کنید',
      'qaza_intro_body':
          'تعداد نمازهای قضای خود را تخمین بزنید و یکی‌یکی آن‌ها را بخوانید. پیشرفت شما ذخیره و با حسابتان همگام می‌شود.',
      'qaza_calculate': 'تخمین نمازهای قضا',
      'qaza_enter_manually': 'وارد کردن دستی تعداد',
      'qaza_remaining': 'باقی‌مانده',
      'qaza_made_up': 'خوانده‌شده',
      'qaza_progress': '{p}٪ خوانده شده',
      'qaza_pray_one': 'یک قضا خواندم',
      'qaza_logged': 'یک نماز قضای {prayer} خوانده شد',
      'qaza_edit_title': '{prayer} باقی‌مانده',
      'qaza_invalid': 'عددی از 0 تا 60000 وارد کنید',
      'qaza_years': 'سال',
      'qaza_months': 'ماه',
      'qaza_days': 'روز',
      'qaza_include_witr': 'شامل وتر (حنفی)',
      'qaza_calc_desc':
          'چه مدت نماز نخوانده‌اید؟ مثلاً از بلوغ تا زمانی که نماز را مرتب شروع کردید.',
      'qaza_calc_result': '{n} از هر نماز اضافه می‌شود',
      'qaza_estimate_note':
          'برای احتیاط هر سال ۳۶۵ روز حساب می‌شود. اگر مطمئن نیستید از عالم دین بپرسید.',
      'qaza_add': 'افزودن به ردیاب',
      'qaza_reset': 'بازنشانی ردیاب',
      'qaza_reset_confirm':
          'همه تعدادها و پیشرفت پاک می‌شود. قابل بازگشت نیست.',
      'qaza_all_done': 'همه نمازهای قضا خوانده شد. الحمدلله!',
      'qaza_tool_subtitle': 'نمازهای قضا',
      // Auth / onboarding / profile / settings / about pages
      'app_tagline': 'برکت را به وقت خود بیاورید',
      'onboarding_pulse_title': 'نبض معنوی',
      'onboarding_pulse_desc':
          'پیوستگی معنوی خود را دنبال کنید و عادت‌های ماندگار بسازید. در ارتباط و پایدار بمانید.',
      'onboarding_prayer_title': 'هیچ نمازی را از دست ندهید',
      'onboarding_prayer_desc':
          'اوقات شرعی دقیق، شمارش معکوس زنده و یادآورهای متناسب با موقعیت شما.',
      'onboarding_inspiration_title': 'الهام روزانه',
      'onboarding_inspiration_desc':
          'با آیات روزانه، اسماء الحسنی، دعاها و موارد بیشتر برای روحتان آرامش بیابید.',
      'onboarding_next': 'بعدی',
      'onboarding_get_started': 'شروع کنید',
      'auth_welcome_back': 'خوش آمدید',
      'auth_sign_in_subtitle': 'برای ادامه سفر معنوی خود وارد شوید',
      'auth_email_address': 'آدرس ایمیل',
      'auth_password': 'رمز عبور',
      'auth_sign_in': 'ورود',
      'auth_or': 'یا',
      'auth_no_account': 'حساب کاربری ندارید؟',
      'auth_sign_up': 'ثبت‌نام',
      'auth_create_account': 'ایجاد حساب',
      'auth_sign_up_subtitle': 'به جامعه ما بپیوندید و با هم رشد کنیم',
      'auth_full_name': 'نام کامل',
      'auth_register': 'ثبت‌نام',
      'auth_have_account': 'قبلاً حساب ساخته‌اید؟',
      'auth_account_created_verify':
          'حساب ایجاد شد! لینک تأیید به {email} ارسال شد.',
      'profile_saved_verses': 'آیات ذخیره‌شده',
      'profile_saved_count': '{n} ذخیره‌شده',
      'profile_activity_history': 'تاریخچه فعالیت',
      'profile_last_activity': 'آخرین: {activity}',
      'profile_no_saved_verses':
          'هنوز آیه‌ای ذخیره نشده. روی نشانک هر آیه بزنید تا اینجا ذخیره شود.',
      'profile_remove_verse': 'حذف از ذخیره‌ها',
      'profile_undo': 'واگرد',
      'profile_change_photo': 'تغییر عکس',
      'profile_take_photo': 'گرفتن عکس',
      'profile_choose_gallery': 'انتخاب از گالری',
      'profile_guest_title': 'خوش آمدید',
      'profile_yesterday': 'دیروز',
      'settings_account': 'حساب کاربری',
      'settings_prayer': 'نماز',
      'settings_support_us': 'از کار ما حمایت کنید',
      'settings_version': 'نسخه {v}',
      'about_title': 'درباره وقت برکت',
      'about_description':
          'همراهی اسلامی برای اوقات نماز، قرآن، ذکر و رشد معنوی روزانه؛ طراحی‌شده تا به وقت شما برکت بدهد.',
      'about_credits': 'قدردانی و منابع داده',
      'about_quran_data': 'متن قرآن، ترجمه‌ها و صوت',
      'about_map_data': 'داده‌های نقشه و مکان',
      'about_map_license':
          '© مشارکت‌کنندگان OpenStreetMap، تحت مجوز پایگاه داده باز (ODbL)',
      'about_prayer_calc': 'محاسبه اوقات نماز',
      'about_prayer_calc_source': 'کتابخانه adhan (متن‌باز)',
      'about_privacy': 'سیاست حفظ حریم خصوصی',
      'about_terms': 'شرایط خدمات',
      'about_licenses': 'مجوزهای متن‌باز',
      'about_made_with_love': 'ساخته‌شده با ❤️ برای امت',
      'about_link_failed': 'باز کردن پیوند ممکن نشد. بعداً دوباره امتحان کنید.',
      'search_surahs': 'جستجو با نام یا شماره',
      'continue_reading': 'ادامه خواندن',
      'no_surahs_found': 'سوره‌ای با جستجوی شما مطابقت ندارد',
      'meccan': 'مکی',
      'medinan': 'مدنی',
      'verse_saved': 'آیه ذخیره شد',
      'verse_removed': 'آیه از ذخیره‌ها حذف شد',
      'save_verse': 'ذخیره آیه',
      'remove_saved_verse': 'حذف از ذخیره‌ها',
      'share_ayah_heading': 'آیه {ayah} از سوره {surah}',
      'copy': 'کپی',
      'copied': 'کپی شد',
      'meaning': 'معنی',
      'transliteration': 'آوانویسی',
      'name_number': 'نام {n} از 99',
      'alhamdulillah': 'الحمدلله',
      'allahu_akbar': 'الله اکبر',
      'astaghfirullah': 'استغفرالله',
      'la_ilaha_illallah': 'لا اله الا الله',
      'tasbeeh_target': 'هدف',
      'tasbeeh_custom': 'دلخواه',
      'tasbeeh_custom_target': 'هدف دلخواه',
      'tasbeeh_round': 'دور {n}',
      'tasbeeh_total': 'مجموع: {n}',
      'tasbeeh_target_reached': 'به هدف رسیدید!',
      'tasbeeh_counter_semantics': 'شمارنده: {count}. برای شمارش ضربه بزنید.',
      'tasbeeh_target_invalid': 'عددی بین 1 تا 9999 وارد کنید',
      'zakat_currency': 'واحد پول (اختیاری)',
      'zakat_currency_hint': 'مثلاً USD، IRR',
      'distance_m': '{n} متر',
      'distance_km': '{n} کیلومتر',
      'osm_attribution': '© OpenStreetMap contributors',
      'dua_before_sleeping': 'پیش از خواب',
      'dua_waking_up': 'هنگام بیدار شدن',
      'dua_before_eating': 'پیش از غذا',
      'dua_after_eating': 'پس از غذا',
      'dua_entering_home': 'هنگام ورود به خانه',
      'dua_leaving_home': 'هنگام خروج از خانه',
      'dua_entering_mosque': 'هنگام ورود به مسجد',
      'dua_leaving_mosque': 'هنگام خروج از مسجد',
      'dua_for_parents': 'برای والدین',
      'dua_for_knowledge': 'برای افزایش علم',
      'dua_forgiveness': 'طلب آمرزش (استغفار)',
      'dua_entering_washroom': 'هنگام ورود به دستشویی',
      'dua_leaving_washroom': 'هنگام خروج از دستشویی',
      'dua_before_wudu': 'پیش از وضو',
      'dua_after_wudu': 'پس از وضو',
      'dua_traveling': 'دعای سفر',
      'dua_morning_evening': 'ذکر صبح و شام',
      'dua_protection': 'برای حفاظت',
      'dua_ayatul_kursi': 'آیة‌الکرسی (پس از نماز)',
      'dua_mirror': 'هنگام نگاه در آینه',
      'dua_wearing_clothes': 'هنگام پوشیدن لباس',
      'clear_search': 'پاک کردن جستجو',
      'confirm': 'تأیید',
      'continue_with_apple': 'ادامه با Apple',
      'continue_with_google': 'ادامه با Google',
      'dismiss': 'بستن',
      'hide_password': 'پنهان کردن رمز عبور',
      'loading': 'در حال بارگذاری…',
      'show_password': 'نمایش رمز عبور',
      'something_went_wrong': 'مشکلی پیش آمد. دوباره تلاش کنید.',
      'type_to_confirm': 'برای تأیید {text} را تایپ کنید',
      'all_tools': 'همه ابزارها',
      'ayah': 'آیه',
      'ayahs': 'آیه',
      'calibrate_compass':
          'اگر جهت اشتباه به نظر می‌رسد، گوشی را به شکل عدد ۸ حرکت دهید تا قطب‌نما کالیبره شود.',
      'compass_unavailable':
          'قطب‌نما در این دستگاه در دسترس نیست — رو به شمال بایستید و سپس به اندازه زاویه نشان‌داده‌شده بچرخید.',
      'could_not_open_maps': 'باز کردن نقشه ممکن نشد',
      'degrees_from_north': '{deg}° از شمال',
      'detecting_location': 'در حال تشخیص موقعیت...',
      'directions': 'مسیریابی',
      'facing_qibla': 'شما رو به قبله هستید',
      'finding_mosques': 'در حال یافتن مساجد نزدیک...',
      'in_days': '{n} روز دیگر',
      'listen_translation': 'گوش دادن به ترجمه',
      'location_error_message':
          'موقعیت شما دریافت نشد. سرویس موقعیت و مجوز را فعال کرده و دوباره تلاش کنید.',
      'mark_as_read': 'علامت‌گذاری به‌عنوان خوانده‌شده',
      'mosques_load_error':
          'بارگیری مساجد نزدیک ممکن نشد. اتصال اینترنت را بررسی کنید.',
      'no_mosques_match': 'مسجدی مطابق جستجوی شما نیست',
      'no_mosques_nearby': 'مسجدی در شعاع ۵ کیلومتری یافت نشد',
      'now_playing': 'در حال پخش',
      'open_in_maps': 'باز کردن در نقشه',
      'pause': 'توقف',
      'play': 'پخش',
      'play_surah': 'پخش سوره',
      'quran_load_error':
          'بارگیری قرآن ممکن نشد. اتصال اینترنت را بررسی و دوباره تلاش کنید.',
      'reset_counter_message':
          'شمارنده به ۰ برمی‌گردد. ذکرهای شما تا این لحظه در نبض معنوی ذخیره می‌شود.',
      'reset_counter_title': 'شمارنده بازنشانی شود؟',
      'share': 'اشتراک‌گذاری',
      'stop': 'توقف کامل',
      'surah_already_logged_today': 'امروز قبلاً ثبت شده است ✓',
      'surah_load_error':
          'بارگیری این سوره ممکن نشد. اتصال اینترنت را بررسی و دوباره تلاش کنید.',
      'surah_logged': 'سوره {name} ثبت شد! ✨',
      'today': 'امروز',
      'tomorrow': 'فردا',
      'translation': 'ترجمه',
      'unnamed_mosque': 'مسجد',
      'zakat_above_nisab': 'بالاتر از نصاب ({nisab}) — زکات واجب است',
      'zakat_below_nisab': 'کمتر از نصاب ({nisab}) — زکات واجب نیست',
      'zakat_gold_nisab': 'طلا (۸۷٫۴۸ گرم)',
      'zakat_gold_price': 'قیمت فعلی هر گرم طلا',
      'zakat_invalid_amount': 'یک عدد مثبت معتبر وارد کنید',
      'zakat_liabilities': 'بدهی‌ها / تعهدات سررسید',
      'zakat_net_wealth': 'خالص دارایی مشمول زکات',
      'zakat_nisab_standard': 'معیار نصاب',
      'zakat_nisab_unknown': 'برای بررسی نصاب، قیمت فلز را در زیر وارد کنید',
      'zakat_no_wealth':
          'پس از کسر بدهی‌ها دارایی مشمول زکات ندارید — زکات واجب نیست',
      'zakat_silver_nisab': 'نقره (۶۱۲٫۳۶ گرم)',
      'zakat_silver_price': 'قیمت فعلی هر گرم نقره',
      'mawlid': 'میلاد پیامبر',
      'isra_miraj': 'اسراء و معراج',
      'shab_e_barat': 'نیمه شعبان',
      'laylat_al_qadr': 'شب قدر (شب ۲۷)',
      'day_of_arafah': 'روز عرفه',
      'name_required': 'لطفاً نام خود را وارد کنید.',
      'email_required': 'لطفاً ایمیل خود را وارد کنید.',
      'invalid_email': 'لطفاً یک ایمیل معتبر وارد کنید.',
      'password_required': 'لطفاً رمز عبور خود را وارد کنید.',
      'password_too_short': 'رمز عبور باید حداقل ۶ کاراکتر باشد.',
      'passwords_do_not_match': 'رمزهای عبور مطابقت ندارند.',
      'confirm_password': 'تأیید رمز عبور',
      'err_user_not_found': 'حسابی با این ایمیل یافت نشد.',
      'err_wrong_credentials': 'ایمیل یا رمز عبور نادرست است.',
      'err_email_in_use': 'حسابی با این ایمیل از قبل وجود دارد.',
      'err_network': 'خطای شبکه. اتصال خود را بررسی کنید.',
      'err_too_many_requests': 'تلاش‌های بیش از حد. بعداً دوباره امتحان کنید.',
      'err_recent_login':
          'برای امنیت، لطفاً پیش از تغییر ایمیل، خارج شده و دوباره وارد شوید.',
      'err_upload_failed': 'بارگذاری عکس ناموفق بود. دوباره امتحان کنید.',
      'err_profile_update_failed':
          'به‌روزرسانی نمایه ناموفق بود. دوباره امتحان کنید.',
      'err_google_failed': 'ورود با Google ناموفق بود. دوباره امتحان کنید.',
      'profile_updated': 'نمایه به‌روزرسانی شد.',
      'photo_updated': 'عکس نمایه به‌روزرسانی شد.',
      'verification_email_sent':
          'لینک تأیید به ایمیل جدید شما ارسال شد. پس از تأیید، ایمیل شما به‌روز می‌شود.',
      'forgot_password': 'رمز عبور را فراموش کرده‌اید؟',
      'reset_password': 'بازنشانی رمز عبور',
      'reset_password_hint':
          'ایمیل خود را وارد کنید تا لینک بازنشانی رمز عبور را برایتان بفرستیم.',
      'send_link': 'ارسال لینک',
      'reset_email_sent':
          'ایمیل بازنشانی رمز عبور ارسال شد. صندوق ورودی خود را بررسی کنید.',
      'email': 'ایمیل',
      'name': 'نام',
      'photo_permission_denied':
          'دسترسی به عکس‌ها رد شد. لطفاً از تنظیمات دستگاه اجازه دهید.',
      'photo_pick_failed': 'باز کردن عکس‌ها ممکن نشد. دوباره امتحان کنید.',
      'member_since': 'عضو از',
      'my_profile': 'نمایه من',
      'points': 'امتیاز',
      'badges': 'نشان‌ها',
      'sign_out': 'خروج',
      'sign_out_confirm': 'آیا مطمئن هستید که می‌خواهید خارج شوید؟',
      'notifications_subtitle': 'اذان، یادآورها و هشدارها',
      'location_settings': 'تنظیمات موقعیت',
      'auto_location': 'موقعیت خودکار (GPS)',
      'manual_location': 'موقعیت دستی',
      'location_required': 'لطفاً یک شهر وارد کنید.',
      'rate_now': 'اکنون امتیاز دهید',
      'later': 'بعداً',
      'rate_us_message':
          'اگر از Barakah Time لذت می‌برید، لطفاً به ما امتیاز دهید! ✨',
      'app_store_coming_soon':
          'Barakah Time به‌زودی در App Store عرضه می‌شود. از حمایت شما سپاسگزاریم!',
      'store_open_failed': 'باز کردن فروشگاه ممکن نشد. بعداً امتحان کنید.',
      'close': 'بستن',
      'skip': 'رد شدن',
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
      'asr_calculation': 'محاسبه عصر',
      'asr_shafi': 'استاندارد (شافعی، مالکی، حنبلی)',
      'asr_hanafi': 'حنفی',
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
      'sunrise': 'طلوع آفتاب',
      'tomorrow_fajr': 'فجر فردا',
      'location_not_found':
          '"{city}" پیدا نشد. املای دیگری امتحان کنید یا نام کشور را اضافه کنید.',
      'location_services_disabled': 'خدمات مکان‌یابی خاموش است',
      'location_permission_denied':
          'برای نمایش اوقات نماز در محل شما به اجازه مکان نیاز است.',
      'location_permission_denied_forever':
          'اجازه مکان مسدود است. آن را در تنظیمات برنامه فعال کنید یا شهر را دستی وارد کنید.',
      'location_timeout': 'مکان شما به‌موقع پیدا نشد.',
      'location_access_required': 'دسترسی به مکان لازم است',
      'open_settings': 'باز کردن تنظیمات',
      'grant_access_retry': 'اجازه و تلاش دوباره',
      'set_manual_location_hint': 'یا شهر را در تنظیمات دستی وارد کنید.',
      'locating': 'در حال یافتن مکان...',
      'location_unavailable': 'مکان در دسترس نیست',
      'prayer_not_started': 'وقت {prayer} هنوز نرسیده است.',
      'prayer_already_logged': '{prayer} امروز قبلاً ثبت شده است.',
      'prayer_notification_title': 'وقت {prayer}',
      'prayer_notification_body': 'اکنون وقت نماز {prayer} است.',
      'pulse_load_failed': 'بارگیری نبض معنوی ممکن نشد.',
      'names_99_short': '۹۹ نام',
      'duas_short': 'دعاها',
      'tasbeeh_short': 'تسبیح',
      'badge_first_step': 'نخستین گام',
      'badge_first_step_desc': 'نخستین فعالیت خود را ثبت کردید',
      'badge_streak_7': 'هفت روز پیاپی',
      'badge_streak_7_desc': 'هفت روز پشت سر هم فعال بودید',
      'badge_streak_30': 'استاد ماه',
      'badge_streak_30_desc': 'سی روز پشت سر هم فعال بودید',
      'badge_streak_100': 'استوار',
      'badge_streak_100_desc': 'صد روز پشت سر هم فعال بودید',
      'badge_daily_achiever': 'دستاورد روزانه',
      'badge_daily_achiever_desc': 'در یک روز به ۱۰۰ امتیاز رسیدید',
      'badge_spiritual_veteran': 'کهنه‌کار معنوی',
      'badge_spiritual_veteran_desc': '۵۰ فعالیت ثبت کردید',
      'badge_points_1000': '۱۰۰۰ امتیاز',
      'badge_points_1000_desc': 'در مجموع ۱۰۰۰ امتیاز کسب کردید',
      'no_badges_yet': 'با ادامهٔ استفاده از برنامه نشان بگیرید!',
      'badges_earned': '{n} نشان کسب شده',
      'motivation_achieved': 'ماشاءالله! به اهداف معنوی امروزتان رسیدید. ✨',
      'motivation_almost': 'پیشرفت عالی! کمی دیگر تا هدفتان مانده است. 🚀',
      'motivation_halfway': 'نیمی از راه را رفته‌اید! ادامه دهید. 💪',
      'motivation_started': 'شروع خوبی است! به سوی اهدافتان ادامه دهید. ⚡',
      'motivation_start':
          'سفر معنوی امروزتان را آغاز کنید. هر قدم ارزشمند است! 🌱',
      'method_mwl': 'رابطهٔ جهان اسلام',
      'method_karachi': 'دانشگاه علوم اسلامی کراچی',
      'method_isna': 'انجمن اسلامی آمریکای شمالی (ISNA)',
      'method_umm_al_qura': 'دانشگاه ام‌القری، مکه',
      'method_egyptian': 'سازمان عمومی نقشه‌برداری مصر',
      'method_dubai': 'دبی (امارات)',
      'method_qatar': 'قطر',
      'method_kuwait': 'کویت',
      'method_turkey': 'دیانت (ترکیه)',
      'method_tehran': 'مؤسسهٔ ژئوفیزیک دانشگاه تهران',
      'method_singapore': 'سنگاپور، مالزی و اندونزی',
      'method_moonsighting': 'کمیتهٔ جهانی رؤیت هلال',
      'unknown_city': 'مکان نامشخص',
      'daily_challenges': 'چالش‌های امروز',
      'challenges_hint': 'با استفاده از برنامه خودکار کامل می‌شوند',
      'challenge_prayers': 'هر پنج نماز را بخوانید',
      'challenge_quran': 'از قرآن بخوانید',
      'challenge_dhikr': '۳۳ ذکر با تسبیح بگویید',
      'challenges_all_done': 'ماشاءالله! همه چالش‌های امروز انجام شد',
      'perfect_days_week': 'روزهای کامل این هفته: {n}/7',
      'quran_font': 'قلم قرآن',
      'quran_font_note': 'هر قلم فقط یک بار، در اولین استفاده، دانلود می‌شود.',
      'night_rec_title': 'پیش از خواب',
      'night_rec_subtitle': 'از سنت پیامبر ﷺ',
      'friday_rec_title': 'جمعه مبارک',
      'friday_rec_subtitle': 'روز جمعه سوره کهف را بخوانید',
      'rec_ayat_kursi': 'آیة الکرسی',
      'rec_baqarah_end': 'دو آیه آخر سوره بقره',
      'rec_mulk': 'سوره ملک',
      'rec_quls': 'چهار قل',
      'rec_waqiah': 'سوره واقعه',
      'rec_muzzammil': 'سوره مزمل',
      'rec_kahf': 'سوره کهف',
      'rec_also_common': 'بسیاری این‌ها را هم می‌خوانند',
      'mark_done': 'انجام شد',
      'mark_not_done': 'انجام نشده',
      'night_reminder': 'یادآوری تلاوت‌های شب',
      'night_reminder_desc': 'یک ساعت بعد از عشا',
      'kahf_reminder': 'سوره کهف در روز جمعه',
      'kahf_reminder_desc': 'صبح جمعه',
      'night_reminder_title': 'پیش از خواب 🌙',
      'night_reminder_body': 'آیة الکرسی، سوره ملک و چهار قل',
      'kahf_reminder_title': 'جمعه مبارک',
      'kahf_reminder_body': 'امروز خواندن سوره کهف را فراموش نکنید',
      'playback_speed': 'سرعت پخش',
      'mushaf': 'مصحف',
      'page_n': 'صفحه {n}',
      'juz_n': 'جزء {n}',
      'mushaf_tap_hint': 'روی یک آیه بزنید تا ترجمه‌اش را ببینید، پخش یا ذخیره کنید',
      'play_from_here': 'پخش از اینجا',
      'send_feedback': 'ارسال بازخورد',
      'send_feedback_desc': 'گزارش مشکل یا پیشنهاد ایده',
      'feedback_no_email_app': 'برنامه ایمیل پیدا نشد. به {email} پیام دهید',
      'adhan_help': 'اذان دیر می‌آید یا نمی‌آید؟',
      'adhan_help_desc': 'تنظیمات گوشی که ممکن است یادآورها را متوقف کند',
      'adhan_help_body': 'برخی گوشی‌ها (مثلاً Vivo، Oppo، Xiaomi، Infinix و Samsung) برای صرفه‌جویی در باتری، برنامه‌ها را در پس‌زمینه متوقف می‌کنند و این می‌تواند اذان را دیر کند یا متوقف کند.\n\n۱. از دکمه زیر تنظیمات برنامه را باز کنید.\n۲. باتری: «بدون محدودیت» را انتخاب کنید.\n۳. اگر گوشی شما گزینه «اجرای خودکار» یا «فعالیت در پس‌زمینه» دارد، آن را برای Barakah Time روشن کنید.\n۴. مطمئن شوید اعلان‌ها مجاز هستند.\n\nسپس یک بار Barakah Time را باز کنید تا یادآورها دوباره تنظیم شوند.',
      'refresh_location': 'به‌روزرسانی مکان',
      'location_updated': 'مکان به‌روز شد',
      'default_user_name': 'کاربر برکت',
      'sign_in_with_apple': 'ورود با Apple',
      'continue_as_guest': 'فعلاً نه',
      'guest_mode_notice':
          'همه امکانات بدون حساب کار می‌کنند. فقط اگر می‌خواهید از پیشرفت خود پشتیبان بگیرید و در دستگاه‌های دیگر استفاده کنید، وارد شوید.',
      'sign_in_to_sync': 'برای همگام‌سازی وارد شوید',
      'auth_unavailable_notice':
          'ورود در حال حاضر در دسترس نیست. می‌توانید به استفاده ادامه دهید؛ داده‌ها روی همین دستگاه می‌مانند.',
      'err_auth_unavailable':
          'ورود در حال حاضر ممکن نیست. اتصال را بررسی کرده و برنامه را دوباره باز کنید.',
      'err_apple_failed': 'ورود با Apple ناموفق بود. دوباره تلاش کنید.',
      'err_user_disabled': 'این حساب غیرفعال شده است.',
      'err_account_exists_different_provider':
          'حسابی با این ایمیل و روش ورود دیگری وجود دارد.',
      'err_user_mismatch': 'لطفاً با همان حسابی که حذف می‌کنید وارد شوید.',
      'session_expired': 'از حساب خارج شدید. لطفاً دوباره وارد شوید.',
      'email_not_verified':
          'ایمیل شما هنوز تأیید نشده است. صندوق ورودی را برای پیوند تأیید بررسی کنید.',
      'resend_verification': 'ارسال دوبارهٔ ایمیل تأیید',
      'verification_link_resent':
          'ایمیل تأیید ارسال شد. صندوق ورودی را بررسی کنید.',
      'delete_account': 'حذف حساب',
      'delete_confirm_word': 'حذف',
      'delete_account_confirm_title': 'حساب خود را حذف می‌کنید؟',
      'delete_account_confirm_message':
          'این کار حساب، پیشرفت، نشان‌ها، آیات ذخیره‌شده و عکس پروفایل شما را برای همیشه حذف می‌کند و قابل بازگشت نیست.',
      'reauth_required_delete':
          'برای امنیت، لطفاً برای حذف حساب ورود خود را تأیید کنید.',
      'confirm_with_password': 'برای ادامه رمز عبور را وارد کنید',
      'confirm_with_provider': 'تأیید با {provider}',
      'account_deleted': 'حساب شما حذف شد.',
      'err_delete_account_failed': 'حذف حساب ممکن نشد. دوباره تلاش کنید.',
      'lifetime_points': 'امتیاز کل',
      'longest_streak': 'طولانی‌ترین پیاپی',
      'adhan_sound': 'صدای اذان',
      'adhan_sound_desc': 'پخش اذان برای یادآوری نماز',
      'adjust_times': 'تنظیم اوقات نماز',
      'app_theme': 'پوسته',
      'theme_system': 'پیش‌فرض سیستم',
      'theme_light': 'روشن',
      'theme_dark': 'تیره',
      'adjust_times_desc': 'هر نماز را با مسجد محل هماهنگ کنید',
      'adjust_times_none': 'بدون تغییر',
      'minutes_short': '{n} دقیقه',
      'adjust_times_note':
          'اوقات نسبت به زمان محاسبه‌شده جابه‌جا می‌شوند. فقط اگر مسجد محل شما متفاوت است از این استفاده کنید.',
      'exact_alarms_hint':
          'اجازهٔ «زنگ‌ها و یادآورها» را بدهید تا یادآوری نماز دقیقاً سر وقت برسد.',
      'notifications_permission_revoked':
          'اجازهٔ اعلان در تنظیمات سیستم خاموش شد، بنابراین یادآوری نماز غیرفعال شد.',
      'good_morning': 'صبح بخیر',
      'good_afternoon': 'ظهر بخیر',
      'good_evening': 'عصر بخیر',
      'assalamualaikum': 'السلام علیکم',
      'hijri_year_suffix': 'ق',
      'hijri_month_1': 'محرم',
      'hijri_month_2': 'صفر',
      'hijri_month_3': 'ربیع‌الاول',
      'hijri_month_4': 'ربیع‌الثانی',
      'hijri_month_5': 'جمادی‌الاول',
      'hijri_month_6': 'جمادی‌الثانی',
      'hijri_month_7': 'رجب',
      'hijri_month_8': 'شعبان',
      'hijri_month_9': 'رمضان',
      'hijri_month_10': 'شوال',
      'hijri_month_11': 'ذی‌القعده',
      'hijri_month_12': 'ذی‌الحجه',
      'qibla_short': 'قبله',
      'calendar_short': 'تقویم',
      'more': 'بیشتر',
      'read_full_ayah': 'خواندن کامل آیه',
      'shared_from_app': 'به اشتراک گذاشته شده از Barakah Time',
      'pulse_share_text':
          'پیشرفت من در Barakah Time: {streak} روز پیاپی و {points} امتیاز در این هفته.',
      'points_this_week': 'امتیاز این هفته',
      'current_streak': 'پیاپی فعلی',
      'day_streak_count': '{n} روز پیاپی',
      'weekday_points': '{day}: {n} امتیاز',
      'recent_activity': 'فعالیت‌های اخیر',
      'no_recent_activity':
          'هنوز فعالیتی ثبت نشده. برای شروع یک نماز ثبت کنید، قرآن بخوانید یا ذکر بگویید.',
      'activity_prayer': 'نماز {prayer}',
      'activity_quran': 'تلاوت قرآن',
      'activity_dhikr': 'ذکر',
      'activity_other': 'فعالیت',
      'points_gained': '+{n} امتیاز',
      'prayer_logged_semantics': '{prayer} ثبت شد',
      'log_prayer_semantics': 'ثبت {prayer}',
      'prayer_in_label': '{prayer} تا',
      'cardinal_n': 'شمال',
      'cardinal_e': 'شرق',
      'cardinal_s': 'جنوب',
      'cardinal_w': 'غرب',
      'qibla_semantics_right': 'قبله {deg} درجه در سمت راست شماست',
      'qibla_semantics_left': 'قبله {deg} درجه در سمت چپ شماست',
      'qibla_semantics_ahead': 'قبله دقیقاً روبه‌روی شماست',
      'qibla_compass': 'قطب‌نمای قبله',
      'logged': 'ثبت شد',
    },
    'ur': {
      'pulse_today': 'آج',
      'pulse_today_prayers': 'آج کی نمازیں',
      'badge_locked': 'مقفل',
      'audio_error_voice_missing':
          "فون میں اس زبان کی آواز نہیں ہے۔ فون کی سیٹنگز ← ٹیکسٹ ٹو اسپیچ سے انسٹال کریں۔",
      'quran_translation_language': 'ترجمے کی زبان',
      'quran_translation_same_as_app': 'ایپ والی زبان',
      'quran_translation_audio_note':
          'اردو، انگریزی، فارسی اور ترکی ترجمہ انسانی آواز میں سنایا جاتا ہے۔',
      'audio_error_play': 'آڈیو نہیں چل سکی۔ نئی تلاوت پہلی بار سننے کے لیے انٹرنیٹ چاہیے، جو آپ پہلے سن چکے ہیں وہ انٹرنیٹ کے بغیر بھی چلتی ہے۔',
      'audio_error_speech': 'آواز میں پڑھائی نہیں چل سکی',
      'name_too_long': 'نام 100 حروف سے زیادہ نہیں ہو سکتا',
      'reminders_need_notifications':
          'پہلے سیٹنگز میں نماز کی نوٹیفکیشنز آن کریں۔',
      'ramadan_title': 'رمضان',
      'ramadan_day_of': '{len} میں سے {day}واں روزہ',
      'ramadan_starts_in': '{n} دن میں شروع',
      'ramadan_qadr_tonight':
          'آج کی رات لیلۃ القدر ہو سکتی ہے۔ اسے عبادت اور دعا میں گزاریں۔',
      'ramadan_moon_adjust': 'چاند کے حساب سے تبدیلی (دن)',
      'ramadan_need_location':
          'سحری اور افطار کے اوقات دیکھنے کے لیے نماز کے اوقات لوڈ کریں۔',
      'ramadan_sehri_ends_in': 'سحری ختم ہونے میں',
      'ramadan_iftar_in': 'افطار میں',
      'ramadan_sehri_ends': 'سحری ختم',
      'ramadan_iftar': 'افطار',
      'ramadan_reminders': 'سحری اور افطار کی یاد دہانی',
      'ramadan_reminders_desc':
          'سحری ختم ہونے سے 30 منٹ پہلے، اور افطار کے وقت',
      'ramadan_duas': 'رمضان کی دعائیں',
      'ramadan_sehri_niyyah': 'روزے کی نیت (سحری)',
      'ramadan_sehri_niyyah_meaning': 'میں نے کل کے رمضان کے روزے کی نیت کی۔',
      'ramadan_iftar_dua': 'افطار کی دعا',
      'ramadan_iftar_dua_meaning':
          'اے اللہ! میں نے تیرے لیے روزہ رکھا، تجھ پر ایمان لایا، تجھ پر بھروسہ کیا، اور تیرے رزق سے افطار کیا۔',
      'ramadan_iftar_dua2': 'روزہ کھولنے کے بعد',
      'ramadan_iftar_dua2_meaning':
          'پیاس بجھ گئی، رگیں تر ہو گئیں، اور اگر اللہ نے چاہا تو اجر ثابت ہو گیا۔ (ابو داؤد)',
      'ramadan_qadr_dua': 'لیلۃ القدر کی دعا',
      'ramadan_qadr_dua_meaning':
          'اے اللہ! تو معاف کرنے والا ہے، معافی کو پسند کرتا ہے، پس مجھے معاف فرما دے۔ (ترمذی)',
      'ramadan_log': 'روزوں کا ریکارڈ',
      'ramadan_fasted': 'روزہ رکھا',
      'ramadan_missed': 'قضا',
      'ramadan_taraweeh': 'تراویح',
      'ramadan_log_hint':
          'روزہ اور تراویح درج کرنے کے لیے دن پر ٹیپ کریں۔ ستارے آخری عشرے کی طاق راتیں ہیں۔',
      'ramadan_qaza_fasts': '{n} روزوں کی قضا باقی ہے',
      'ramadan_day': 'دن',
      'ramadan_not_set': 'صاف کریں',
      'ramadan_prayed_taraweeh': 'تراویح پڑھی',
      'ramadan_prepare': 'تیاری کریں: قرآن، دعاؤں اور صدقے کا منصوبہ بنائیں۔',
      'ramadan_sehri_reminder_title': 'سحری 30 منٹ میں ختم',
      'ramadan_sehri_reminder_body':
          'سحری {time} پر ختم ہوگی۔ نیت کرنا نہ بھولیں۔',
      'ramadan_iftar_reminder_title': 'افطار کا وقت ہو گیا',
      'ramadan_iftar_reminder_body':
          'روزہ افطار کریں اور دعا مانگیں۔ افطار کے وقت دعا قبول ہوتی ہے۔',
      'memorial_title': 'ایصالِ ثواب',
      'memorial_tool_subtitle': 'مرحومین کے لیے',
      'memorial_sign_in':
          'کسی عزیز کے لیے ایصالِ ثواب کا صفحہ بنانے یا اس میں شامل ہونے کے لیے سائن ان کریں۔',
      'memorial_intro':
          'کسی مرحوم عزیز کا صفحہ بنائیں اور واٹس ایپ پر شیئر کریں۔ گھر والے اور دوست پارے لے کر ختمِ قرآن مکمل کر سکتے ہیں، مل کر ذکر کا ہدف پورا کر سکتے ہیں، اور ان کے لیے نیک اعمال لکھ سکتے ہیں۔',
      'memorial_create': 'صفحہ بنائیں',
      'memorial_join': 'کوڈ سے شامل ہوں',
      'memorial_none':
          'ابھی کوئی صفحہ نہیں۔ نیا بنائیں یا کسی کے بھیجے ہوئے کوڈ سے شامل ہوں۔',
      'memorial_you_created': 'آپ نے بنایا',
      'memorial_joined': 'شامل',
      'memorial_code_invalid': '8 حروف والا کوڈ درج کریں',
      'memorial_code': 'کوڈ',
      'memorial_join_button': 'شامل ہوں',
      'memorial_name_required': 'نام درج کریں',
      'memorial_name': 'مرحوم کا نام',
      'memorial_subtitle': 'رشتہ یا نوٹ (اختیاری)',
      'memorial_subtitle_hint': 'مثلاً احمد کے والد',
      'memorial_death_date': 'تاریخِ وفات',
      'memorial_optional': 'اختیاری',
      'memorial_show_dates': 'یاد کے دن دکھائیں',
      'memorial_show_dates_desc': 'سوئم، دسواں، چہلم اور برسی',
      'memorial_goals': 'ذکر کے ہدف',
      'memorial_goal': 'ہدف',
      'memorial_error_not_found': 'اس کوڈ کا کوئی صفحہ نہیں ملا۔',
      'memorial_error_para_taken':
          'یہ پارہ ابھی کسی نے لے لیا۔ براہ کرم کوئی اور چنیں۔',
      'memorial_error_generic':
          'کچھ غلط ہو گیا۔ انٹرنیٹ چیک کر کے دوبارہ کوشش کریں۔',
      'memorial_deleted': 'یہ صفحہ حذف ہو چکا ہے۔',
      'memorial_remove_from_list': 'میری فہرست سے ہٹائیں',
      'memorial_created_hint':
          'صفحہ بن گیا۔ اسے گھر والوں اور دوستوں سے شیئر کریں۔',
      'memorial_share': 'شیئر',
      'memorial_share_text':
          '{name} کے ایصالِ ثواب میں شامل ہوں۔ Barakah Time ایپ میں ان کے لیے قرآن کا ایک پارہ پڑھیں یا ذکر کریں۔\n\nکوڈ: {code}\n\nایپ حاصل کریں: {link}',
      'memorial_para': 'پارہ {n}',
      'memorial_take_para_confirm':
          'آپ یہ پارہ مرحوم کے لیے پڑھیں گے۔ باقی لوگ دیکھ سکیں گے کہ یہ آپ نے لیا ہے۔',
      'memorial_take_para': 'یہ پارہ لیں',
      'memorial_para_read_by': 'پارہ {n} {name} نے پڑھا',
      'memorial_para_taken_by': 'پارہ {n} {name} پڑھ رہے ہیں',
      'memorial_para_yours': 'یہ پارہ آپ پڑھ رہے ہیں',
      'memorial_mark_read': 'میں نے پڑھ لیا',
      'memorial_release_para': 'واپس کریں',
      'memorial_khatam_done':
          'ختم مکمل ہو گیا۔ الحمدللہ! نیا ختم شروع ہو گیا ہے۔',
      'memorial_para_done': 'جزاک اللہ خیر۔ اللہ قبول فرمائے۔',
      'memorial_how_many': 'کتنی بار؟',
      'memorial_added': 'شامل ہو گیا۔ جزاک اللہ خیر۔',
      'memorial_delete': 'صفحہ حذف کریں',
      'memorial_delete_confirm':
          'یہ صفحہ سب کے لیے حذف ہو جائے گا، ساری پیش رفت سمیت۔ یہ واپس نہیں ہو سکتا۔',
      'memorial_add_deed': 'نیک عمل یا دعا لکھیں',
      'memorial_deed_hint': 'مثلاً 10 لوگوں کو کھانا کھلایا، یا ان کے لیے دعا',
      'memorial_dates': 'یاد کے دن',
      'memorial_activity': 'سرگرمی',
      'memorial_code_copied': 'کوڈ کاپی ہو گیا',
      'memorial_invite': 'دعوت دیں',
      'memorial_khatam_n': 'ختم {n}',
      'memorial_khatams_completed': '{n} ختم مکمل',
      'memorial_khatam_hint':
          'مرحوم کے لیے پڑھنے کو کسی خالی پارے پر ٹیپ کریں۔',
      'memorial_free': 'خالی',
      'memorial_yours': 'آپ کا',
      'memorial_taken': 'لیا ہوا',
      'memorial_read': 'پڑھ لیا',
      'memorial_add_count': 'شامل کریں',
      'memorial_remind_me': 'ان دنوں یاد دلائیں',
      'memorial_feed_para': '{name} نے پارہ {n} پڑھا',
      'memorial_feed_khatam': 'ختم {n} مکمل ہوا۔ الحمدللہ!',
      'memorial_feed_dhikr': '{name} نے {dhikr} {count} بار پڑھا',
      'memorial_feed_empty': 'ابھی کچھ نہیں۔ سب سے پہلے حصہ ڈالیں۔',
      'memorial_day3': 'سوئم (تیسرا دن)',
      'memorial_day10': 'دسواں',
      'memorial_day40': 'چہلم (چالیسواں)',
      'memorial_barsi': 'برسی',
      'memorial_reminder_title': '{name} کا {day}',
      'memorial_reminder_body':
          'آج {name} کو قرآن، دعا یا صدقے کے ساتھ یاد کریں۔',
      'dhikr_kareema': 'آیتِ کریمہ',
      'dhikr_darood': 'درود شریف',
      'dhikr_kalma': 'کلمہ طیبہ',
      'dhikr_ikhlas': 'سورۃ اخلاص',
      'dhikr_yaseen': 'سورۃ یٰسین',
      'dhikr_istighfar': 'استغفار',
      'widget_empty': 'نماز کے اوقات لوڈ کرنے کے لیے Barakah Time کھولیں',
      'promise_title': 'ہمارا وعدہ',
      'promise_no_ads': 'کبھی کوئی اشتہار نہیں',
      'promise_no_sell': 'ہم آپ کا ڈیٹا کبھی نہ بیچتے ہیں نہ کسی کو دیتے ہیں',
      'promise_no_tracking': 'کوئی ٹریکر یا اینالیٹکس نہیں',
      'promise_location':
          'آپ کی لوکیشن صرف نماز کے اوقات، قبلہ اور قریبی مساجد کے لیے استعمال ہوتی ہے',
      'onboarding_privacy_title': 'کوئی اشتہار نہیں۔ آپ کا ڈیٹا آپ کا ہے۔',
      'onboarding_privacy_desc':
          'Barakah Time میں نہ اشتہار ہیں نہ ٹریکر، اور ہم آپ کا ڈیٹا کبھی نہیں بیچتے۔ آپ کی عبادت آپ اور اللہ کے درمیان ہے۔',
      'qaza_tracker': 'قضا نماز ٹریکر',
      'witr': 'وتر',
      'qaza_intro_title': 'قضا نمازیں ادا کریں',
      'qaza_intro_body':
          'اندازہ لگائیں کہ آپ کی کتنی نمازیں قضا ہیں، پھر انہیں ایک ایک کر کے ادا کریں۔ آپ کی پیش رفت محفوظ ہو کر آپ کے اکاؤنٹ سے سنک ہوتی ہے۔',
      'qaza_calculate': 'قضا نمازوں کا اندازہ',
      'qaza_enter_manually': 'تعداد خود درج کریں',
      'qaza_remaining': 'باقی',
      'qaza_made_up': 'ادا شدہ',
      'qaza_progress': '{p}% ادا ہو چکیں',
      'qaza_pray_one': 'ایک قضا ادا کی',
      'qaza_logged': '{prayer} کی ایک قضا ادا ہو گئی',
      'qaza_edit_title': 'باقی {prayer}',
      'qaza_invalid': '0 سے 60000 تک کوئی عدد درج کریں',
      'qaza_years': 'سال',
      'qaza_months': 'مہینے',
      'qaza_days': 'دن',
      'qaza_include_witr': 'وتر شامل کریں (حنفی)',
      'qaza_calc_desc':
          'آپ کی نمازیں کتنے عرصے قضا ہوئیں؟ مثلاً بالغ ہونے سے لے کر باقاعدہ نماز شروع کرنے تک۔',
      'qaza_calc_result': 'ہر نماز کی {n} قضا شامل ہوں گی',
      'qaza_estimate_note':
          'احتیاطاً ایک سال 365 دن کا شمار کیا جاتا ہے۔ شک ہو تو کسی عالم سے پوچھ لیں۔',
      'qaza_add': 'ٹریکر میں شامل کریں',
      'qaza_reset': 'ٹریکر ری سیٹ کریں',
      'qaza_reset_confirm':
          'تمام تعداد اور پیش رفت مٹ جائے گی۔ یہ واپس نہیں ہو سکتا۔',
      'qaza_all_done': 'تمام قضا نمازیں ادا ہو گئیں۔ الحمدللہ!',
      'qaza_tool_subtitle': 'قضا نمازیں',
      // Auth / onboarding / profile / settings / about pages
      'app_tagline': 'اپنے وقت میں برکت لائیں',
      'onboarding_pulse_title': 'روحانی نبض',
      'onboarding_pulse_desc':
          'اپنی روحانی مستقل مزاجی کو ٹریک کریں اور دیرپا عادتیں بنائیں۔ جڑے رہیں، ثابت قدم رہیں۔',
      'onboarding_prayer_title': 'کوئی نماز نہ چھوٹے',
      'onboarding_prayer_desc':
          'آپ کے مقام کے مطابق درست اوقاتِ نماز، لائیو کاؤنٹ ڈاؤن اور یاد دہانیاں۔',
      'onboarding_inspiration_title': 'روزانہ کی تحریک',
      'onboarding_inspiration_desc':
          'روزانہ آیات، اللہ کے 99 نام، دعاؤں اور بہت کچھ کے ساتھ سکون پائیں۔',
      'onboarding_next': 'اگلا',
      'onboarding_get_started': 'شروع کریں',
      'auth_welcome_back': 'خوش آمدید',
      'auth_sign_in_subtitle': 'اپنا روحانی سفر جاری رکھنے کے لیے سائن ان کریں',
      'auth_email_address': 'ای میل ایڈریس',
      'auth_password': 'پاس ورڈ',
      'auth_sign_in': 'سائن ان',
      'auth_or': 'یا',
      'auth_no_account': 'اکاؤنٹ نہیں ہے؟',
      'auth_sign_up': 'سائن اپ',
      'auth_create_account': 'اکاؤنٹ بنائیں',
      'auth_sign_up_subtitle': 'ہماری کمیونٹی میں شامل ہوں اور مل کر آگے بڑھیں',
      'auth_full_name': 'پورا نام',
      'auth_register': 'رجسٹر کریں',
      'auth_have_account': 'پہلے سے اکاؤنٹ ہے؟',
      'auth_account_created_verify':
          'اکاؤنٹ بن گیا! ہم نے {email} پر تصدیقی لنک بھیج دیا ہے۔',
      'profile_saved_verses': 'محفوظ آیات',
      'profile_saved_count': '{n} محفوظ',
      'profile_activity_history': 'سرگرمیوں کی تاریخ',
      'profile_last_activity': 'آخری: {activity}',
      'profile_no_saved_verses':
          'ابھی کوئی آیت محفوظ نہیں۔ کسی بھی آیت پر بُک مارک دبا کر اسے یہاں محفوظ کریں۔',
      'profile_remove_verse': 'محفوظ سے ہٹائیں',
      'profile_undo': 'واپس کریں',
      'profile_change_photo': 'تصویر تبدیل کریں',
      'profile_take_photo': 'تصویر کھینچیں',
      'profile_choose_gallery': 'گیلری سے منتخب کریں',
      'profile_guest_title': 'خوش آمدید',
      'profile_yesterday': 'کل',
      'settings_account': 'اکاؤنٹ',
      'settings_prayer': 'نماز',
      'settings_support_us': 'ہمارے کام کی حمایت کریں',
      'settings_version': 'ورژن {v}',
      'about_title': 'برکت ٹائم کے بارے میں',
      'about_description':
          'نماز کے اوقات، قرآن، ذکر اور روزانہ روحانی ترقی کے لیے ایک اسلامی ساتھی، جو آپ کے وقت میں برکت لانے کے لیے بنایا گیا ہے۔',
      'about_credits': 'کریڈٹس اور ڈیٹا کے ذرائع',
      'about_quran_data': 'قرآن کا متن، تراجم اور آڈیو',
      'about_map_data': 'نقشہ اور مقامات کا ڈیٹا',
      'about_map_license':
          '© OpenStreetMap کے معاونین، اوپن ڈیٹابیس لائسنس (ODbL) کے تحت دستیاب',
      'about_prayer_calc': 'اوقاتِ نماز کا حساب',
      'about_prayer_calc_source': 'adhan لائبریری (اوپن سورس)',
      'about_privacy': 'رازداری کی پالیسی',
      'about_terms': 'سروس کی شرائط',
      'about_licenses': 'اوپن سورس لائسنس',
      'about_made_with_love': 'امت کے لیے ❤️ سے بنایا گیا',
      'about_link_failed': 'لنک نہیں کھل سکا۔ براہِ کرم بعد میں کوشش کریں۔',
      'search_surahs': 'نام یا نمبر سے تلاش کریں',
      'continue_reading': 'پڑھنا جاری رکھیں',
      'no_surahs_found': 'آپ کی تلاش سے کوئی سورت نہیں ملی',
      'meccan': 'مکی',
      'medinan': 'مدنی',
      'verse_saved': 'آیت محفوظ ہو گئی',
      'verse_removed': 'آیت محفوظ شدہ سے ہٹا دی گئی',
      'save_verse': 'آیت محفوظ کریں',
      'remove_saved_verse': 'محفوظ شدہ سے ہٹائیں',
      'share_ayah_heading': 'سورہ {surah} کی آیت {ayah}',
      'copy': 'کاپی کریں',
      'copied': 'کاپی ہو گیا',
      'meaning': 'معنی',
      'transliteration': 'تلفظ',
      'name_number': '99 میں سے نام نمبر {n}',
      'alhamdulillah': 'الحمد للہ',
      'allahu_akbar': 'اللہ اکبر',
      'astaghfirullah': 'استغفر اللہ',
      'la_ilaha_illallah': 'لا الہ الا اللہ',
      'tasbeeh_target': 'ہدف',
      'tasbeeh_custom': 'اپنی مرضی',
      'tasbeeh_custom_target': 'اپنی مرضی کا ہدف',
      'tasbeeh_round': 'دور {n}',
      'tasbeeh_total': 'کل: {n}',
      'tasbeeh_target_reached': 'ہدف مکمل ہو گیا!',
      'tasbeeh_counter_semantics': 'گنتی: {count}۔ گننے کے لیے ٹیپ کریں۔',
      'tasbeeh_target_invalid': '1 سے 9999 تک کوئی عدد درج کریں',
      'zakat_currency': 'کرنسی (اختیاری)',
      'zakat_currency_hint': 'مثلاً PKR، USD',
      'distance_m': '{n} میٹر',
      'distance_km': '{n} کلومیٹر',
      'osm_attribution': '© OpenStreetMap contributors',
      'dua_before_sleeping': 'سونے سے پہلے',
      'dua_waking_up': 'جاگنے پر',
      'dua_before_eating': 'کھانے سے پہلے',
      'dua_after_eating': 'کھانے کے بعد',
      'dua_entering_home': 'گھر میں داخل ہوتے وقت',
      'dua_leaving_home': 'گھر سے نکلتے وقت',
      'dua_entering_mosque': 'مسجد میں داخل ہوتے وقت',
      'dua_leaving_mosque': 'مسجد سے نکلتے وقت',
      'dua_for_parents': 'والدین کے لیے',
      'dua_for_knowledge': 'علم میں اضافے کے لیے',
      'dua_forgiveness': 'استغفار (معافی کے لیے)',
      'dua_entering_washroom': 'بیت الخلاء میں داخل ہوتے وقت',
      'dua_leaving_washroom': 'بیت الخلاء سے نکلتے وقت',
      'dua_before_wudu': 'وضو سے پہلے',
      'dua_after_wudu': 'وضو کے بعد',
      'dua_traveling': 'سفر کی دعا',
      'dua_morning_evening': 'صبح و شام کا ذکر',
      'dua_protection': 'حفاظت کے لیے',
      'dua_ayatul_kursi': 'آیت الکرسی (نماز کے بعد)',
      'dua_mirror': 'آئینہ دیکھتے وقت',
      'dua_wearing_clothes': 'کپڑے پہنتے وقت',
      'clear_search': 'تلاش صاف کریں',
      'confirm': 'تصدیق کریں',
      'continue_with_apple': 'Apple کے ساتھ جاری رکھیں',
      'continue_with_google': 'Google کے ساتھ جاری رکھیں',
      'dismiss': 'بند کریں',
      'hide_password': 'پاس ورڈ چھپائیں',
      'loading': 'لوڈ ہو رہا ہے…',
      'show_password': 'پاس ورڈ دکھائیں',
      'something_went_wrong': 'کچھ غلط ہو گیا۔ دوبارہ کوشش کریں۔',
      'type_to_confirm': 'تصدیق کے لیے {text} ٹائپ کریں',
      'all_tools': 'تمام ٹولز',
      'ayah': 'آیت',
      'ayahs': 'آیات',
      'calibrate_compass':
          'اگر سمت غلط لگے تو کمپاس کیلیبریٹ کرنے کے لیے فون کو 8 کی شکل میں گھمائیں۔',
      'compass_unavailable':
          'اس ڈیوائس پر کمپاس دستیاب نہیں — شمال کی طرف رخ کریں، پھر دکھائے گئے زاویے پر مڑیں۔',
      'could_not_open_maps': 'نقشہ نہیں کھل سکا',
      'degrees_from_north': 'شمال سے {deg}°',
      'detecting_location': 'مقام معلوم کیا جا رہا ہے...',
      'directions': 'راستہ',
      'facing_qibla': 'آپ کا رخ قبلہ کی طرف ہے',
      'finding_mosques': 'قریبی مساجد تلاش کی جا رہی ہیں...',
      'in_days': '{n} دن میں',
      'listen_translation': 'ترجمہ سنیں',
      'location_error_message':
          'آپ کا مقام معلوم نہیں ہو سکا۔ لوکیشن سروس اور اجازت فعال کریں، پھر دوبارہ کوشش کریں۔',
      'mark_as_read': 'پڑھا ہوا نشان زد کریں',
      'mosques_load_error':
          'قریبی مساجد لوڈ نہیں ہو سکیں۔ انٹرنیٹ کنکشن چیک کریں۔',
      'no_mosques_match': 'آپ کی تلاش سے کوئی مسجد نہیں ملی',
      'no_mosques_nearby': '5 کلومیٹر کے اندر کوئی مسجد نہیں ملی',
      'now_playing': 'چل رہا ہے',
      'open_in_maps': 'نقشے میں کھولیں',
      'pause': 'روکیں',
      'play': 'چلائیں',
      'play_surah': 'سورہ چلائیں',
      'quran_load_error':
          'قرآن لوڈ نہیں ہو سکا۔ انٹرنیٹ کنکشن چیک کریں اور دوبارہ کوشش کریں۔',
      'reset_counter_message':
          'کاؤنٹر 0 پر واپس چلا جائے گا۔ اب تک کا ذکر روحانی پلس میں محفوظ ہو جائے گا۔',
      'reset_counter_title': 'کاؤنٹر ری سیٹ کریں؟',
      'share': 'شیئر کریں',
      'stop': 'بند کریں',
      'surah_already_logged_today': 'آج پہلے ہی درج ہو چکی ہے ✓',
      'surah_load_error':
          'یہ سورہ لوڈ نہیں ہو سکی۔ انٹرنیٹ کنکشن چیک کریں اور دوبارہ کوشش کریں۔',
      'surah_logged': 'سورہ {name} درج ہو گئی! ✨',
      'today': 'آج',
      'tomorrow': 'کل',
      'translation': 'ترجمہ',
      'unnamed_mosque': 'مسجد',
      'zakat_above_nisab': 'نصاب ({nisab}) سے زیادہ — زکوٰۃ واجب ہے',
      'zakat_below_nisab': 'نصاب ({nisab}) سے کم — زکوٰۃ واجب نہیں',
      'zakat_gold_nisab': 'سونا (87.48 گرام)',
      'zakat_gold_price': 'سونے کی موجودہ قیمت فی گرام',
      'zakat_invalid_amount': 'درست مثبت عدد درج کریں',
      'zakat_liabilities': 'واجب الادا قرض / ذمہ داریاں',
      'zakat_net_wealth': 'قابلِ زکوٰۃ خالص مال',
      'zakat_nisab_standard': 'نصاب کا معیار',
      'zakat_nisab_unknown': 'نصاب جانچنے کے لیے نیچے دھات کی قیمت درج کریں',
      'zakat_no_wealth': 'قرض کے بعد قابلِ زکوٰۃ مال نہیں — زکوٰۃ واجب نہیں',
      'zakat_silver_nisab': 'چاندی (612.36 گرام)',
      'zakat_silver_price': 'چاندی کی موجودہ قیمت فی گرام',
      'mawlid': 'عید میلاد النبی',
      'isra_miraj': 'شبِ معراج',
      'shab_e_barat': 'شبِ برات',
      'laylat_al_qadr': 'لیلۃ القدر (27ویں شب)',
      'day_of_arafah': 'یومِ عرفہ',
      'name_required': 'براہ کرم اپنا نام درج کریں۔',
      'email_required': 'براہ کرم اپنا ای میل درج کریں۔',
      'invalid_email': 'براہ کرم درست ای میل ایڈریس درج کریں۔',
      'password_required': 'براہ کرم اپنا پاس ورڈ درج کریں۔',
      'password_too_short': 'پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے۔',
      'passwords_do_not_match': 'پاس ورڈ مماثل نہیں ہیں۔',
      'confirm_password': 'پاس ورڈ کی تصدیق کریں',
      'err_user_not_found': 'اس ای میل سے کوئی اکاؤنٹ نہیں ملا۔',
      'err_wrong_credentials': 'ای میل یا پاس ورڈ غلط ہے۔',
      'err_email_in_use': 'اس ای میل سے پہلے ہی ایک اکاؤنٹ موجود ہے۔',
      'err_network': 'نیٹ ورک کی خرابی۔ اپنا کنکشن چیک کریں۔',
      'err_too_many_requests': 'بہت زیادہ کوششیں۔ بعد میں دوبارہ کوشش کریں۔',
      'err_recent_login':
          'حفاظت کے لیے، ای میل تبدیل کرنے سے پہلے سائن آؤٹ کر کے دوبارہ سائن ان کریں۔',
      'err_upload_failed': 'تصویر اپ لوڈ نہیں ہو سکی۔ دوبارہ کوشش کریں۔',
      'err_profile_update_failed':
          'پروفائل اپ ڈیٹ نہیں ہو سکی۔ دوبارہ کوشش کریں۔',
      'err_google_failed': 'Google سائن ان ناکام رہا۔ دوبارہ کوشش کریں۔',
      'profile_updated': 'پروفائل اپ ڈیٹ ہو گئی۔',
      'photo_updated': 'پروفائل تصویر اپ ڈیٹ ہو گئی۔',
      'verification_email_sent':
          'آپ کے نئے ای میل پر تصدیقی لنک بھیج دیا گیا ہے۔ تصدیق کے بعد ای میل اپ ڈیٹ ہو جائے گا۔',
      'forgot_password': 'پاس ورڈ بھول گئے؟',
      'reset_password': 'پاس ورڈ ری سیٹ کریں',
      'reset_password_hint':
          'اپنا ای میل درج کریں، ہم آپ کو پاس ورڈ ری سیٹ کرنے کا لنک بھیجیں گے۔',
      'send_link': 'لنک بھیجیں',
      'reset_email_sent':
          'پاس ورڈ ری سیٹ ای میل بھیج دی گئی۔ اپنا ان باکس چیک کریں۔',
      'email': 'ای میل',
      'name': 'نام',
      'photo_permission_denied':
          'تصاویر تک رسائی مسترد کر دی گئی۔ براہ کرم ڈیوائس کی ترتیبات میں اجازت دیں۔',
      'photo_pick_failed': 'تصاویر نہیں کھل سکیں۔ دوبارہ کوشش کریں۔',
      'member_since': 'رکن از',
      'my_profile': 'میری پروفائل',
      'points': 'پوائنٹس',
      'badges': 'بیجز',
      'sign_out': 'سائن آؤٹ',
      'sign_out_confirm': 'کیا آپ واقعی سائن آؤٹ کرنا چاہتے ہیں؟',
      'notifications_subtitle': 'اذان، یاد دہانیاں اور الرٹس',
      'location_settings': 'مقام کی ترتیبات',
      'auto_location': 'خودکار مقام (GPS)',
      'manual_location': 'دستی مقام',
      'location_required': 'براہ کرم شہر درج کریں۔',
      'rate_now': 'ابھی ریٹ کریں',
      'later': 'بعد میں',
      'rate_us_message':
          'اگر آپ کو برکت ٹائم پسند ہے تو براہ کرم ہمیں ریٹ کریں! ✨',
      'app_store_coming_soon':
          'برکت ٹائم جلد App Store پر دستیاب ہوگا۔ آپ کے تعاون کا شکریہ!',
      'store_open_failed': 'اسٹور نہیں کھل سکا۔ بعد میں کوشش کریں۔',
      'close': 'بند کریں',
      'skip': 'چھوڑیں',
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
      'asr_calculation': 'عصر کا حساب',
      'asr_shafi': 'عام (شافعی، مالکی، حنبلی)',
      'asr_hanafi': 'حنفی',
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
      'hajj_step4_desc': 'کنکریاں جمع کریں اور رات قیام کریں۔',
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
      'sunrise': 'طلوعِ آفتاب',
      'tomorrow_fajr': 'کل کی فجر',
      'location_not_found':
          '"{city}" نہیں ملا۔ مختلف ہجے آزمائیں یا ملک کا نام شامل کریں۔',
      'location_services_disabled': 'لوکیشن سروسز بند ہیں',
      'location_permission_denied':
          'آپ کے مقام کے اوقاتِ نماز دکھانے کے لیے لوکیشن کی اجازت درکار ہے۔',
      'location_permission_denied_forever':
          'لوکیشن کی اجازت بلاک ہے۔ ایپ سیٹنگز میں فعال کریں یا شہر دستی طور پر منتخب کریں۔',
      'location_timeout': 'آپ کا مقام بروقت معلوم نہیں ہو سکا۔',
      'location_access_required': 'لوکیشن تک رسائی درکار ہے',
      'open_settings': 'سیٹنگز کھولیں',
      'grant_access_retry': 'اجازت دیں اور دوبارہ کوشش کریں',
      'set_manual_location_hint': 'یا سیٹنگز میں شہر دستی طور پر منتخب کریں۔',
      'locating': 'مقام تلاش کیا جا رہا ہے...',
      'location_unavailable': 'مقام دستیاب نہیں',
      'prayer_not_started': '{prayer} کا وقت ابھی شروع نہیں ہوا۔',
      'prayer_already_logged': '{prayer} آج پہلے ہی درج ہو چکی ہے۔',
      'prayer_notification_title': '{prayer} کا وقت',
      'prayer_notification_body': '{prayer} کی نماز کا وقت ہو گیا ہے۔',
      'pulse_load_failed': 'آپ کی روحانی نبض لوڈ نہیں ہو سکی۔',
      'names_99_short': '99 نام',
      'duas_short': 'دعائیں',
      'tasbeeh_short': 'تسبیح',
      'badge_first_step': 'پہلا قدم',
      'badge_first_step_desc': 'آپ نے اپنی پہلی سرگرمی درج کی',
      'badge_streak_7': '7 دن کا تسلسل',
      'badge_streak_7_desc': 'لگاتار 7 دن فعال رہے',
      'badge_streak_30': 'ماہانہ ماہر',
      'badge_streak_30_desc': 'لگاتار 30 دن فعال رہے',
      'badge_streak_100': 'ثابت قدم',
      'badge_streak_100_desc': 'لگاتار 100 دن فعال رہے',
      'badge_daily_achiever': 'روزانہ کامیاب',
      'badge_daily_achiever_desc': 'ایک دن میں 100 پوائنٹس حاصل کیے',
      'badge_spiritual_veteran': 'روحانی تجربہ کار',
      'badge_spiritual_veteran_desc': '50 سرگرمیاں درج کیں',
      'badge_points_1000': '1,000 پوائنٹس',
      'badge_points_1000_desc': 'مجموعی طور پر 1,000 پوائنٹس حاصل کیے',
      'no_badges_yet': 'بیجز حاصل کرنے کے لیے ایپ استعمال کرتے رہیں!',
      'badges_earned': '{n} بیجز حاصل کیے',
      'motivation_achieved':
          'ماشاءاللہ! آپ نے آج کے روحانی اہداف حاصل کر لیے۔ ✨',
      'motivation_almost':
          'زبردست پیش رفت! ہدف تک پہنچنے میں تھوڑا سا باقی ہے۔ 🚀',
      'motivation_halfway': 'آپ آدھا راستہ طے کر چکے ہیں! جاری رکھیں۔ 💪',
      'motivation_started': 'اچھی شروعات! اپنے اہداف کی طرف بڑھتے رہیں۔ ⚡',
      'motivation_start': 'آج کا روحانی سفر شروع کریں۔ ہر قدم اہم ہے! 🌱',
      'method_mwl': 'مسلم ورلڈ لیگ',
      'method_karachi': 'جامعہ علوم اسلامیہ، کراچی',
      'method_isna': 'اسلامک سوسائٹی آف نارتھ امریکہ (ISNA)',
      'method_umm_al_qura': 'جامعہ ام القریٰ، مکہ مکرمہ',
      'method_egyptian': 'مصری جنرل اتھارٹی آف سروے',
      'method_dubai': 'دبئی (متحدہ عرب امارات)',
      'method_qatar': 'قطر',
      'method_kuwait': 'کویت',
      'method_turkey': 'دیانت (ترکی)',
      'method_tehran': 'انسٹی ٹیوٹ آف جیو فزکس، تہران یونیورسٹی',
      'method_singapore': 'سنگاپور، ملائیشیا اور انڈونیشیا',
      'method_moonsighting': 'مون سائٹنگ کمیٹی ورلڈ وائیڈ',
      'unknown_city': 'نامعلوم مقام',
      'daily_challenges': 'آج کے چیلنج',
      'challenges_hint': 'ایپ استعمال کرتے ہوئے خود مکمل ہوتے ہیں',
      'challenge_prayers': 'پانچوں نمازیں پڑھیں',
      'challenge_quran': 'قرآن میں سے پڑھیں',
      'challenge_dhikr': 'تسبیح پر 33 بار ذکر کریں',
      'challenges_all_done': 'ماشاءاللہ! آج کے سارے چیلنج مکمل ہو گئے',
      'perfect_days_week': 'اس ہفتے کے مکمل دن: {n}/7',
      'quran_font': 'قرآن کا فونٹ',
      'quran_font_note': 'ہر فونٹ پہلی بار استعمال پر صرف ایک بار ڈاؤن لوڈ ہوتا ہے۔',
      'night_rec_title': 'سونے سے پہلے',
      'night_rec_subtitle': 'نبی ﷺ کی سنت سے',
      'friday_rec_title': 'جمعہ مبارک',
      'friday_rec_subtitle': 'جمعہ کے دن سورہ کہف پڑھیں',
      'rec_ayat_kursi': 'آیت الکرسی',
      'rec_baqarah_end': 'سورہ بقرہ کی آخری دو آیات',
      'rec_mulk': 'سورہ ملک',
      'rec_quls': 'چاروں قل',
      'rec_waqiah': 'سورہ واقعہ',
      'rec_muzzammil': 'سورہ مزمل',
      'rec_kahf': 'سورہ کہف',
      'rec_also_common': 'بہت سے لوگ یہ بھی پڑھتے ہیں',
      'mark_done': 'مکمل',
      'mark_not_done': 'مکمل نہیں',
      'night_reminder': 'رات کی تلاوت کی یاد دہانی',
      'night_reminder_desc': 'عشاء کے ایک گھنٹے بعد',
      'kahf_reminder': 'جمعہ کو سورہ کہف',
      'kahf_reminder_desc': 'جمعہ کی صبح',
      'night_reminder_title': 'سونے سے پہلے 🌙',
      'night_reminder_body': 'آیت الکرسی، سورہ ملک اور چاروں قل',
      'kahf_reminder_title': 'جمعہ مبارک',
      'kahf_reminder_body': 'آج سورہ کہف پڑھنا نہ بھولیں',
      'playback_speed': 'آواز کی رفتار',
      'mushaf': 'مصحف',
      'page_n': 'صفحہ {n}',
      'juz_n': 'پارہ {n}',
      'mushaf_tap_hint': 'ترجمہ دیکھنے، سننے یا محفوظ کرنے کے لیے کسی آیت پر ٹیپ کریں',
      'play_from_here': 'یہاں سے چلائیں',
      'send_feedback': 'رائے بھیجیں',
      'send_feedback_desc': 'کوئی مسئلہ بتائیں یا مشورہ دیں',
      'feedback_no_email_app': 'کوئی ای میل ایپ نہیں ملی۔ ہمیں {email} پر لکھیں',
      'adhan_help': 'اذان دیر سے آتی ہے یا نہیں آتی؟',
      'adhan_help_desc': 'فون کی وہ سیٹنگز جو یاد دہانی روک سکتی ہیں',
      'adhan_help_body': 'کچھ فون (جیسے Vivo، Oppo، Xiaomi، Infinix اور Samsung) بیٹری بچانے کے لیے پس منظر میں ایپس بند کر دیتے ہیں، جس سے اذان دیر سے آ سکتی ہے یا رک سکتی ہے۔\n\n1۔ نیچے والے بٹن سے ایپ کی سیٹنگز کھولیں۔\n2۔ بیٹری: "Unrestricted" یا "No restrictions" چنیں۔\n3۔ اگر آپ کے فون میں "Autostart" یا "Background activity" کا آپشن ہے تو Barakah Time کے لیے اسے آن کریں۔\n4۔ یقینی بنائیں کہ نوٹیفکیشنز کی اجازت ہے۔\n\nاس کے بعد ایک بار Barakah Time کھولیں تاکہ یاد دہانیاں دوبارہ لگ جائیں۔',
      'refresh_location': 'مقام اپ ڈیٹ کریں',
      'location_updated': 'مقام اپ ڈیٹ ہو گیا',
      'default_user_name': 'برکت صارف',
      'sign_in_with_apple': 'Apple کے ساتھ سائن ان کریں',
      'continue_as_guest': 'ابھی نہیں',
      'guest_mode_notice':
          'ایپ کی ہر سہولت اکاؤنٹ کے بغیر چلتی ہے۔ سائن اِن صرف تب کریں جب آپ اپنا ریکارڈ محفوظ رکھنا اور دوسرے فون پر استعمال کرنا چاہیں۔',
      'sign_in_to_sync': 'ہم آہنگی کے لیے سائن ان کریں',
      'auth_unavailable_notice':
          'سائن ان اس وقت دستیاب نہیں۔ آپ ایپ استعمال کرتے رہ سکتے ہیں؛ آپ کا ڈیٹا اسی آلے پر رہے گا۔',
      'err_auth_unavailable':
          'سائن ان اس وقت ممکن نہیں۔ اپنا کنکشن چیک کریں اور ایپ دوبارہ کھولیں۔',
      'err_apple_failed': 'Apple کے ساتھ سائن ان ناکام رہا۔ دوبارہ کوشش کریں۔',
      'err_user_disabled': 'یہ اکاؤنٹ غیر فعال کر دیا گیا ہے۔',
      'err_account_exists_different_provider':
          'اس ای میل کے ساتھ کسی اور طریقے سے اکاؤنٹ پہلے سے موجود ہے۔',
      'err_user_mismatch':
          'براہ کرم اسی اکاؤنٹ سے سائن ان کریں جسے آپ حذف کر رہے ہیں۔',
      'session_expired':
          'آپ سائن آؤٹ ہو گئے ہیں۔ براہ کرم دوبارہ سائن ان کریں۔',
      'email_not_verified':
          'آپ کی ای میل ابھی تصدیق شدہ نہیں۔ تصدیقی لنک کے لیے ان باکس دیکھیں۔',
      'resend_verification': 'تصدیقی ای میل دوبارہ بھیجیں',
      'verification_link_resent': 'تصدیقی ای میل بھیج دی گئی۔ ان باکس دیکھیں۔',
      'delete_account': 'اکاؤنٹ حذف کریں',
      'delete_confirm_word': 'حذف',
      'delete_account_confirm_title': 'اپنا اکاؤنٹ حذف کریں؟',
      'delete_account_confirm_message':
          'اس سے آپ کا اکاؤنٹ، پیش رفت، بیجز، محفوظ آیات اور پروفائل تصویر ہمیشہ کے لیے حذف ہو جائیں گے۔ یہ واپس نہیں ہو سکتا۔',
      'reauth_required_delete':
          'حفاظت کے لیے، اکاؤنٹ حذف کرنے سے پہلے اپنا سائن ان تصدیق کریں۔',
      'confirm_with_password': 'جاری رکھنے کے لیے پاس ورڈ درج کریں',
      'confirm_with_provider': '{provider} کے ساتھ تصدیق کریں',
      'account_deleted': 'آپ کا اکاؤنٹ حذف کر دیا گیا۔',
      'err_delete_account_failed': 'اکاؤنٹ حذف نہیں ہو سکا۔ دوبارہ کوشش کریں۔',
      'lifetime_points': 'مجموعی پوائنٹس',
      'longest_streak': 'سب سے طویل تسلسل',
      'adhan_sound': 'اذان کی آواز',
      'adhan_sound_desc': 'نماز کی یاد دہانی پر اذان چلائیں',
      'adjust_times': 'نماز کے اوقات میں ترمیم',
      'app_theme': 'تھیم',
      'theme_system': 'سسٹم کے مطابق',
      'theme_light': 'لائٹ',
      'theme_dark': 'ڈارک',
      'adjust_times_desc': 'ہر نماز کو اپنی مسجد کے وقت کے مطابق کریں',
      'adjust_times_none': 'کوئی تبدیلی نہیں',
      'minutes_short': '{n} منٹ',
      'adjust_times_note':
          'اوقات حساب شدہ وقت سے آگے پیچھے کیے جاتے ہیں۔ یہ صرف تب استعمال کریں جب آپ کی مقامی مسجد کا وقت مختلف ہو۔',
      'exact_alarms_hint':
          '"الارمز اور یاد دہانیاں" کی اجازت دیں تاکہ نماز کی یاد دہانی بالکل وقت پر آئے۔',
      'notifications_permission_revoked':
          'سسٹم سیٹنگز میں اطلاعات کی اجازت بند کر دی گئی، اس لیے نماز کی یاد دہانیاں بند ہو گئیں۔',
      'good_morning': 'صبح بخیر',
      'good_afternoon': 'سہ پہر بخیر',
      'good_evening': 'شام بخیر',
      'assalamualaikum': 'السلام علیکم',
      'hijri_year_suffix': 'ھ',
      'hijri_month_1': 'محرم',
      'hijri_month_2': 'صفر',
      'hijri_month_3': 'ربیع الاول',
      'hijri_month_4': 'ربیع الثانی',
      'hijri_month_5': 'جمادی الاول',
      'hijri_month_6': 'جمادی الثانی',
      'hijri_month_7': 'رجب',
      'hijri_month_8': 'شعبان',
      'hijri_month_9': 'رمضان',
      'hijri_month_10': 'شوال',
      'hijri_month_11': 'ذوالقعدہ',
      'hijri_month_12': 'ذوالحجہ',
      'qibla_short': 'قبلہ',
      'calendar_short': 'کیلنڈر',
      'more': 'مزید',
      'read_full_ayah': 'پوری آیت پڑھیں',
      'shared_from_app': 'Barakah Time سے شیئر کیا گیا',
      'pulse_share_text':
          'Barakah Time میں میری پیش رفت: {streak} دن کا تسلسل اور اس ہفتے {points} پوائنٹس۔',
      'points_this_week': 'اس ہفتے کے پوائنٹس',
      'current_streak': 'موجودہ تسلسل',
      'day_streak_count': '{n} دن کا تسلسل',
      'weekday_points': '{day}: {n} پوائنٹس',
      'recent_activity': 'حالیہ سرگرمی',
      'no_recent_activity':
          'ابھی کوئی سرگرمی نہیں۔ شروع کرنے کے لیے نماز درج کریں، قرآن پڑھیں یا ذکر کریں۔',
      'activity_prayer': 'نمازِ {prayer}',
      'activity_quran': 'تلاوتِ قرآن',
      'activity_dhikr': 'ذکر',
      'activity_other': 'سرگرمی',
      'points_gained': '+{n} پوائنٹس',
      'prayer_logged_semantics': '{prayer} درج ہو گئی',
      'log_prayer_semantics': '{prayer} درج کریں',
      'prayer_in_label': '{prayer} میں باقی',
      'cardinal_n': 'شمال',
      'cardinal_e': 'مشرق',
      'cardinal_s': 'جنوب',
      'cardinal_w': 'مغرب',
      'qibla_semantics_right': 'قبلہ آپ کے دائیں جانب {deg}° پر ہے',
      'qibla_semantics_left': 'قبلہ آپ کے بائیں جانب {deg}° پر ہے',
      'qibla_semantics_ahead': 'قبلہ بالکل سامنے ہے',
      'qibla_compass': 'قبلہ کمپاس',
      'logged': 'درج شدہ',
    },
    'tr': {
      'pulse_today': 'Bugün',
      'pulse_today_prayers': 'Bugünün namazları',
      'badge_locked': 'Kilitli',
      'audio_error_voice_missing':
          "Telefonda bu dil için ses yok. Telefon Ayarları → Metin okuma bölümünden yükleyin.",
      'quran_translation_language': 'Meal dili',
      'quran_translation_same_as_app': 'Uygulama diliyle aynı',
      'quran_translation_audio_note':
          'Urduca, İngilizce, Farsça ve Türkçe mealler bir okuyucunun sesiyle dinlenir.',
      'audio_error_play': 'Ses çalınamadı. Yeni tilavetler ilk seferde internet gerektirir; daha önce dinledikleriniz internetsiz de çalar.',
      'audio_error_speech': 'Sesli okuma başarısız oldu',
      'name_too_long': 'Ad en fazla 100 karakter olabilir',
      'reminders_need_notifications':
          'Önce Ayarlar\'dan namaz bildirimlerini açın.',
      'ramadan_title': 'Ramazan',
      'ramadan_day_of': '{len} günün {day}. günü',
      'ramadan_starts_in': '{n} gün sonra başlıyor',
      'ramadan_qadr_tonight':
          'Bu gece Kadir Gecesi olabilir. İbadet ve duayla geçirin.',
      'ramadan_moon_adjust': 'Hilal gözlem ayarı (gün)',
      'ramadan_need_location':
          'Sahur ve iftar vakitlerini görmek için namaz vakitlerini yükleyin.',
      'ramadan_sehri_ends_in': 'Sahurun bitmesine',
      'ramadan_iftar_in': 'İftara',
      'ramadan_sehri_ends': 'Sahur bitişi',
      'ramadan_iftar': 'İftar',
      'ramadan_reminders': 'Sahur ve iftar hatırlatmaları',
      'ramadan_reminders_desc':
          'Sahur bitmeden 30 dakika önce ve iftar vaktinde',
      'ramadan_duas': 'Ramazan duaları',
      'ramadan_sehri_niyyah': 'Oruç niyeti (sahur)',
      'ramadan_sehri_niyyah_meaning':
          'Yarınki Ramazan orucunu tutmaya niyet ettim.',
      'ramadan_iftar_dua': 'İftar duası',
      'ramadan_iftar_dua_meaning':
          'Allah\'ım, senin için oruç tuttum, sana inandım, sana güvendim ve senin rızkınla orucumu açtım.',
      'ramadan_iftar_dua2': 'Orucu açtıktan sonra',
      'ramadan_iftar_dua2_meaning':
          'Susuzluk gitti, damarlar ıslandı ve inşallah ecir sabit oldu. (Ebû Dâvûd)',
      'ramadan_qadr_dua': 'Kadir Gecesi duası',
      'ramadan_qadr_dua_meaning':
          'Allah\'ım, sen affedicisin, affetmeyi seversin, beni affet. (Tirmizî)',
      'ramadan_log': 'Oruç kaydı',
      'ramadan_fasted': 'Tuttum',
      'ramadan_missed': 'Kaçırdım',
      'ramadan_taraweeh': 'Teravih',
      'ramadan_log_hint':
          'Orucu ve teravihi işaretlemek için bir güne dokunun. Yıldızlar son on günün tek gecelerini gösterir.',
      'ramadan_qaza_fasts': 'Kaza edilecek {n} oruç',
      'ramadan_day': 'Gün',
      'ramadan_not_set': 'Temizle',
      'ramadan_prayed_taraweeh': 'Teravih kıldım',
      'ramadan_prepare': 'Hazırlanın: Kur\'an, dua ve sadaka planınızı yapın.',
      'ramadan_sehri_reminder_title': 'Sahur 30 dakika sonra bitiyor',
      'ramadan_sehri_reminder_body':
          'Sahur {time}\'da bitiyor. Niyet etmeyi unutmayın.',
      'ramadan_iftar_reminder_title': 'İftar vakti',
      'ramadan_iftar_reminder_body':
          'Orucunuzu açın ve dua edin; iftar anındaki dua kabul olunur.',
      'memorial_title': 'İsal-i Sevap',
      'memorial_tool_subtitle': 'Vefat edenler için',
      'memorial_sign_in':
          'Bir yakınınız için İsal-i Sevap sayfası oluşturmak veya katılmak için giriş yapın.',
      'memorial_intro':
          'Vefat eden bir yakınınız için sayfa oluşturup WhatsApp\'ta paylaşın. Aile ve arkadaşlar cüz alarak hatmi tamamlayabilir, ortak hedeflere zikir ekleyebilir ve onun için iyilikler yazabilir.',
      'memorial_create': 'Sayfa oluştur',
      'memorial_join': 'Kodla katıl',
      'memorial_none':
          'Henüz sayfa yok. Bir tane oluşturun veya paylaşılan bir kodla katılın.',
      'memorial_you_created': 'Sizin oluşturduğunuz',
      'memorial_joined': 'Katıldınız',
      'memorial_code_invalid': '8 karakterlik kodu girin',
      'memorial_code': 'Kod',
      'memorial_join_button': 'Katıl',
      'memorial_name_required': 'Bir isim girin',
      'memorial_name': 'Vefat edenin adı',
      'memorial_subtitle': 'Yakınlık veya not (isteğe bağlı)',
      'memorial_subtitle_hint': 'ör. Ahmed\'in babası',
      'memorial_death_date': 'Vefat tarihi',
      'memorial_optional': 'İsteğe bağlı',
      'memorial_show_dates': 'Anma günlerini göster',
      'memorial_show_dates_desc': '3., 10., 40. gün ve sene-i devriye',
      'memorial_goals': 'Zikir hedefleri',
      'memorial_goal': 'Hedef',
      'memorial_error_not_found': 'Bu kodla bir sayfa bulunamadı.',
      'memorial_error_para_taken':
          'Bu cüzü az önce biri aldı. Lütfen başka birini seçin.',
      'memorial_error_generic':
          'Bir sorun oluştu. İnternetinizi kontrol edip tekrar deneyin.',
      'memorial_deleted': 'Bu sayfa silindi.',
      'memorial_remove_from_list': 'Listemden kaldır',
      'memorial_created_hint':
          'Sayfa oluşturuldu. Aile ve arkadaşlarla paylaşın.',
      'memorial_share': 'Paylaş',
      'memorial_share_text':
          '{name} için İsal-i Sevap\'a katılın. Barakah Time uygulamasında onun için bir cüz okuyun veya zikir yapın.\n\nKod: {code}\n\nUygulamayı indirin: {link}',
      'memorial_para': '{n}. cüz',
      'memorial_take_para_confirm':
          'Bu cüzü vefat eden için okuyacaksınız. Diğerleri sizin aldığınızı görecek.',
      'memorial_take_para': 'Bu cüzü al',
      'memorial_para_read_by': '{n}. cüzü {name} okudu',
      'memorial_para_taken_by': '{n}. cüzü {name} okuyor',
      'memorial_para_yours': 'Bu cüzü siz okuyorsunuz',
      'memorial_mark_read': 'Okudum',
      'memorial_release_para': 'Geri ver',
      'memorial_khatam_done':
          'Hatim tamamlandı. Elhamdülillah! Yeni hatim başladı.',
      'memorial_para_done': 'Allah razı olsun. Allah kabul etsin.',
      'memorial_how_many': 'Kaç kez?',
      'memorial_added': 'Eklendi. Allah razı olsun.',
      'memorial_delete': 'Sayfayı sil',
      'memorial_delete_confirm':
          'Bu sayfa tüm ilerlemeyle birlikte herkes için silinir. Geri alınamaz.',
      'memorial_add_deed': 'İyilik veya dua ekle',
      'memorial_deed_hint': 'ör. 10 kişiye yemek verdim veya onun için bir dua',
      'memorial_dates': 'Anma günleri',
      'memorial_activity': 'Etkinlik',
      'memorial_code_copied': 'Kod kopyalandı',
      'memorial_invite': 'Davet et',
      'memorial_khatam_n': '{n}. hatim',
      'memorial_khatams_completed': '{n} hatim tamamlandı',
      'memorial_khatam_hint':
          'Vefat eden için okumak üzere boş bir cüze dokunun.',
      'memorial_free': 'Boş',
      'memorial_yours': 'Sizin',
      'memorial_taken': 'Alındı',
      'memorial_read': 'Okundu',
      'memorial_add_count': 'Ekle',
      'memorial_remind_me': 'Bu günlerde hatırlat',
      'memorial_feed_para': '{name} {n}. cüzü okudu',
      'memorial_feed_khatam': '{n}. hatim tamamlandı. Elhamdülillah!',
      'memorial_feed_dhikr': '{name} {dhikr} × {count} okudu',
      'memorial_feed_empty': 'Henüz bir şey yok. İlk katkıyı siz yapın.',
      'memorial_day3': '3. gün',
      'memorial_day10': '10. gün',
      'memorial_day40': '40. gün (kırkı)',
      'memorial_barsi': 'Sene-i devriye',
      'memorial_reminder_title': '{name} için {day}',
      'memorial_reminder_body':
          'Bugün {name} için Kur\'an, dua veya sadaka ile anın.',
      'dhikr_kareema': 'Ayet-i Kerime',
      'dhikr_darood': 'Salavat',
      'dhikr_kalma': 'Kelime-i Tevhid',
      'dhikr_ikhlas': 'İhlas Suresi',
      'dhikr_yaseen': 'Yasin Suresi',
      'dhikr_istighfar': 'İstiğfar',
      'widget_empty': 'Namaz vakitlerini yüklemek için Barakah Time\'ı açın',
      'promise_title': 'Sözümüz',
      'promise_no_ads': 'Asla reklam yok',
      'promise_no_sell': 'Verilerinizi asla satmayız veya paylaşmayız',
      'promise_no_tracking': 'İzleyici veya analiz aracı yok',
      'promise_location':
          'Konumunuz yalnızca namaz vakitleri, kıble ve yakındaki camiler için kullanılır',
      'onboarding_privacy_title': 'Reklam yok. Verileriniz sizindir.',
      'onboarding_privacy_desc':
          'Barakah Time\'da reklam ve izleyici yoktur, verilerinizi asla satmayız. İbadetiniz sizinle Allah arasındadır.',
      'qaza_tracker': 'Kaza Takibi',
      'witr': 'Vitir',
      'qaza_intro_title': 'Kaçırılan namazları kaza edin',
      'qaza_intro_body':
          'Kaç namaz borcunuz olduğunu tahmin edin, sonra bunları tek tek kılın. İlerlemeniz kaydedilir ve hesabınızla eşitlenir.',
      'qaza_calculate': 'Kaza namazlarını hesapla',
      'qaza_enter_manually': 'Sayıları elle gir',
      'qaza_remaining': 'Kalan',
      'qaza_made_up': 'Kılınan',
      'qaza_progress': '%{p} kılındı',
      'qaza_pray_one': 'Bir kaza kıldım',
      'qaza_logged': 'Bir {prayer} kazası kılındı',
      'qaza_edit_title': 'Kalan {prayer}',
      'qaza_invalid': '0 ile 60000 arasında bir sayı girin',
      'qaza_years': 'Yıl',
      'qaza_months': 'Ay',
      'qaza_days': 'Gün',
      'qaza_include_witr': 'Vitir dahil (Hanefi)',
      'qaza_calc_desc':
          'Ne kadar süre namaz kılmadınız? Örneğin ergenlikten düzenli namaza başlayana kadar.',
      'qaza_calc_result': 'Her namazdan {n} eklenir',
      'qaza_estimate_note':
          'Tedbir olarak bir yıl 365 gün sayılır. Emin değilseniz bir âlime danışın.',
      'qaza_add': 'Takibe ekle',
      'qaza_reset': 'Takibi sıfırla',
      'qaza_reset_confirm': 'Tüm sayılar ve ilerleme silinir. Geri alınamaz.',
      'qaza_all_done': 'Tüm kaza namazları kılındı. Elhamdülillah!',
      'qaza_tool_subtitle': 'Kaçırılan namazlar',
      // Auth / onboarding / profile / settings / about pages
      'app_tagline': 'Vaktinize bereket katın',
      'onboarding_pulse_title': 'Manevi Nabız',
      'onboarding_pulse_desc':
          'Manevi istikrarınızı takip edin ve kalıcı alışkanlıklar edinin. Bağlı kalın, istikrarlı kalın.',
      'onboarding_prayer_title': 'Hiçbir Namazı Kaçırmayın',
      'onboarding_prayer_desc':
          'Konumunuza göre doğru namaz vakitleri, canlı geri sayım ve hatırlatıcılar.',
      'onboarding_inspiration_title': 'Günlük İlham',
      'onboarding_inspiration_desc':
          'Günlük ayetler, Esmaül Hüsna, dualar ve daha fazlasıyla ruhunuza huzur bulun.',
      'onboarding_next': 'İleri',
      'onboarding_get_started': 'Başlayın',
      'auth_welcome_back': 'Tekrar Hoş Geldiniz',
      'auth_sign_in_subtitle':
          'Manevi yolculuğunuza devam etmek için giriş yapın',
      'auth_email_address': 'E-posta Adresi',
      'auth_password': 'Şifre',
      'auth_sign_in': 'Giriş Yap',
      'auth_or': 'veya',
      'auth_no_account': 'Hesabınız yok mu?',
      'auth_sign_up': 'Kaydol',
      'auth_create_account': 'Hesap Oluştur',
      'auth_sign_up_subtitle': 'Topluluğumuza katılın ve birlikte gelişelim',
      'auth_full_name': 'Ad Soyad',
      'auth_register': 'Kayıt Ol',
      'auth_have_account': 'Zaten hesabınız var mı?',
      'auth_account_created_verify':
          'Hesap oluşturuldu! {email} adresine doğrulama bağlantısı gönderdik.',
      'profile_saved_verses': 'Kaydedilen ayetler',
      'profile_saved_count': '{n} kayıtlı',
      'profile_activity_history': 'Etkinlik geçmişi',
      'profile_last_activity': 'Son: {activity}',
      'profile_no_saved_verses':
          'Henüz kayıtlı ayet yok. Bir ayeti buraya kaydetmek için yer imine dokunun.',
      'profile_remove_verse': 'Kaydedilenlerden kaldır',
      'profile_undo': 'Geri al',
      'profile_change_photo': 'Fotoğrafı değiştir',
      'profile_take_photo': 'Fotoğraf çek',
      'profile_choose_gallery': 'Galeriden seç',
      'profile_guest_title': 'Hoş geldiniz',
      'profile_yesterday': 'Dün',
      'settings_account': 'Hesap',
      'settings_prayer': 'Namaz',
      'settings_support_us': 'Çalışmamızı destekleyin',
      'settings_version': 'Sürüm {v}',
      'about_title': 'Bereket Vakti Hakkında',
      'about_description':
          'Namaz vakitleri, Kur\'an, zikir ve günlük manevi gelişim için İslami bir yol arkadaşı; vaktinize bereket katmak için tasarlandı.',
      'about_credits': 'Katkılar ve veri kaynakları',
      'about_quran_data': 'Kur\'an metni, mealler ve ses',
      'about_map_data': 'Harita ve yer verileri',
      'about_map_license':
          '© OpenStreetMap katkıda bulunanları, Açık Veritabanı Lisansı (ODbL) kapsamında',
      'about_prayer_calc': 'Namaz vakti hesaplama',
      'about_prayer_calc_source': 'adhan kütüphanesi (açık kaynak)',
      'about_privacy': 'Gizlilik Politikası',
      'about_terms': 'Hizmet Şartları',
      'about_licenses': 'Açık kaynak lisansları',
      'about_made_with_love': 'Ümmet için ❤️ ile yapıldı',
      'about_link_failed':
          'Bağlantı açılamadı. Lütfen daha sonra tekrar deneyin.',
      'search_surahs': 'Ad veya numarayla ara',
      'continue_reading': 'Okumaya devam et',
      'no_surahs_found': 'Aramanızla eşleşen sure yok',
      'meccan': 'Mekkî',
      'medinan': 'Medenî',
      'verse_saved': 'Ayet kaydedildi',
      'verse_removed': 'Ayet kaydedilenlerden kaldırıldı',
      'save_verse': 'Ayeti kaydet',
      'remove_saved_verse': 'Kaydedilenlerden kaldır',
      'share_ayah_heading': '{surah} Suresi, {ayah}. Ayet',
      'copy': 'Kopyala',
      'copied': 'Panoya kopyalandı',
      'meaning': 'Anlamı',
      'transliteration': 'Okunuşu',
      'name_number': '99 isimden {n}.',
      'alhamdulillah': 'Elhamdülillah',
      'allahu_akbar': 'Allahu Ekber',
      'astaghfirullah': 'Estağfirullah',
      'la_ilaha_illallah': 'Lâ ilâhe illallah',
      'tasbeeh_target': 'Hedef',
      'tasbeeh_custom': 'Özel',
      'tasbeeh_custom_target': 'Özel hedef',
      'tasbeeh_round': '{n}. tur',
      'tasbeeh_total': 'Toplam: {n}',
      'tasbeeh_target_reached': 'Hedefe ulaşıldı!',
      'tasbeeh_counter_semantics': 'Sayaç: {count}. Saymak için dokunun.',
      'tasbeeh_target_invalid': '1 ile 9999 arasında bir sayı girin',
      'zakat_currency': 'Para birimi (isteğe bağlı)',
      'zakat_currency_hint': 'ör. TRY, USD, EUR',
      'distance_m': '{n} m',
      'distance_km': '{n} km',
      'osm_attribution': '© OpenStreetMap contributors',
      'dua_before_sleeping': 'Uyumadan Önce',
      'dua_waking_up': 'Uyanınca',
      'dua_before_eating': 'Yemekten Önce',
      'dua_after_eating': 'Yemekten Sonra',
      'dua_entering_home': 'Eve Girerken',
      'dua_leaving_home': 'Evden Çıkarken',
      'dua_entering_mosque': 'Camiye Girerken',
      'dua_leaving_mosque': 'Camiden Çıkarken',
      'dua_for_parents': 'Anne Baba İçin',
      'dua_for_knowledge': 'İlim İçin',
      'dua_forgiveness': 'Bağışlanma İçin (İstiğfar)',
      'dua_entering_washroom': 'Tuvalete Girerken',
      'dua_leaving_washroom': 'Tuvaletten Çıkarken',
      'dua_before_wudu': 'Abdestten Önce',
      'dua_after_wudu': 'Abdestten Sonra',
      'dua_traveling': 'Yolculuk',
      'dua_morning_evening': 'Sabah/Akşam',
      'dua_protection': 'Korunma İçin',
      'dua_ayatul_kursi': 'Ayetü\'l-Kürsî (Namazdan Sonra)',
      'dua_mirror': 'Aynaya Bakarken',
      'dua_wearing_clothes': 'Elbise Giyerken',
      'clear_search': 'Aramayı temizle',
      'confirm': 'Onayla',
      'continue_with_apple': 'Apple ile devam et',
      'continue_with_google': 'Google ile devam et',
      'dismiss': 'Kapat',
      'hide_password': 'Şifreyi gizle',
      'loading': 'Yükleniyor…',
      'show_password': 'Şifreyi göster',
      'something_went_wrong': 'Bir şeyler ters gitti. Lütfen tekrar deneyin.',
      'type_to_confirm': 'Onaylamak için {text} yazın',
      'all_tools': 'Tüm Araçlar',
      'ayah': 'Ayet',
      'ayahs': 'Ayet',
      'calibrate_compass':
          'Yön yanlış görünüyorsa pusulayı kalibre etmek için telefonunuzu 8 çizerek hareket ettirin.',
      'compass_unavailable':
          'Bu cihazda pusula yok — kuzeye dönün, ardından gösterilen açı kadar dönün.',
      'could_not_open_maps': 'Harita açılamadı',
      'degrees_from_north': 'Kuzeyden {deg}°',
      'detecting_location': 'Konum belirleniyor...',
      'directions': 'Yol tarifi',
      'facing_qibla': 'Kıbleye dönüksünüz',
      'finding_mosques': 'Yakındaki camiler aranıyor...',
      'in_days': '{n} gün sonra',
      'listen_translation': 'Meali dinle',
      'location_error_message':
          'Konumunuz alınamadı. Konum servislerini ve iznini açıp tekrar deneyin.',
      'mark_as_read': 'Okundu olarak işaretle',
      'mosques_load_error':
          'Yakındaki camiler yüklenemedi. İnternet bağlantınızı kontrol edin.',
      'no_mosques_match': 'Aramanızla eşleşen cami yok',
      'no_mosques_nearby': '5 km içinde cami bulunamadı',
      'now_playing': 'Çalıyor',
      'open_in_maps': 'Haritada aç',
      'pause': 'Duraklat',
      'play': 'Oynat',
      'play_surah': 'Sureyi oynat',
      'quran_load_error':
          'Kur\'an yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.',
      'reset_counter_message':
          'Sayaç 0’a dönecek. Şimdiye kadarki zikriniz Manevi Nabız’a kaydedilecek.',
      'reset_counter_title': 'Sayaç sıfırlansın mı?',
      'share': 'Paylaş',
      'stop': 'Durdur',
      'surah_already_logged_today': 'Bugün zaten kaydedildi ✓',
      'surah_load_error':
          'Bu sure yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.',
      'surah_logged': '{name} suresi kaydedildi! ✨',
      'today': 'Bugün',
      'tomorrow': 'Yarın',
      'translation': 'Meal',
      'unnamed_mosque': 'Cami',
      'zakat_above_nisab': 'Nisabın ({nisab}) üzerinde — zekât gerekir',
      'zakat_below_nisab': 'Nisabın ({nisab}) altında — zekât gerekmez',
      'zakat_gold_nisab': 'Altın (87,48 g)',
      'zakat_gold_price': 'Altının güncel gram fiyatı',
      'zakat_invalid_amount': 'Geçerli pozitif bir sayı girin',
      'zakat_liabilities': 'Vadesi gelen borçlar',
      'zakat_net_wealth': 'Zekâta tabi net servet',
      'zakat_nisab_standard': 'Nisab ölçüsü',
      'zakat_nisab_unknown':
          'Nisabı kontrol etmek için aşağıya metal fiyatını girin',
      'zakat_no_wealth':
          'Borçlardan sonra zekâta tabi servet yok — zekât gerekmez',
      'zakat_silver_nisab': 'Gümüş (612,36 g)',
      'zakat_silver_price': 'Gümüşün güncel gram fiyatı',
      'mawlid': 'Mevlid Kandili',
      'isra_miraj': 'Miraç Kandili',
      'shab_e_barat': 'Berat Kandili',
      'laylat_al_qadr': 'Kadir Gecesi (27. gece)',
      'day_of_arafah': 'Arefe Günü',
      'name_required': 'Lütfen adınızı girin.',
      'email_required': 'Lütfen e-postanızı girin.',
      'invalid_email': 'Lütfen geçerli bir e-posta adresi girin.',
      'password_required': 'Lütfen şifrenizi girin.',
      'password_too_short': 'Şifre en az 6 karakter olmalıdır.',
      'passwords_do_not_match': 'Şifreler eşleşmiyor.',
      'confirm_password': 'Şifreyi Onayla',
      'err_user_not_found': 'Bu e-postayla kayıtlı hesap bulunamadı.',
      'err_wrong_credentials': 'E-posta veya şifre hatalı.',
      'err_email_in_use': 'Bu e-postayla zaten bir hesap var.',
      'err_network': 'Ağ hatası. Bağlantınızı kontrol edin.',
      'err_too_many_requests': 'Çok fazla deneme. Daha sonra tekrar deneyin.',
      'err_recent_login':
          'Güvenliğiniz için e-postanızı değiştirmeden önce çıkış yapıp tekrar giriş yapın.',
      'err_upload_failed': 'Fotoğraf yüklenemedi. Lütfen tekrar deneyin.',
      'err_profile_update_failed':
          'Profil güncellenemedi. Lütfen tekrar deneyin.',
      'err_google_failed': 'Google ile giriş başarısız. Lütfen tekrar deneyin.',
      'profile_updated': 'Profil güncellendi.',
      'photo_updated': 'Profil fotoğrafı güncellendi.',
      'verification_email_sent':
          'Yeni e-postanıza bir doğrulama bağlantısı gönderildi. Onayladığınızda e-postanız güncellenecek.',
      'forgot_password': 'Şifremi Unuttum?',
      'reset_password': 'Şifreyi Sıfırla',
      'reset_password_hint':
          'E-postanızı girin, size şifre sıfırlama bağlantısı gönderelim.',
      'send_link': 'Bağlantı Gönder',
      'reset_email_sent':
          'Şifre sıfırlama e-postası gönderildi. Gelen kutunuzu kontrol edin.',
      'email': 'E-posta',
      'name': 'Ad',
      'photo_permission_denied':
          'Fotoğraf erişimi reddedildi. Lütfen cihaz ayarlarından izin verin.',
      'photo_pick_failed': 'Fotoğraflar açılamadı. Lütfen tekrar deneyin.',
      'member_since': 'Üyelik tarihi',
      'my_profile': 'Profilim',
      'points': 'Puan',
      'badges': 'Rozetler',
      'sign_out': 'Çıkış Yap',
      'sign_out_confirm': 'Çıkış yapmak istediğinizden emin misiniz?',
      'notifications_subtitle': 'Ezan, hatırlatıcılar ve uyarılar',
      'location_settings': 'Konum Ayarları',
      'auto_location': 'Otomatik Konum (GPS)',
      'manual_location': 'Manuel Konum',
      'location_required': 'Lütfen bir şehir girin.',
      'rate_now': 'Şimdi Değerlendir',
      'later': 'Daha Sonra',
      'rate_us_message':
          'Barakah Time\'ı beğendiyseniz lütfen bizi değerlendirin! ✨',
      'app_store_coming_soon':
          'Barakah Time yakında App Store\'da. Desteğiniz için teşekkürler!',
      'store_open_failed':
          'Mağaza açılamadı. Lütfen daha sonra tekrar deneyin.',
      'close': 'Kapat',
      'skip': 'Atla',
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
      'asr_calculation': 'İkindi Hesaplaması',
      'asr_shafi': 'Standart (Şafii, Maliki, Hanbeli)',
      'asr_hanafi': 'Hanefi',
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
      'sunrise': 'Güneş',
      'tomorrow_fajr': 'Yarının Sabah namazı',
      'location_not_found':
          '"{city}" bulunamadı. Farklı bir yazım deneyin veya ülke ekleyin.',
      'location_services_disabled': 'Konum servisleri kapalı',
      'location_permission_denied':
          'Bulunduğunuz yerin namaz vakitlerini göstermek için konum izni gerekli.',
      'location_permission_denied_forever':
          'Konum izni engellendi. Uygulama ayarlarından açın veya şehri elle girin.',
      'location_timeout': 'Konumunuz zamanında alınamadı.',
      'location_access_required': 'Konum Erişimi Gerekli',
      'open_settings': 'Ayarları Aç',
      'grant_access_retry': 'İzin Ver ve Tekrar Dene',
      'set_manual_location_hint': 'Veya Ayarlar\'dan şehri elle girin.',
      'locating': 'Konum bulunuyor...',
      'location_unavailable': 'Konum kullanılamıyor',
      'prayer_not_started': '{prayer} vakti henüz girmedi.',
      'prayer_already_logged': '{prayer} bugün zaten kaydedildi.',
      'prayer_notification_title': '{prayer} vakti',
      'prayer_notification_body': '{prayer} namazı vakti geldi.',
      'pulse_load_failed': 'Manevi nabzınız yüklenemedi.',
      'names_99_short': '99 İsim',
      'duas_short': 'Dualar',
      'tasbeeh_short': 'Tesbih',
      'badge_first_step': 'İlk Adım',
      'badge_first_step_desc': 'İlk etkinliğini kaydettin',
      'badge_streak_7': '7 Günlük Seri',
      'badge_streak_7_desc': '7 gün üst üste aktif oldun',
      'badge_streak_30': 'Ayın Ustası',
      'badge_streak_30_desc': '30 gün üst üste aktif oldun',
      'badge_streak_100': 'İstikrarlı',
      'badge_streak_100_desc': '100 gün üst üste aktif oldun',
      'badge_daily_achiever': 'Günün Başarısı',
      'badge_daily_achiever_desc': 'Bir günde 100 puana ulaştın',
      'badge_spiritual_veteran': 'Manevi Usta',
      'badge_spiritual_veteran_desc': '50 etkinlik kaydettin',
      'badge_points_1000': '1.000 Puan',
      'badge_points_1000_desc': 'Toplam 1.000 puan kazandın',
      'no_badges_yet': 'Rozet kazanmak için uygulamayı kullanmaya devam et!',
      'badges_earned': '{n} rozet kazanıldı',
      'motivation_achieved': 'MaşaAllah! Bugünkü manevi hedeflerine ulaştın. ✨',
      'motivation_almost': 'Harika ilerleme! Hedefine az kaldı. 🚀',
      'motivation_halfway': 'Yolun yarısındasın! Böyle devam. 💪',
      'motivation_started':
          'İyi başlangıç! Hedeflerine doğru ilerlemeye devam et. ⚡',
      'motivation_start':
          'Bugünkü manevi yolculuğuna başla. Her adım önemli! 🌱',
      'method_mwl': 'Müslüman Dünya Birliği',
      'method_karachi': 'İslami İlimler Üniversitesi, Karaçi',
      'method_isna': 'Kuzey Amerika İslam Birliği (ISNA)',
      'method_umm_al_qura': 'Ümmü’l-Kura Üniversitesi, Mekke',
      'method_egyptian': 'Mısır Genel Ölçme Kurumu',
      'method_dubai': 'Dubai (BAE)',
      'method_qatar': 'Katar',
      'method_kuwait': 'Kuveyt',
      'method_turkey': 'Diyanet İşleri Başkanlığı',
      'method_tehran': 'Tahran Üniversitesi Jeofizik Enstitüsü',
      'method_singapore': 'Singapur, Malezya ve Endonezya',
      'method_moonsighting': 'Dünya Hilal Gözetleme Komitesi',
      'unknown_city': 'Bilinmeyen konum',
      'daily_challenges': 'Bugünün hedefleri',
      'challenges_hint': 'Uygulamayı kullandıkça kendiliğinden tamamlanır',
      'challenge_prayers': 'Beş vakit namazı kılın',
      'challenge_quran': 'Kuran\'dan okuyun',
      'challenge_dhikr': 'Tesbihte 33 zikir çekin',
      'challenges_all_done': 'Maşallah! Bugünün tüm hedefleri tamamlandı',
      'perfect_days_week': 'Bu haftaki tam günler: {n}/7',
      'quran_font': 'Kuran yazı tipi',
      'quran_font_note': 'Her yazı tipi ilk kullanımda yalnızca bir kez indirilir.',
      'night_rec_title': 'Uyumadan önce',
      'night_rec_subtitle': 'Peygamberimizin ﷺ sünnetinden',
      'friday_rec_title': 'Hayırlı Cumalar',
      'friday_rec_subtitle': 'Cuma günü Kehf Suresi\'ni okuyun',
      'rec_ayat_kursi': 'Ayetel Kürsi',
      'rec_baqarah_end': 'Bakara Suresi\'nin son iki ayeti',
      'rec_mulk': 'Mülk Suresi',
      'rec_quls': 'Dört Kul suresi',
      'rec_waqiah': 'Vâkıa Suresi',
      'rec_muzzammil': 'Müzzemmil Suresi',
      'rec_kahf': 'Kehf Suresi',
      'rec_also_common': 'Birçok kişi bunları da okur',
      'mark_done': 'Tamamlandı',
      'mark_not_done': 'Tamamlanmadı',
      'night_reminder': 'Gece okumaları hatırlatıcısı',
      'night_reminder_desc': 'Yatsıdan bir saat sonra',
      'kahf_reminder': 'Cuma günü Kehf Suresi',
      'kahf_reminder_desc': 'Cuma sabahı',
      'night_reminder_title': 'Uyumadan önce 🌙',
      'night_reminder_body': 'Ayetel Kürsi, Mülk Suresi ve Kul sureleri',
      'kahf_reminder_title': 'Hayırlı Cumalar',
      'kahf_reminder_body': 'Bugün Kehf Suresi\'ni okumayı unutmayın',
      'playback_speed': 'Oynatma hızı',
      'mushaf': 'Mushaf',
      'page_n': 'Sayfa {n}',
      'juz_n': 'Cüz {n}',
      'mushaf_tap_hint': 'Mealini görmek, dinlemek veya kaydetmek için bir ayete dokunun',
      'play_from_here': 'Buradan oynat',
      'send_feedback': 'Geri bildirim gönder',
      'send_feedback_desc': 'Bir sorun bildir veya fikir öner',
      'feedback_no_email_app': 'E-posta uygulaması bulunamadı. Bize {email} adresinden yazın',
      'adhan_help': 'Ezan geç mi geliyor ya da hiç gelmiyor mu?',
      'adhan_help_desc': 'Hatırlatıcıları engelleyebilen telefon ayarları',
      'adhan_help_body': 'Bazı telefonlar (örneğin Vivo, Oppo, Xiaomi, Infinix ve Samsung) pil tasarrufu için arka plandaki uygulamaları durdurur; bu da ezanı geciktirebilir veya engelleyebilir.\n\n1. Aşağıdaki düğmeyle uygulama ayarlarını açın.\n2. Pil: "Kısıtlamasız" seçeneğini seçin.\n3. Telefonunuzda "Otomatik başlatma" veya "Arka plan etkinliği" varsa Barakah Time için açın.\n4. Bildirimlere izin verildiğinden emin olun.\n\nArdından hatırlatıcıların yeniden kurulması için Barakah Time\'ı bir kez açın.',
      'refresh_location': 'Konumu güncelle',
      'location_updated': 'Konum güncellendi',
      'default_user_name': 'Bereket Kullanıcısı',
      'sign_in_with_apple': 'Apple ile Giriş Yap',
      'continue_as_guest': 'Şimdi değil',
      'guest_mode_notice':
          'Her şey hesap olmadan çalışır. Yalnızca ilerlemeni yedeklemek ve diğer cihazlarda kullanmak istersen giriş yap.',
      'sign_in_to_sync': 'Senkronize etmek için giriş yap',
      'auth_unavailable_notice':
          'Giriş şu anda kullanılamıyor. Uygulamayı kullanmaya devam edebilirsin; verilerin bu cihazda kalır.',
      'err_auth_unavailable':
          'Giriş şu anda yapılamıyor. Bağlantını kontrol edip uygulamayı yeniden başlat.',
      'err_apple_failed': 'Apple ile giriş başarısız oldu. Lütfen tekrar dene.',
      'err_user_disabled': 'Bu hesap devre dışı bırakıldı.',
      'err_account_exists_different_provider':
          'Bu e-postayla farklı bir giriş yöntemi kullanan bir hesap zaten var.',
      'err_user_mismatch': 'Lütfen sildiğin hesapla giriş yap.',
      'session_expired': 'Oturumun kapatıldı. Lütfen tekrar giriş yap.',
      'email_not_verified':
          'E-postan henüz doğrulanmadı. Doğrulama bağlantısı için gelen kutunu kontrol et.',
      'resend_verification': 'Doğrulama e-postasını tekrar gönder',
      'verification_link_resent':
          'Doğrulama e-postası gönderildi. Gelen kutunu kontrol et.',
      'delete_account': 'Hesabı sil',
      'delete_confirm_word': 'SİL',
      'delete_account_confirm_title': 'Hesabın silinsin mi?',
      'delete_account_confirm_message':
          'Bu işlem hesabını, ilerlemeni, rozetlerini, kayıtlı ayetlerini ve profil fotoğrafını kalıcı olarak siler. Geri alınamaz.',
      'reauth_required_delete':
          'Güvenliğin için hesabını silmeden önce girişini doğrula.',
      'confirm_with_password': 'Devam etmek için şifreni gir',
      'confirm_with_provider': '{provider} ile doğrula',
      'account_deleted': 'Hesabın silindi.',
      'err_delete_account_failed': 'Hesabın silinemedi. Lütfen tekrar dene.',
      'lifetime_points': 'Toplam puan',
      'longest_streak': 'En uzun seri',
      'adhan_sound': 'Ezan sesi',
      'adhan_sound_desc': 'Namaz hatırlatmalarında ezan çal',
      'adjust_times': 'Namaz vakitlerini ayarla',
      'app_theme': 'Tema',
      'theme_system': 'Sistem varsayılanı',
      'theme_light': 'Açık',
      'theme_dark': 'Koyu',
      'adjust_times_desc': 'Her vakti camiinize göre kaydırın',
      'adjust_times_none': 'Değişiklik yok',
      'minutes_short': '{n} dk',
      'adjust_times_note':
          'Vakitler hesaplanan saatten kaydırılır. Yalnızca yerel caminiz farklıysa kullanın.',
      'exact_alarms_hint':
          'Namaz hatırlatmalarının tam vaktinde gelmesi için "Alarmlar ve hatırlatıcılar" iznini ver.',
      'notifications_permission_revoked':
          'Bildirim izni sistem ayarlarından kapatıldı, bu yüzden namaz hatırlatmaları devre dışı bırakıldı.',
      'good_morning': 'Günaydın',
      'good_afternoon': 'Tünaydın',
      'good_evening': 'İyi akşamlar',
      'assalamualaikum': 'Esselamün aleyküm',
      'hijri_year_suffix': 'H',
      'hijri_month_1': 'Muharrem',
      'hijri_month_2': 'Safer',
      'hijri_month_3': 'Rebiülevvel',
      'hijri_month_4': 'Rebiülahir',
      'hijri_month_5': 'Cemaziyelevvel',
      'hijri_month_6': 'Cemaziyelahir',
      'hijri_month_7': 'Recep',
      'hijri_month_8': 'Şaban',
      'hijri_month_9': 'Ramazan',
      'hijri_month_10': 'Şevval',
      'hijri_month_11': 'Zilkade',
      'hijri_month_12': 'Zilhicce',
      'qibla_short': 'Kıble',
      'calendar_short': 'Takvim',
      'more': 'Daha fazla',
      'read_full_ayah': 'Ayetin tamamını oku',
      'shared_from_app': 'Barakah Time ile paylaşıldı',
      'pulse_share_text':
          'Barakah Time ilerlemem: {streak} günlük seri ve bu hafta {points} puan.',
      'points_this_week': 'Bu haftaki puan',
      'current_streak': 'Mevcut seri',
      'day_streak_count': '{n} günlük seri',
      'weekday_points': '{day}: {n} puan',
      'recent_activity': 'Son etkinlikler',
      'no_recent_activity':
          'Henüz etkinlik yok. Başlamak için bir namaz kaydet, Kuran oku veya zikir çek.',
      'activity_prayer': '{prayer} namazı',
      'activity_quran': 'Kuran okuma',
      'activity_dhikr': 'Zikir',
      'activity_other': 'Etkinlik',
      'points_gained': '+{n} puan',
      'prayer_logged_semantics': '{prayer} kaydedildi',
      'log_prayer_semantics': '{prayer} kaydet',
      'prayer_in_label': '{prayer} vaktine',
      'cardinal_n': 'K',
      'cardinal_e': 'D',
      'cardinal_s': 'G',
      'cardinal_w': 'B',
      'qibla_semantics_right': 'Kıble {deg}° sağınızda',
      'qibla_semantics_left': 'Kıble {deg}° solunuzda',
      'qibla_semantics_ahead': 'Kıble tam karşınızda',
      'qibla_compass': 'Kıble pusulası',
      'logged': 'Kaydedildi',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get app_name => translate('app_name');

  // Auth / onboarding / profile / settings / about pages
  String get app_tagline => translate('app_tagline');
  String get onboarding_pulse_title => translate('onboarding_pulse_title');
  String get onboarding_pulse_desc => translate('onboarding_pulse_desc');
  String get onboarding_prayer_title => translate('onboarding_prayer_title');
  String get onboarding_prayer_desc => translate('onboarding_prayer_desc');
  String get onboarding_inspiration_title =>
      translate('onboarding_inspiration_title');
  String get onboarding_inspiration_desc =>
      translate('onboarding_inspiration_desc');
  String get onboarding_next => translate('onboarding_next');
  String get onboarding_get_started => translate('onboarding_get_started');
  String get auth_welcome_back => translate('auth_welcome_back');
  String get auth_sign_in_subtitle => translate('auth_sign_in_subtitle');
  String get auth_email_address => translate('auth_email_address');
  String get auth_password => translate('auth_password');
  String get auth_sign_in => translate('auth_sign_in');
  String get auth_or => translate('auth_or');
  String get auth_no_account => translate('auth_no_account');
  String get auth_sign_up => translate('auth_sign_up');
  String get auth_create_account => translate('auth_create_account');
  String get auth_sign_up_subtitle => translate('auth_sign_up_subtitle');
  String get auth_full_name => translate('auth_full_name');
  String get auth_register => translate('auth_register');
  String get auth_have_account => translate('auth_have_account');
  String authAccountCreatedVerify(Object email) =>
      translate('auth_account_created_verify').replaceAll('{email}', '$email');
  String get profile_saved_verses => translate('profile_saved_verses');
  String profileSavedCount(Object n) =>
      translate('profile_saved_count').replaceAll('{n}', '$n');
  String get profile_activity_history => translate('profile_activity_history');
  String profileLastActivity(Object activity) =>
      translate('profile_last_activity').replaceAll('{activity}', '$activity');
  String get profile_no_saved_verses => translate('profile_no_saved_verses');
  String get profile_remove_verse => translate('profile_remove_verse');
  String get profile_undo => translate('profile_undo');
  String get profile_change_photo => translate('profile_change_photo');
  String get profile_take_photo => translate('profile_take_photo');
  String get profile_choose_gallery => translate('profile_choose_gallery');
  String get profile_guest_title => translate('profile_guest_title');
  String get profile_yesterday => translate('profile_yesterday');
  String get settings_account => translate('settings_account');
  String get settings_prayer => translate('settings_prayer');
  String get settings_support_us => translate('settings_support_us');
  String settingsVersion(Object v) =>
      translate('settings_version').replaceAll('{v}', '$v');
  String get about_title => translate('about_title');
  String get about_description => translate('about_description');
  String get about_credits => translate('about_credits');
  String get about_quran_data => translate('about_quran_data');
  String get about_map_data => translate('about_map_data');
  String get about_map_license => translate('about_map_license');
  String get about_prayer_calc => translate('about_prayer_calc');
  String get about_prayer_calc_source => translate('about_prayer_calc_source');
  String get about_privacy => translate('about_privacy');
  String get about_terms => translate('about_terms');
  String get about_licenses => translate('about_licenses');
  String get about_made_with_love => translate('about_made_with_love');
  String get about_link_failed => translate('about_link_failed');

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
  String get asr_calculation => translate('asr_calculation');
  String get asr_shafi => translate('asr_shafi');
  String get asr_hanafi => translate('asr_hanafi');
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
  String get sunrise => translate('sunrise');
  String get tomorrow_fajr => translate('tomorrow_fajr');
  String get location_not_found => translate('location_not_found');
  String get location_services_disabled =>
      translate('location_services_disabled');
  String get location_permission_denied =>
      translate('location_permission_denied');
  String get location_permission_denied_forever =>
      translate('location_permission_denied_forever');
  String get location_timeout => translate('location_timeout');
  String get location_required => translate('location_required');
  String get open_settings => translate('open_settings');
  String get grant_access_retry => translate('grant_access_retry');
  String get set_manual_location_hint => translate('set_manual_location_hint');
  String get locating => translate('locating');
  String get location_unavailable => translate('location_unavailable');
  String get prayer_not_started => translate('prayer_not_started');
  String get prayer_already_logged => translate('prayer_already_logged');
  String get prayer_notification_title =>
      translate('prayer_notification_title');
  String get prayer_notification_body => translate('prayer_notification_body');
  String get pulse_load_failed => translate('pulse_load_failed');
  String get names_99_short => translate('names_99_short');
  String get duas_short => translate('duas_short');
  String get tasbeeh_short => translate('tasbeeh_short');

  String get name_required => translate('name_required');
  String get email_required => translate('email_required');
  String get invalid_email => translate('invalid_email');
  String get password_required => translate('password_required');
  String get password_too_short => translate('password_too_short');
  String get passwords_do_not_match => translate('passwords_do_not_match');
  String get confirm_password => translate('confirm_password');
  String get err_user_not_found => translate('err_user_not_found');
  String get err_wrong_credentials => translate('err_wrong_credentials');
  String get err_email_in_use => translate('err_email_in_use');
  String get err_network => translate('err_network');
  String get err_too_many_requests => translate('err_too_many_requests');
  String get err_recent_login => translate('err_recent_login');
  String get err_upload_failed => translate('err_upload_failed');
  String get err_profile_update_failed =>
      translate('err_profile_update_failed');
  String get err_google_failed => translate('err_google_failed');
  String get profile_updated => translate('profile_updated');
  String get photo_updated => translate('photo_updated');
  String get verification_email_sent => translate('verification_email_sent');
  String get forgot_password => translate('forgot_password');
  String get reset_password => translate('reset_password');
  String get reset_password_hint => translate('reset_password_hint');
  String get send_link => translate('send_link');
  String get reset_email_sent => translate('reset_email_sent');
  String get email => translate('email');
  String get name => translate('name');
  String get photo_permission_denied => translate('photo_permission_denied');
  String get photo_pick_failed => translate('photo_pick_failed');
  String get member_since => translate('member_since');
  String get my_profile => translate('my_profile');
  String get points => translate('points');
  String get badges => translate('badges');
  String get sign_out => translate('sign_out');
  String get sign_out_confirm => translate('sign_out_confirm');
  String get notifications_subtitle => translate('notifications_subtitle');
  String get location_settings => translate('location_settings');
  String get auto_location => translate('auto_location');
  String get manual_location => translate('manual_location');
  String get location_access_required => translate('location_access_required');
  String get rate_now => translate('rate_now');
  String get later => translate('later');
  String get rate_us_message => translate('rate_us_message');
  String get app_store_coming_soon => translate('app_store_coming_soon');
  String get store_open_failed => translate('store_open_failed');
  String get close => translate('close');
  String get skip => translate('skip');

  String get all_tools => translate('all_tools');
  String get ayah => translate('ayah');
  String get ayahs => translate('ayahs');
  String get calibrate_compass => translate('calibrate_compass');
  String get compass_unavailable => translate('compass_unavailable');
  String get could_not_open_maps => translate('could_not_open_maps');
  String get degrees_from_north => translate('degrees_from_north');
  String get detecting_location => translate('detecting_location');
  String get directions => translate('directions');
  String get facing_qibla => translate('facing_qibla');
  String get finding_mosques => translate('finding_mosques');
  String get in_days => translate('in_days');
  String get listen_translation => translate('listen_translation');
  String get location_error_message => translate('location_error_message');
  String get mark_as_read => translate('mark_as_read');
  String get mosques_load_error => translate('mosques_load_error');
  String get no_mosques_match => translate('no_mosques_match');
  String get no_mosques_nearby => translate('no_mosques_nearby');
  String get now_playing => translate('now_playing');
  String get open_in_maps => translate('open_in_maps');
  String get pause => translate('pause');
  String get play => translate('play');
  String get play_surah => translate('play_surah');
  String get quran_load_error => translate('quran_load_error');
  String get reset_counter_message => translate('reset_counter_message');
  String get reset_counter_title => translate('reset_counter_title');
  String get share => translate('share');
  String get stop => translate('stop');
  String get surah_already_logged_today =>
      translate('surah_already_logged_today');
  String get surah_load_error => translate('surah_load_error');
  String get surah_logged => translate('surah_logged');
  String get today => translate('today');
  String get tomorrow => translate('tomorrow');
  String get translation => translate('translation');
  String get unnamed_mosque => translate('unnamed_mosque');
  String get zakat_above_nisab => translate('zakat_above_nisab');
  String get zakat_below_nisab => translate('zakat_below_nisab');
  String get zakat_gold_nisab => translate('zakat_gold_nisab');
  String get zakat_gold_price => translate('zakat_gold_price');
  String get zakat_invalid_amount => translate('zakat_invalid_amount');
  String get zakat_liabilities => translate('zakat_liabilities');
  String get zakat_net_wealth => translate('zakat_net_wealth');
  String get zakat_nisab_standard => translate('zakat_nisab_standard');
  String get zakat_nisab_unknown => translate('zakat_nisab_unknown');
  String get zakat_no_wealth => translate('zakat_no_wealth');
  String get zakat_silver_nisab => translate('zakat_silver_nisab');
  String get zakat_silver_price => translate('zakat_silver_price');

  // Shared UI widgets (lib/presentation/widgets)
  String get clear_search => translate('clear_search');
  String get confirm => translate('confirm');
  String get continue_with_apple => translate('continue_with_apple');
  String get continue_with_google => translate('continue_with_google');
  String get dismiss => translate('dismiss');
  String get hide_password => translate('hide_password');
  String get loading => translate('loading');
  String get show_password => translate('show_password');
  String get something_went_wrong => translate('something_went_wrong');
  String typeToConfirm(String text) =>
      translate('type_to_confirm').replaceAll('{text}', text);

  String get badge_first_step => translate('badge_first_step');
  String get badge_first_step_desc => translate('badge_first_step_desc');
  String get badge_streak_7 => translate('badge_streak_7');
  String get badge_streak_7_desc => translate('badge_streak_7_desc');
  String get badge_streak_30 => translate('badge_streak_30');
  String get badge_streak_30_desc => translate('badge_streak_30_desc');
  String get badge_streak_100 => translate('badge_streak_100');
  String get badge_streak_100_desc => translate('badge_streak_100_desc');
  String get badge_daily_achiever => translate('badge_daily_achiever');
  String get badge_daily_achiever_desc =>
      translate('badge_daily_achiever_desc');
  String get badge_spiritual_veteran => translate('badge_spiritual_veteran');
  String get badge_spiritual_veteran_desc =>
      translate('badge_spiritual_veteran_desc');
  String get badge_points_1000 => translate('badge_points_1000');
  String get badge_points_1000_desc => translate('badge_points_1000_desc');
  String get no_badges_yet => translate('no_badges_yet');
  String get motivation_achieved => translate('motivation_achieved');
  String get motivation_almost => translate('motivation_almost');
  String get motivation_halfway => translate('motivation_halfway');
  String get motivation_started => translate('motivation_started');
  String get motivation_start => translate('motivation_start');
  String get method_mwl => translate('method_mwl');
  String get method_karachi => translate('method_karachi');
  String get method_isna => translate('method_isna');
  String get method_umm_al_qura => translate('method_umm_al_qura');
  String get method_egyptian => translate('method_egyptian');
  String get method_dubai => translate('method_dubai');
  String get method_qatar => translate('method_qatar');
  String get method_kuwait => translate('method_kuwait');
  String get method_turkey => translate('method_turkey');
  String get method_tehran => translate('method_tehran');
  String get method_singapore => translate('method_singapore');
  String get method_moonsighting => translate('method_moonsighting');
  String get unknown_city => translate('unknown_city');
  String get default_user_name => translate('default_user_name');
  String get sign_in_with_apple => translate('sign_in_with_apple');
  String get continue_as_guest => translate('continue_as_guest');
  String get guest_mode_notice => translate('guest_mode_notice');
  String get refresh_location => translate('refresh_location');
  String get mushaf => translate('mushaf');
  String get daily_challenges => translate('daily_challenges');
  String get challenges_hint => translate('challenges_hint');
  String get challenge_prayers => translate('challenge_prayers');
  String get challenge_quran => translate('challenge_quran');
  String get challenge_dhikr => translate('challenge_dhikr');
  String get challenges_all_done => translate('challenges_all_done');
  String perfectDaysWeek(int n) =>
      translate('perfect_days_week').replaceAll('{n}', '$n');
  String get quran_font => translate('quran_font');
  String get quran_font_note => translate('quran_font_note');
  String get night_rec_title => translate('night_rec_title');
  String get night_rec_subtitle => translate('night_rec_subtitle');
  String get friday_rec_title => translate('friday_rec_title');
  String get friday_rec_subtitle => translate('friday_rec_subtitle');
  String get rec_ayat_kursi => translate('rec_ayat_kursi');
  String get rec_baqarah_end => translate('rec_baqarah_end');
  String get rec_mulk => translate('rec_mulk');
  String get rec_quls => translate('rec_quls');
  String get rec_waqiah => translate('rec_waqiah');
  String get rec_muzzammil => translate('rec_muzzammil');
  String get rec_kahf => translate('rec_kahf');
  String get rec_also_common => translate('rec_also_common');
  String get mark_done => translate('mark_done');
  String get mark_not_done => translate('mark_not_done');
  String get night_reminder => translate('night_reminder');
  String get night_reminder_desc => translate('night_reminder_desc');
  String get kahf_reminder => translate('kahf_reminder');
  String get kahf_reminder_desc => translate('kahf_reminder_desc');
  String get night_reminder_title => translate('night_reminder_title');
  String get night_reminder_body => translate('night_reminder_body');
  String get kahf_reminder_title => translate('kahf_reminder_title');
  String get kahf_reminder_body => translate('kahf_reminder_body');
  String get playback_speed => translate('playback_speed');
  String pageN(int n) => translate('page_n').replaceAll('{n}', '$n');
  String juzN(int n) => translate('juz_n').replaceAll('{n}', '$n');
  String get mushaf_tap_hint => translate('mushaf_tap_hint');
  String get play_from_here => translate('play_from_here');
  String get send_feedback => translate('send_feedback');
  String get send_feedback_desc => translate('send_feedback_desc');
  String feedbackNoEmailApp(String email) =>
      translate('feedback_no_email_app').replaceAll('{email}', email);
  String get adhan_help => translate('adhan_help');
  String get adhan_help_desc => translate('adhan_help_desc');
  String get adhan_help_body => translate('adhan_help_body');
  String get location_updated => translate('location_updated');
  String get sign_in_to_sync => translate('sign_in_to_sync');
  String get auth_unavailable_notice => translate('auth_unavailable_notice');
  String get err_auth_unavailable => translate('err_auth_unavailable');
  String get err_apple_failed => translate('err_apple_failed');
  String get err_user_disabled => translate('err_user_disabled');
  String get err_account_exists_different_provider =>
      translate('err_account_exists_different_provider');
  String get err_user_mismatch => translate('err_user_mismatch');
  String get session_expired => translate('session_expired');
  String get email_not_verified => translate('email_not_verified');
  String get resend_verification => translate('resend_verification');
  String get verification_link_resent => translate('verification_link_resent');
  String get delete_account => translate('delete_account');
  String get delete_account_confirm_title =>
      translate('delete_account_confirm_title');
  String get delete_account_confirm_message =>
      translate('delete_account_confirm_message');
  String get reauth_required_delete => translate('reauth_required_delete');
  String get confirm_with_password => translate('confirm_with_password');
  String get account_deleted => translate('account_deleted');
  String get err_delete_account_failed =>
      translate('err_delete_account_failed');
  String get lifetime_points => translate('lifetime_points');
  String get longest_streak => translate('longest_streak');
  String get adhan_sound => translate('adhan_sound');
  String get adhan_sound_desc => translate('adhan_sound_desc');
  String get adjust_times => translate('adjust_times');
  String get app_theme => translate('app_theme');
  String get theme_system => translate('theme_system');
  String get theme_light => translate('theme_light');
  String get theme_dark => translate('theme_dark');
  String get adjust_times_desc => translate('adjust_times_desc');
  String get adjust_times_none => translate('adjust_times_none');
  String get adjust_times_note => translate('adjust_times_note');
  String minutesShort(int n) =>
      translate('minutes_short').replaceAll('{n}', n > 0 ? '+$n' : '$n');
  String get exact_alarms_hint => translate('exact_alarms_hint');
  String get notifications_permission_revoked =>
      translate('notifications_permission_revoked');

  String get good_morning => translate('good_morning');
  String get good_afternoon => translate('good_afternoon');
  String get good_evening => translate('good_evening');
  String get assalamualaikum => translate('assalamualaikum');
  String get hijri_year_suffix => translate('hijri_year_suffix');
  String get hijri_month_1 => translate('hijri_month_1');
  String get hijri_month_2 => translate('hijri_month_2');
  String get hijri_month_3 => translate('hijri_month_3');
  String get hijri_month_4 => translate('hijri_month_4');
  String get hijri_month_5 => translate('hijri_month_5');
  String get hijri_month_6 => translate('hijri_month_6');
  String get hijri_month_7 => translate('hijri_month_7');
  String get hijri_month_8 => translate('hijri_month_8');
  String get hijri_month_9 => translate('hijri_month_9');
  String get hijri_month_10 => translate('hijri_month_10');
  String get hijri_month_11 => translate('hijri_month_11');
  String get hijri_month_12 => translate('hijri_month_12');
  String get qibla_short => translate('qibla_short');
  String get calendar_short => translate('calendar_short');
  String get more => translate('more');
  String get read_full_ayah => translate('read_full_ayah');
  String get shared_from_app => translate('shared_from_app');
  String get pulse_share_text => translate('pulse_share_text');
  String get points_this_week => translate('points_this_week');
  String get current_streak => translate('current_streak');
  String get day_streak_count => translate('day_streak_count');
  String get weekday_points => translate('weekday_points');
  String get recent_activity => translate('recent_activity');
  String get no_recent_activity => translate('no_recent_activity');
  String get activity_prayer => translate('activity_prayer');
  String get activity_quran => translate('activity_quran');
  String get activity_dhikr => translate('activity_dhikr');
  String get activity_other => translate('activity_other');
  String get points_gained => translate('points_gained');
  String get prayer_logged_semantics => translate('prayer_logged_semantics');
  String get log_prayer_semantics => translate('log_prayer_semantics');
  String get prayer_in_label => translate('prayer_in_label');
  String get cardinal_n => translate('cardinal_n');
  String get cardinal_e => translate('cardinal_e');
  String get cardinal_s => translate('cardinal_s');
  String get cardinal_w => translate('cardinal_w');
  String get qibla_semantics_right => translate('qibla_semantics_right');
  String get qibla_semantics_left => translate('qibla_semantics_left');
  String get qibla_semantics_ahead => translate('qibla_semantics_ahead');
  String get qibla_compass => translate('qibla_compass');
  String get logged => translate('logged');

  String get search_surahs => translate('search_surahs');
  String get continue_reading => translate('continue_reading');
  String get no_surahs_found => translate('no_surahs_found');
  String get meccan => translate('meccan');
  String get medinan => translate('medinan');
  String get verse_saved => translate('verse_saved');
  String get verse_removed => translate('verse_removed');
  String get save_verse => translate('save_verse');
  String get remove_saved_verse => translate('remove_saved_verse');
  String get share_ayah_heading => translate('share_ayah_heading');
  String get copy => translate('copy');
  String get copied => translate('copied');
  String get meaning => translate('meaning');
  String get transliteration => translate('transliteration');
  String get name_number => translate('name_number');
  String get alhamdulillah => translate('alhamdulillah');
  String get allahu_akbar => translate('allahu_akbar');
  String get astaghfirullah => translate('astaghfirullah');
  String get la_ilaha_illallah => translate('la_ilaha_illallah');
  String get tasbeeh_target => translate('tasbeeh_target');
  String get tasbeeh_custom => translate('tasbeeh_custom');
  String get tasbeeh_custom_target => translate('tasbeeh_custom_target');
  String get tasbeeh_round => translate('tasbeeh_round');
  String get tasbeeh_total => translate('tasbeeh_total');
  String get tasbeeh_target_reached => translate('tasbeeh_target_reached');
  String get tasbeeh_counter_semantics =>
      translate('tasbeeh_counter_semantics');
  String get tasbeeh_target_invalid => translate('tasbeeh_target_invalid');
  String get zakat_currency => translate('zakat_currency');
  String get zakat_currency_hint => translate('zakat_currency_hint');
  String get distance_m => translate('distance_m');
  String get distance_km => translate('distance_km');
  String get osm_attribution => translate('osm_attribution');

  String get delete_confirm_word => translate('delete_confirm_word');

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
