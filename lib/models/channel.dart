class Channel {
  final String name;
  final String url;
  final String? logo;
  final String? group;
  bool isFavorite;

  Channel({
    required this.name,
    required this.url,
    this.logo,
    this.group,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'logo': logo,
      'group': group,
      'isFavorite': isFavorite,
    };
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      logo: json['logo'],
      group: json['group'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Channel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          url == other.url;

  @override
  int get hashCode => name.hashCode ^ url.hashCode;
}