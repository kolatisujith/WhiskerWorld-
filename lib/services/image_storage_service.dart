import '../models/enums.dart';

/// Preset image item with metadata for quick selection
class PetImagePreset {
  final String id;
  final String title;
  final AnimalType animalType;
  final String url;

  const PetImagePreset({
    required this.id,
    required this.title,
    required this.animalType,
    required this.url,
  });
}

/// Web-compatible image selection and storage abstraction service.
/// Avoids mobile-only `dart:io` file primitives and operates safely across Flutter Web and Desktop.
class ImageStorageService {
  /// Singleton instance
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;
  ImageStorageService._internal();

  /// Curated library of royalty-free, high-quality young pet photography presets
  static const List<PetImagePreset> presets = [
    // Puppies
    PetImagePreset(
      id: 'preset_pup_golden',
      title: 'Golden Retriever Puppy',
      animalType: AnimalType.dog,
      url: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_pup_frenchie',
      title: 'French Bulldog Pup',
      animalType: AnimalType.dog,
      url: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_pup_corgi',
      title: 'Corgi Puppy',
      animalType: AnimalType.dog,
      url: 'https://images.unsplash.com/photo-1546975490-e8b92a360b24?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_pup_beagle',
      title: 'Beagle Pup',
      animalType: AnimalType.dog,
      url: 'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?auto=format&fit=crop&w=800&q=80',
    ),

    // Kittens
    PetImagePreset(
      id: 'preset_kit_ragdoll',
      title: 'Ragdoll Baby Kitten',
      animalType: AnimalType.cat,
      url: 'https://images.unsplash.com/photo-1574158622682-e40e69881006?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_kit_british_blue',
      title: 'British Shorthair Kitten',
      animalType: AnimalType.cat,
      url: 'https://images.unsplash.com/photo-1548802673-380ab8ebc7b7?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_kit_tabby',
      title: 'Striped Tabby Kitten',
      animalType: AnimalType.cat,
      url: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_kit_calico',
      title: 'Calico Playful Kitten',
      animalType: AnimalType.cat,
      url: 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?auto=format&fit=crop&w=800&q=80',
    ),

    // Baby Rabbits
    PetImagePreset(
      id: 'preset_rab_holland',
      title: 'Holland Lop Baby Bunny',
      animalType: AnimalType.rabbit,
      url: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_rab_white',
      title: 'White Fluffy Kit',
      animalType: AnimalType.rabbit,
      url: 'https://images.unsplash.com/photo-1535241749838-299277b6305f?auto=format&fit=crop&w=800&q=80',
    ),

    // Baby Birds
    PetImagePreset(
      id: 'preset_bird_cockatiel',
      title: 'Cockatiel Chick',
      animalType: AnimalType.bird,
      url: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_bird_parakeet',
      title: 'Budgie Fledgling',
      animalType: AnimalType.bird,
      url: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=800&q=80',
    ),

    // Small Animals
    PetImagePreset(
      id: 'preset_small_hamster',
      title: 'Syrian Hamster Pup',
      animalType: AnimalType.other,
      url: 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?auto=format&fit=crop&w=800&q=80',
    ),
    PetImagePreset(
      id: 'preset_small_guineapig',
      title: 'Guinea Pig Pup',
      animalType: AnimalType.other,
      url: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=800&q=80',
    ),

    // Reptiles
    PetImagePreset(
      id: 'preset_rep_gecko',
      title: 'Crested Gecko Hatchling',
      animalType: AnimalType.reptile,
      url: 'https://images.unsplash.com/photo-1508817628294-5a453fa0b8fb?auto=format&fit=crop&w=800&q=80',
    ),

    // Fish
    PetImagePreset(
      id: 'preset_fish_guppy',
      title: 'Fancy Guppy Fry',
      animalType: AnimalType.fish,
      url: 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  /// Curated store cover presets
  static const List<String> storeCoverPresets = [
    'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=1200&q=80',
  ];

  /// Curated store logo presets
  static const List<String> storeLogoPresets = [
    'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1535930891776-0c2dfb7fda1a?auto=format&fit=crop&w=300&q=80',
    'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=300&q=80',
  ];

  /// Filters presets by animal type or returns general young pets
  List<PetImagePreset> getPresetsForType(AnimalType? type) {
    if (type == null) return presets;
    final matching = presets.where((p) => p.animalType == type).toList();
    return matching.isNotEmpty ? matching : presets;
  }

  /// Validates an image URL or data URI format
  bool isValidImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return true;
    if (trimmed.startsWith('data:image/')) return true;
    return false;
  }

  /// Formats raw bytes to data URL if uploading custom client-side bytes
  String bytesToDataUrl(List<int> bytes, {String mimeType = 'image/jpeg'}) {
    // Basic data URI representation for web compatibility
    final b64 = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'data:$mimeType;hex,$b64';
  }

  /// Default fallback image when a pet has no images
  String getFallbackImage(AnimalType type) {
    final matching = getPresetsForType(type);
    if (matching.isNotEmpty) return matching.first.url;
    return presets.first.url;
  }
}
