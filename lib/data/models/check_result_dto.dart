import 'package:shortest_path/domain/entities/check_result.dart';

/// JSON form of the server's verdict in the POST response:
/// `{"id": "...", "correct": true}`.
final class CheckResultDto {
  const CheckResultDto({required this.id, required this.correct});

  /// Throws [FormatException] when [json] is not a check result.
  factory CheckResultDto.fromJson(Object? json) => switch (json) {
    {'id': final String id, 'correct': final bool correct} => CheckResultDto(
      id: id,
      correct: correct,
    ),
    _ => throw FormatException('Not a check result: $json'),
  };

  final String id;
  final bool correct;

  CheckResult toEntity() => CheckResult(id: id, correct: correct);
}
