import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/channel.dart';
import '../services/m3u_parser.dart';

class PlaylistProvider extends ChangeNotifier {
  static const String _urlKey = 'playlist_url';
  static const String _channelsKey = 'channels_cache';
  static const String _favoritesKey = 'favorites';
  static const String _defaultUrl =
      'https://iptv-org.github.io/iptv/index.m3u';

  List<Channel> _allChannels = [];
  List<Channel> _filteredChannels = [];
  String _playlistUrl = _defaultUrl;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Channel> get allChannels => _allChannels;
  List<Channel> get filteredChannels => _filteredChannels;
  String get playlistUrl => _playlistUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  String get searchQuery => _searchQuery;

  List<String> get categories {
    final groups = <String>{};
    for (final channel in _allChannels) {
      if (channel.group != null) {
        groups.add(channel.group!);
      }
    }
    return ['All', ...groups.toList()..sort()];
  }

  Future<void> initializePlaylist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_urlKey);
      _playlistUrl = savedUrl ?? _defaultUrl;

      // Try to load from cache first
      final cachedChannels = prefs.getString(_channelsKey);
      if (cachedChannels != null && cachedChannels.isNotEmpty) {
        _loadFromCache(cachedChannels, prefs);
        _isLoading = false;
        notifyListeners();
        return;
      }

      // If no cache, fetch from URL
      await _fetchAndParsePlaylist(_playlistUrl, prefs);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadFromCache(String cachedJson, SharedPreferences prefs) {
    try {
      final decoded = jsonDecode(cachedJson) as List;
      _allChannels =
          decoded.map((item) => Channel.fromJson(item)).toList();

      // Load favorites
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      for (final channel in _allChannels) {
        channel.isFavorite = favoritesList.contains(channel.name);
      }

      _filteredChannels = _allChannels;
    } catch (e) {
      _error = 'Failed to load cached channels: $e';
    }
  }

  Future<void> _fetchAndParsePlaylist(
    String url,
    SharedPreferences prefs,
  ) async {
    try {
      final channels = await M3uParser.parseUrl(url);

      // Load favorites
      final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
      for (final channel in channels) {
        channel.isFavorite = favoritesList.contains(channel.name);
      }

      _allChannels = channels;
      _filteredChannels = channels;

      // Save to cache
      final encoded =
          jsonEncode(_allChannels.map((c) => c.toJson()).toList());
      await prefs.setString(_channelsKey, encoded);
      await prefs.setString(_urlKey, url);

      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePlaylistUrl(String newUrl) async {
    if (newUrl.isEmpty) {
      _error = 'URL cannot be empty';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await _fetchAndParsePlaylist(newUrl, prefs);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void searchChannels(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredChannels = _allChannels;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredChannels = _allChannels
          .where((channel) =>
              channel.name.toLowerCase().contains(lowerQuery) ||
              (channel.group?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    if (category == 'All') {
      _filteredChannels = _allChannels;
    } else {
      _filteredChannels =
          _allChannels.where((c) => c.group == category).toList();
    }

    // Re-apply search filter if active
    if (_searchQuery.isNotEmpty) {
      searchChannels(_searchQuery);
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(Channel channel) async {
    channel.isFavorite = !channel.isFavorite;

    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey) ?? [];

    if (channel.isFavorite) {
      favoritesList.add(channel.name);
    } else {
      favoritesList.remove(channel.name);
    }

    await prefs.setStringList(_favoritesKey, favoritesList);
    notifyListeners();
  }

  List<Channel> getFavorites() {
    return _allChannels.where((c) => c.isFavorite).toList();
  }
}