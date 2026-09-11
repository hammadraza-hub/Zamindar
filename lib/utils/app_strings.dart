/// Centralized location for reusable text strings across the app.
/// Add more as new screens/modules are built (auth, checkout, etc.)
class AppStrings {
  AppStrings._(); // prevent instantiation

  // ---------- App General ----------
  static const String appName = 'Zamindar';

  // ---------- Generic Actions ----------
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String save = 'Save';
  static const String continueText = 'Continue';
  static const String submit = 'Submit';

  // ---------- Generic Messages ----------
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String noInternetConnection =
      'No internet connection. Please check your network.';
  static const String requestTimeout = 'Request timed out. Please try again.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String loading = 'Loading...';
  static const String noDataFound = 'No data found.';

  // ---------- Validation Messages ----------
  static const String fieldRequired = 'This field is required.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String passwordTooShort =
      'Password must be at least 6 characters.';
  static const String passwordsDoNotMatch = 'Passwords do not match.';

  // ---------- Auth ----------
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String forgotPassword = 'Forgot Password?';
  static const String continueAsGuest = 'Continue as Guest';
  static const String loginFailed =
      'Login failed. Please check your credentials.';
  static const String signupFailed = 'Registration failed. Please try again.';

  // ---------- Cart & Checkout ----------
  static const String addToCart = 'Add to Cart';
  static const String cartEmpty = 'Your cart is empty.';
  static const String placeOrder = 'Place Order';
  static const String orderPlacedSuccess =
      'Your order has been placed successfully!';
  static const String orderFailed =
      'Could not place your order. Please try again.';

  // ---------- Orders ----------
  static const String noOrdersYet = 'You have no orders yet.';
  static const String orderHistory = 'Order History';
}
