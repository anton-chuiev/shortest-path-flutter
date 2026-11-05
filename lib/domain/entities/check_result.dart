import 'package:equatable/equatable.dart';

/// The server's verdict on one submitted result.
final class CheckResult extends Equatable {
  const CheckResult({required this.id, required this.correct});

  /// Id of the task the result was sent for.
  final String id;

  final bool correct;

  @override
  List<Object?> get props => [id, correct];
}
