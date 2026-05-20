Main Idea:

The app automatically tracks the user's working time based on Wi-Fi network connection.

When the user connects to a specific workspace Wi-Fi network, the timer starts automatically.
When the user disconnects from that Wi-Fi network, the timer stops automatically.
The tracked time is saved daily and summarized weekly.
Core Features:
Authentication:

Use Firebase Authentication:

Email / Password login
Google Sign-In
Each tracked time record must be linked to the logged-in account.
Display the logged-in user's:
Full Name
Email
Profile Photo (if available)
User Identity Display:

On Home Dashboard show clearly:

Welcome message with user name
Account currently tracking time
Profile avatar
Email address
Device currently synced

Example:
Tracking Time For: Ali Majed

Database:

Use Firebase Firestore for storing:

User profile
Daily working sessions
Weekly summaries
Device synchronization data
Account-specific reports
Sync:
Real-time synchronization across two devices or more
If user logs in from another device, same data appears instantly.
Automatic Time Tracking:
Detect connection to selected workspace Wi-Fi SSID.
Start timer automatically.
Stop timer automatically.
Save session start/end time under current user account.
Dashboard:

Show:

User Name + Avatar
Current Day Name
Full Date
Live Clock
Current Wi-Fi status
Current tracking status
Today's worked hours
This week's total hours
Weekly Reports:
Hours grouped by logged-in account
Weekly chart
Daily breakdown
Total weekly hours
Average daily hours
Notifications:
Work session started for current user
Work session ended
Daily reminder
Settings:
Choose workspace Wi-Fi name
Change profile info
Dark / Light mode
Arabic / English
Logout / Switch account
Device sync settings
UI Design:

Modern premium productivity UI:

Clean professional style
Material 3
Animated dashboard
Cards with gradients
Smooth transitions
Architecture:

Use:

Riverpod for State Management
MVVM
Repository Pattern
Firebase Service Layer
Required Packages:

firebase_core
firebase_auth
cloud_firestore
google_sign_in
network_info_plus
flutter_local_notifications
intl
fl_chart
flutter_riverpod

Screens:
Splash
Login
Register
Home Dashboard
Weekly Reports
History Sessions
Profile Screen
Settings
Device Sync Screen
Extra Features:
Export PDF reports with user name
Multi-account support
Offline save then sync later
Productivity score per user
Attendance history
Important:

Generate full production-ready Flutter code with clean folder structure, reusable widgets, responsive UI, and Firebase integration.

lib/
│── main.dart
│── firebase_options.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_assets.dart
│   │   └── firebase_constants.dart
│   │
│   ├── theme/
│   │   ├── light_theme.dart
│   │   ├── dark_theme.dart
│   │   └── theme_provider.dart
│   │
│   ├── utils/
│   │   ├── date_helper.dart
│   │   ├── time_helper.dart
│   │   ├── wifi_helper.dart
│   │   ├── validators.dart
│   │   └── extensions.dart
│   │
│   ├── services/
│   │   ├── firebase_service.dart
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── wifi_tracking_service.dart
│   │   ├── notification_service.dart
│   │   ├── sync_service.dart
│   │   └── local_storage_service.dart
│   │
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_textfield.dart
│       ├── loading_widget.dart
│       ├── user_avatar.dart
│       ├── stat_card.dart
│       └── weekly_chart.dart
│
├── features/
│
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   │ 
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   └── register_screen.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── dashboard_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── live_clock.dart
│   │   │       ├── tracking_status_card.dart
│   │   │       ├── today_hours_card.dart
│   │   │       └── user_header.dart
│
│   ├── tracking/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── session_model.dart
│   │   │   └── repositories/
│   │   │       └── tracking_repository_impl.dart
│   │   │
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── session_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── tracking_repository.dart
│   │   │   └── usecases/
│   │   │       ├── start_tracking.dart
│   │   │       ├── stop_tracking.dart
│   │   │       └── get_today_hours.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── tracking_provider.dart
│   │       └── screens/
│   │           └── history_screen.dart
│
│   ├── reports/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── reports_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── weekly_report_screen.dart
│   │   │   └── widgets/
│   │   │       ├── report_chart.dart
│   │   │       └── report_card.dart
│
│   ├── profile/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart
│   │   │   └── screens/
│   │   │       └── profile_screen.dart
│
│   ├── settings/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── settings_provider.dart
│   │   │   └── screens/
│   │   │       └── settings_screen.dart
│
│   └── sync/
│       ├── presentation/
│       │   ├── providers/
│       │   │   └── sync_provider.dart
│       │   └── screens/
│       │       └── devices_screen.dart
│
├── routes/
    ├── app_router.dart
    └── route_names.dart


