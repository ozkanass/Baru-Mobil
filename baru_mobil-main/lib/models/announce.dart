class Announce {
  final int id;
  final String title;
  final String content;
  final DateTime date;
  final String imageUrl;

  Announce({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.imageUrl,
  });

  factory Announce.fromJson(Map<String, dynamic> json) {
    return Announce(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      imageUrl: json['image_url'],
    );
  }
}
