import '../models/enums.dart';

/// Whisker World Animal Utilities & Terminology Engine
class AnimalUtils {
  AnimalUtils._();

  /// Canonical young animal terminology dictionary.
  static const Map<String, String> _youngTerminology = {
    'dog': 'Puppy',
    'cat': 'Kitten',
    'lion': 'Cub',
    'tiger': 'Cub',
    'bear': 'Cub',
    'elephant': 'Calf',
    'cow': 'Calf',
    'deer': 'Fawn',
    'horse': 'Foal',
    'goat': 'Kid',
    'sheep': 'Lamb',
    'pig': 'Piglet',
    'rabbit': 'Kit',
    'chicken': 'Chick',
    'duck': 'Duckling',
    'bird': 'Chick',
    'fish': 'Fry',
    'reptile': 'Hatchling',
    'hamster': 'Pup',
    'guinea pig': 'Pup',
    'ferret': 'Kit',
  };

  /// Popular young pet categories for discovery
  static const List<Map<String, dynamic>> youngPetCategories = [
    {
      'title': 'Puppies',
      'animalType': AnimalType.dog,
      'youngTerm': 'Puppy',
      'icon': '🐶',
      'description': 'Playful golden pups, frenchies, and cuddle bugs',
    },
    {
      'title': 'Kittens',
      'animalType': AnimalType.cat,
      'youngTerm': 'Kitten',
      'icon': '🐱',
      'description': 'Purring ragdolls, british blues, and tiny paws',
    },
    {
      'title': 'Baby Birds',
      'animalType': AnimalType.bird,
      'youngTerm': 'Chick',
      'icon': '🦜',
      'description': 'Hand-fed cockatiels, lovebirds, and parakeets',
    },
    {
      'title': 'Baby Rabbits',
      'animalType': AnimalType.rabbit,
      'youngTerm': 'Kit',
      'icon': '🐰',
      'description': 'Velvet-eared holland lops and mini rexes',
    },
    {
      'title': 'Small Animals',
      'animalType': AnimalType.other,
      'youngTerm': 'Pup / Kit',
      'icon': '🐹',
      'description': 'Gentle hamsters, guinea pigs, and sugar gliders',
    },
    {
      'title': 'Young Reptiles',
      'animalType': AnimalType.reptile,
      'youngTerm': 'Hatchling',
      'icon': '🦎',
      'description': 'Curious geckos, bearded dragons, and tortoises',
    },
    {
      'title': 'Young Fish',
      'animalType': AnimalType.fish,
      'youngTerm': 'Fry',
      'icon': '🐠',
      'description': 'Bright guppy fry, bettas, and aquatic friends',
    },
  ];

  /// Returns the species-specific young animal term (e.g., Cat -> Kitten, Rabbit -> Kit).
  /// Falls back to "Young" or the species name if not in the dictionary.
  static String getYoungTerm(String speciesOrType) {
    final key = speciesOrType.trim().toLowerCase();
    if (_youngTerminology.containsKey(key)) {
      return _youngTerminology[key]!;
    }

    // Check by animal type enum name
    for (final entry in _youngTerminology.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Young $speciesOrType';
  }

  /// Returns the young term for a given [AnimalType].
  static String getYoungTermForType(AnimalType type) {
    return getYoungTerm(type.name);
  }

  /// Formats age value and unit into a clean, human-readable string (e.g., "3 weeks", "1 year").
  static String formatAge(int ageValue, AgeUnit ageUnit) {
    final unitString = switch (ageUnit) {
      AgeUnit.days => ageValue == 1 ? 'day' : 'days',
      AgeUnit.weeks => ageValue == 1 ? 'week' : 'weeks',
      AgeUnit.months => ageValue == 1 ? 'month' : 'months',
      AgeUnit.years => ageValue == 1 ? 'year' : 'years',
    };
    return '$ageValue $unitString';
  }

  /// Calculates total equivalent age in days for standardized comparisons.
  static int toDays(int ageValue, AgeUnit ageUnit) {
    return switch (ageUnit) {
      AgeUnit.days => ageValue,
      AgeUnit.weeks => ageValue * 7,
      AgeUnit.months => ageValue * 30,
      AgeUnit.years => ageValue * 365,
    };
  }

  /// Determines the appropriate [LifeStage] based on the age value and unit.
  /// Whisker World prioritizes newborn, baby, and young pets while supporting all life stages.
  static LifeStage determineLifeStage(int ageValue, AgeUnit ageUnit, {AnimalType? type}) {
    final days = toDays(ageValue, ageUnit);

    // Newborn: 0 - 28 days (under ~1 month)
    if (days <= 28) {
      return LifeStage.newborn;
    }
    // Baby: 29 days - 90 days (~1 to 3 months)
    if (days <= 90) {
      return LifeStage.baby;
    }
    // Young: 91 days - under 1 year (~3 to <12 months)
    if (days < 365) {
      return LifeStage.young;
    }
    // Adolescent: 1 - 2 years
    if (days <= 730) {
      return LifeStage.adolescent;
    }
    // Adult: 2 - 7 years
    if (days <= 2555) {
      return LifeStage.adult;
    }
    // Senior: 7+ years
    return LifeStage.senior;
  }

  /// Returns a friendly human label for a life stage.
  static String getLifeStageLabel(LifeStage stage) {
    return switch (stage) {
      LifeStage.newborn => 'Newborn',
      LifeStage.baby => 'Baby',
      LifeStage.young => 'Young',
      LifeStage.adolescent => 'Adolescent',
      LifeStage.adult => 'Adult',
      LifeStage.senior => 'Senior',
    };
  }

  /// Returns a descriptive tagline for the pet combining its young term and age.
  /// E.g. "Kitten (8 weeks old)" or "Senior Dog (8 years old)".
  static String getPetStageDescription({
    required String speciesOrType,
    required int ageValue,
    required AgeUnit ageUnit,
    required LifeStage lifeStage,
  }) {
    final ageStr = formatAge(ageValue, ageUnit);
    if (lifeStage == LifeStage.newborn ||
        lifeStage == LifeStage.baby ||
        lifeStage == LifeStage.young) {
      final youngTerm = getYoungTerm(speciesOrType);
      return '$youngTerm ($ageStr old)';
    }
    final stageLabel = getLifeStageLabel(lifeStage);
    return '$stageLabel ($ageStr old)';
  }
}
