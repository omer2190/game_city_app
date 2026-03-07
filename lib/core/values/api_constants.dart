class ApiConstants {
  // static const String baseUrl = 'http://192.168.0.189:7000';
  static const String baseUrl = 'https://orca-app-l477g.ondigitalocean.app';
  // static const String baseUrl = 'https://gaming-city-seven.vercel.app';

  // Auth Endpoints
  static const String login = '$baseUrl/api/users/login';
  static const String register = '$baseUrl/api/users/register';
  static const String verifyAccount = '$baseUrl/api/users/verify';
  static const String forgotPassword = '$baseUrl/api/users/forgot-password';
  static const String resetPassword = '$baseUrl/api/users/reset-password';
  static const String changePassword = '$baseUrl/api/users/change-password';
  static const String googleLogin = '$baseUrl/api/users/google-login';
  static const String userProfile = '$baseUrl/api/users/me/profile';
  static const String updateUser = '$baseUrl/api/users/';

  // Games Endpoints
  static const String games = '$baseUrl/api/games';
  static const String gameSearchOrRequest =
      '$baseUrl/api/games/search-or-request';
  static const String friendsSuggestions = '$baseUrl/api/friends/suggestions';
  static const String friendsList = '$baseUrl/api/friends/list';
  static const String friendRequest = '$baseUrl/api/friends/request';
  static const String acceptFriendRequest = '$baseUrl/api/friends/accept';
  static const String pendingRequests = '$baseUrl/api/friends/requests/pending';
  static const String socialMedia = '$baseUrl/api/socialMedia';
  static const String socialMediaLink = '$baseUrl/api/socialMedia/link';

  // Chat
  static const String chatSend = '$baseUrl/api/chat/send';
  static const String chatRooms = '$baseUrl/api/chat/rooms';

  // News
  static const String news = '$baseUrl/api/news/';

  // User Info
  static const String userInfoTypes = '$baseUrl/api/user-info/types';
  static const String userInfo = '$baseUrl/api/user-info';

  // Notifications
  static const String notifications = '$baseUrl/api/notifications';

  // Wishlist
  static const String toggleWishlist = '$baseUrl/api/wishlist/toggle';
  static const String myWishlist = '$baseUrl/api/wishlist/my';

  // Home Dashboard
  static const String homeDashboard = '$baseUrl/api/reports/home';

  // Version Check
  static const String checkVersion = '$baseUrl/api/version/check';
}
