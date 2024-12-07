class Sticker {
  final String id;
  final String url;

  Sticker({required this.id, required this.url});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
    };
  }

  static Sticker fromMap(Map<String, dynamic> map) {
    return Sticker(
      id: map['id'],
      url: map['url'],
    );
  }
}
