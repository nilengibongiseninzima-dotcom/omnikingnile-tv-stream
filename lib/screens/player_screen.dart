import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import '../models/channel.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;

  const PlayerScreen({
    Key? key,
    required this.channel,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
      autoPlay: true,
      looping: true,
      fullScreenByDefault: false,
      allowedScreenSleep: false,
      placeholder: SizedBox.expand(
        child: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        ),
      ),
      aspectRatio: 16 / 9,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableModripper: true,
        enablePip: true,
        controlBarTextStyle: const TextStyle(
          color: Colors.white,
        ),
        controlBarHeight: 48,
        playIcon: Icons.play_arrow,
        pauseIcon: Icons.pause,
        forwardSkipTimeInMilliseconds: 10000,
        backwardSkipTimeInMilliseconds: 10000,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.channel.url,
        videoFormat: BetterPlayerVideoFormat.hls,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 10 * 1024 * 1024,
          maxCacheSize: 100 * 1024 * 1024,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.channel.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player
            BetterPlayer(
              controller: _betterPlayerController,
            ),
            // Channel Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.channel.group != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.channel.group!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red[300],
                            ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Stream URL:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[300],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a2a),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.channel.url,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[400],
                                fontFamily: 'monospace',
                              ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}