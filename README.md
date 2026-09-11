Zamindar App 🌱
A Flutter-based mobile application for zamindar.co — an e-commerceplatform for agricultural products (seeds, fertilizers, tools, and more).

📱 About
Zamindar App connects farmers and agricultural businesses with qualityfarming products. The app is being integrated with the WordPress/WooCommercebackend at zamindar.co.

Current Status:

✅ UI complete (Onboarding, Home, Categories, Cart, Checkout flow)
✅ Cart system with Provider state management
✅ Profile photo persistence (local storage)
🔄 Backend integration in progress (WooCommerce Store API + JWT Auth)
🛠️ Tech Stack
Framework: Flutter (Dart)
State Management: Provider
Backend: WordPress + WooCommerce (integration in progress)
Authentication: JWT (planned)
🚀 Getting Started
Prerequisites
Flutter SDK (latest stable)
VS Code or Android Studio
Android emulator or physical device
Setup
Clone the repository:
git clone https://github.com/hammadraza-hub/Zamindar.git
Navigate to the project folder:
bash

cd zamindar
Install dependencies:
bash

flutter pub get
Run the app:
bash

flutter run
📁 Project Structure
text

lib/
├── config/           # App configuration (API endpoints, constants)
├── models/           # Data models
├── providers/        # State management (Provider)
├── repositories/     # Data repositories (API calls)
├── screens/          # UI screens
│   ├── onboarding_screen.dart
│   ├── splash_screen.dart
│   ├── main_navigation_screen.dart
│   ├── home_screen.dart
│   ├── categories_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   └── ...
├── services/
│   ├── api/          # API client layer
│   ├── auth/         # Authentication services
│   └── cart_provider.dart
├── utils/            # Utilities (colors, strings)
└── widgets/          # Reusable widgets
🗺️ Roadmap
 M0: Project cleanup & structure
 M1: WordPress backend setup (Store API + JWT)
 M2: Authentication (Login/Signup)
 M3: Real products from WooCommerce
 M4: Cart sync
 M5: Real orders & checkout
 M6: Payments (COD, JazzCash, Easypaisa)
 M7: Orders history
 M8: User account & addresses
👨‍💻 Author
Hammad Raza — hammadraza-hub

