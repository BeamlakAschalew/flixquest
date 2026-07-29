class InAppMessagePayload {
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl;
  final String? buttonText;
  final String displayType; // 'modal', 'bottom_sheet', 'banner'

  InAppMessagePayload({
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    this.buttonText,
    this.displayType = 'modal',
  });

  factory InAppMessagePayload.fromMap(Map<String, dynamic> data) {
    return InAppMessagePayload(
      title: data['title'] ?? data['notification_title'] ?? '',
      body: data['body'] ?? data['notification_body'] ?? '',
      imageUrl: data['image_url'] ?? data['imageUrl'],
      actionUrl: data['action_url'] ?? data['actionUrl'],
      buttonText: data['button_text'] ?? data['buttonText'],
      displayType: (data['display_type'] ?? data['displayType'] ?? 'modal').toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'action_url': actionUrl,
      'button_text': buttonText,
      'display_type': displayType,
    };
  }
}
