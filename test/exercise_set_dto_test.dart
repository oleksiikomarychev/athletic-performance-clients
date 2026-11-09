import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/models/workout.dart';

void main() {
  test('reads reps from workout detail response', () {
    final set = ExerciseSetDto.fromJson({
      'reps': 5,
      'working_weight': 170,
      'effort': 9,
    });

    expect(set.reps, 5);
    expect(set.weight, 170);
    expect(set.toJson()['volume'], 5);
  });

  test('still reads volume from stored workout sets', () {
    expect(ExerciseSetDto.fromJson({'volume': 5}).reps, 5);
  });

  test('workout detail keeps reps in nested exercise sets', () {
    final workout = Workout.fromJson({
      'name': 'Day 1',
      'exercise_instances': [
        {
          'exercise_list_id': 35,
          'sets': [
            {'reps': 5, 'working_weight': 170, 'effort': 9},
          ],
        },
      ],
    });

    expect(workout.exerciseInstances.single.sets.single.reps, 5);
  });
}
