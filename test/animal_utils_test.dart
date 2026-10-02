import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/utils/animal_utils.dart';

void main() {
  group('AnimalUtils Terminology & Age System', () {
    test('Species-specific young animal terminology lookup', () {
      expect(AnimalUtils.getYoungTerm('Dog'), 'Puppy');
      expect(AnimalUtils.getYoungTerm('Cat'), 'Kitten');
      expect(AnimalUtils.getYoungTerm('Lion'), 'Cub');
      expect(AnimalUtils.getYoungTerm('Tiger'), 'Cub');
      expect(AnimalUtils.getYoungTerm('Bear'), 'Cub');
      expect(AnimalUtils.getYoungTerm('Elephant'), 'Calf');
      expect(AnimalUtils.getYoungTerm('Cow'), 'Calf');
      expect(AnimalUtils.getYoungTerm('Deer'), 'Fawn');
      expect(AnimalUtils.getYoungTerm('Horse'), 'Foal');
      expect(AnimalUtils.getYoungTerm('Goat'), 'Kid');
      expect(AnimalUtils.getYoungTerm('Sheep'), 'Lamb');
      expect(AnimalUtils.getYoungTerm('Pig'), 'Piglet');
      expect(AnimalUtils.getYoungTerm('Rabbit'), 'Kit');
      expect(AnimalUtils.getYoungTerm('Chicken'), 'Chick');
      expect(AnimalUtils.getYoungTerm('Duck'), 'Duckling');
      expect(AnimalUtils.getYoungTerm('Bird'), 'Chick');
      expect(AnimalUtils.getYoungTerm('Fish'), 'Fry');
      expect(AnimalUtils.getYoungTerm('Reptile'), 'Hatchling');
    });

    test('AnimalType young term resolution', () {
      expect(AnimalUtils.getYoungTermForType(AnimalType.dog), 'Puppy');
      expect(AnimalUtils.getYoungTermForType(AnimalType.cat), 'Kitten');
      expect(AnimalUtils.getYoungTermForType(AnimalType.rabbit), 'Kit');
      expect(AnimalUtils.getYoungTermForType(AnimalType.horse), 'Foal');
      expect(AnimalUtils.getYoungTermForType(AnimalType.duck), 'Duckling');
      expect(AnimalUtils.getYoungTermForType(AnimalType.chicken), 'Chick');
    });

    test('Age formatting with pluralization', () {
      expect(AnimalUtils.formatAge(1, AgeUnit.days), '1 day');
      expect(AnimalUtils.formatAge(14, AgeUnit.days), '14 days');
      expect(AnimalUtils.formatAge(1, AgeUnit.weeks), '1 week');
      expect(AnimalUtils.formatAge(8, AgeUnit.weeks), '8 weeks');
      expect(AnimalUtils.formatAge(1, AgeUnit.months), '1 month');
      expect(AnimalUtils.formatAge(6, AgeUnit.months), '6 months');
      expect(AnimalUtils.formatAge(1, AgeUnit.years), '1 year');
      expect(AnimalUtils.formatAge(2, AgeUnit.years), '2 years');
    });

    test('LifeStage determination based on age system', () {
      // Newborn (< 28 days)
      expect(AnimalUtils.determineLifeStage(2, AgeUnit.weeks), LifeStage.newborn);
      expect(AnimalUtils.determineLifeStage(20, AgeUnit.days), LifeStage.newborn);

      // Baby (29 - 90 days / ~1-3 months)
      expect(AnimalUtils.determineLifeStage(6, AgeUnit.weeks), LifeStage.baby);
      expect(AnimalUtils.determineLifeStage(2, AgeUnit.months), LifeStage.baby);

      // Young (91 - 365 days / ~3-12 months)
      expect(AnimalUtils.determineLifeStage(6, AgeUnit.months), LifeStage.young);
      expect(AnimalUtils.determineLifeStage(10, AgeUnit.months), LifeStage.young);

      // Adolescent (1 - 2 years)
      expect(AnimalUtils.determineLifeStage(18, AgeUnit.months), LifeStage.adolescent);
      expect(AnimalUtils.determineLifeStage(1, AgeUnit.years), LifeStage.adolescent);

      // Adult (2 - 7 years)
      expect(AnimalUtils.determineLifeStage(3, AgeUnit.years), LifeStage.adult);

      // Senior (7+ years)
      expect(AnimalUtils.determineLifeStage(8, AgeUnit.years), LifeStage.senior);
    });

    test('Pet stage description generation', () {
      final kittenDesc = AnimalUtils.getPetStageDescription(
        speciesOrType: 'Cat',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
      );
      expect(kittenDesc, 'Kitten (8 weeks old)');

      final adultDesc = AnimalUtils.getPetStageDescription(
        speciesOrType: 'Dog',
        ageValue: 3,
        ageUnit: AgeUnit.years,
        lifeStage: LifeStage.adult,
      );
      expect(adultDesc, 'Adult (3 years old)');
    });
  });
}
