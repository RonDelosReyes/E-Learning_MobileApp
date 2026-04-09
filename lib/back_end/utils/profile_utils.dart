// Returns a safe profile image URL or fallback
String getValidProfileImage(String? url) {
  if (url == null || url.isEmpty) {
    // fallback placeholder
    return 'assets/profile_placeholder.png';
  }
  return url;
}
