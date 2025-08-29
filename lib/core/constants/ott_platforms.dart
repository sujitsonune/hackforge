class OTTPlatform {
  final String id;
  final String name;
  final String category;
  final String logoUrl;
  final List<double> popularPlans;
  final String color;

  const OTTPlatform({
    required this.id,
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.popularPlans,
    required this.color,
  });
}

class OTTPlatforms {
  static const List<OTTPlatform> platforms = [
    // Video Streaming
    OTTPlatform(
      id: 'netflix',
      name: 'Netflix',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/netflix.png',
      popularPlans: [199, 499, 649, 799],
      color: '#E50914',
    ),
    OTTPlatform(
      id: 'amazon_prime',
      name: 'Amazon Prime Video',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/amazon_prime.png',
      popularPlans: [179, 459, 1499],
      color: '#00A8E1',
    ),
    OTTPlatform(
      id: 'disney_hotstar',
      name: 'Disney+ Hotstar',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/disney_hotstar.png',
      popularPlans: [149, 399, 899, 1499],
      color: '#1F80E0',
    ),
    OTTPlatform(
      id: 'zee5',
      name: 'ZEE5',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/zee5.png',
      popularPlans: [99, 299, 699, 999],
      color: '#6C42FF',
    ),
    OTTPlatform(
      id: 'sonyliv',
      name: 'SonyLIV',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/sonyliv.png',
      popularPlans: [99, 299, 699, 999],
      color: '#4285F4',
    ),
    OTTPlatform(
      id: 'voot',
      name: 'Voot',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/voot.png',
      popularPlans: [99, 299, 499],
      color: '#FF6600',
    ),
    OTTPlatform(
      id: 'alt_balaji',
      name: 'ALTBalaji',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/alt_balaji.png',
      popularPlans: [100, 300],
      color: '#FF6B35',
    ),
    OTTPlatform(
      id: 'mx_player',
      name: 'MX Player',
      category: 'Video Streaming',
      logoUrl: 'assets/logos/mx_player.png',
      popularPlans: [99, 299],
      color: '#FFA500',
    ),
    
    // Music Streaming
    OTTPlatform(
      id: 'spotify',
      name: 'Spotify',
      category: 'Music Streaming',
      logoUrl: 'assets/logos/spotify.png',
      popularPlans: [119, 179, 359],
      color: '#1DB954',
    ),
    OTTPlatform(
      id: 'youtube_music',
      name: 'YouTube Music',
      category: 'Music Streaming',
      logoUrl: 'assets/logos/youtube_music.png',
      popularPlans: [99, 149],
      color: '#FF0000',
    ),
    OTTPlatform(
      id: 'apple_music',
      name: 'Apple Music',
      category: 'Music Streaming',
      logoUrl: 'assets/logos/apple_music.png',
      popularPlans: [99, 149, 199],
      color: '#FF2D92',
    ),
    OTTPlatform(
      id: 'jiosaavn',
      name: 'JioSaavn',
      category: 'Music Streaming',
      logoUrl: 'assets/logos/jiosaavn.png',
      popularPlans: [99, 299, 399],
      color: '#01C96C',
    ),
    OTTPlatform(
      id: 'gaana',
      name: 'Gaana',
      category: 'Music Streaming',
      logoUrl: 'assets/logos/gaana.png',
      popularPlans: [99, 399],
      color: '#FF6B00',
    ),
    
    // Gaming
    OTTPlatform(
      id: 'xbox_game_pass',
      name: 'Xbox Game Pass',
      category: 'Gaming',
      logoUrl: 'assets/logos/xbox_game_pass.png',
      popularPlans: [489, 849],
      color: '#107C10',
    ),
    OTTPlatform(
      id: 'playstation_plus',
      name: 'PlayStation Plus',
      category: 'Gaming',
      logoUrl: 'assets/logos/playstation_plus.png',
      popularPlans: [499, 849, 1299],
      color: '#003087',
    ),
    
    // Cloud Storage
    OTTPlatform(
      id: 'google_one',
      name: 'Google One',
      category: 'Cloud Storage',
      logoUrl: 'assets/logos/google_one.png',
      popularPlans: [130, 210, 650, 1300],
      color: '#4285F4',
    ),
    OTTPlatform(
      id: 'icloud',
      name: 'iCloud+',
      category: 'Cloud Storage',
      logoUrl: 'assets/logos/icloud.png',
      popularPlans: [75, 219, 749],
      color: '#007AFF',
    ),
    
    // Productivity
    OTTPlatform(
      id: 'microsoft_365',
      name: 'Microsoft 365',
      category: 'Productivity',
      logoUrl: 'assets/logos/microsoft_365.png',
      popularPlans: [489, 719],
      color: '#FF8C00',
    ),
    OTTPlatform(
      id: 'adobe_creative_cloud',
      name: 'Adobe Creative Cloud',
      category: 'Productivity',
      logoUrl: 'assets/logos/adobe_cc.png',
      popularPlans: [1675, 4448],
      color: '#FF0000',
    ),
  ];

  static List<String> get categories => platforms
      .map((platform) => platform.category)
      .toSet()
      .toList();

  static List<OTTPlatform> getPlatformsByCategory(String category) =>
      platforms.where((platform) => platform.category == category).toList();

  static OTTPlatform? getPlatformById(String id) =>
      platforms.cast<OTTPlatform?>().firstWhere(
        (platform) => platform?.id == id,
        orElse: () => null,
      );

  static List<OTTPlatform> searchPlatforms(String query) =>
      platforms
          .where((platform) =>
              platform.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
}