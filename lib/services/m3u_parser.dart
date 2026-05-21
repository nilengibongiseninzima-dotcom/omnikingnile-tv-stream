import 'package:http/http.dart' as http;
import '../models/channel.dart';

class M3uParser {
  static Future<List<Channel>> parseUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load playlist: ${response.statusCode}');
      }

      return parseContent(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static List<Channel> parseContent(String content) {
    final lines = content.split('\n');
    final channels = <Channel>[];
    String? currentName;
    String? currentLogo;
    String? currentGroup;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF:')) {
        // Parse metadata line
        currentName = _extractName(line);
        currentLogo = _extractAttribute(line, 'tvg-logo');
        currentGroup = _extractAttribute(line, 'group-title');
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        // Parse URL line
        if (currentName != null && currentName.isNotEmpty) {
          channels.add(
            Channel(
              name: currentName,
              url: line,
              logo: currentLogo,
              group: currentGroup ?? 'Other',
            ),
          );
        }
        currentName = null;
        currentLogo = null;
        currentGroup = null;
      }
    }

    return channels;
  }

  static String _extractName(String extinf) {
    // Format: #EXTINF:-1 tvg-id="..." tvg-logo="..." group-title="..." , Channel Name
    final parts = extinf.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    return 'Unknown Channel';
  }

  static String? _extractAttribute(String extinf, String attribute) {
    final regex = RegExp('$attribute="([^"]*)"');
    final match = regex.firstMatch(extinf);
    return match?.group(1);
  }
}