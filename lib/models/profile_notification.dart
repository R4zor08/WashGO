class ProfileNotification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;

  const ProfileNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  ProfileNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    bool? isRead,
  }) {
    return ProfileNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}
