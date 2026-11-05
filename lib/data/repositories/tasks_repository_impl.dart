import 'package:shortest_path/core/network/api_client.dart';
import 'package:shortest_path/core/network/cancellation_token.dart';
import 'package:shortest_path/data/models/check_result_dto.dart';
import 'package:shortest_path/data/models/task_dto.dart';
import 'package:shortest_path/data/models/task_result_dto.dart';
import 'package:shortest_path/domain/entities/check_result.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/domain/entities/task_result.dart';
import 'package:shortest_path/domain/repositories/tasks_repository.dart';

/// [TasksRepository] backed by the Webspark API.
class TasksRepositoryImpl implements TasksRepository {
  const TasksRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Task>> fetchTasks(Uri url) {
    return _apiClient.get(url, decode: _decodeTasks);
  }

  @override
  Future<List<CheckResult>> submitResults(
    Uri url,
    List<TaskResult> results, {
    CancellationToken? cancellationToken,
  }) {
    return _apiClient.post(
      url,
      // The body is a JSON array with one item per task.
      body: [
        for (final result in results) TaskResultDto.fromEntity(result).toJson(),
      ],
      decode: _decodeCheckResults,
      cancellationToken: cancellationToken,
    );
  }

  /// A [FormatException] thrown here is reported by [ApiClient] as
  /// `InvalidResponseException`.
  static List<Task> _decodeTasks(Object? json) => switch (json) {
    final List<Object?> items => List.unmodifiable([
      for (final item in items) TaskDto.fromJson(item).toEntity(),
    ]),
    _ => throw FormatException('Tasks data is not a list: $json'),
  };

  /// Same contract as [_decodeTasks].
  static List<CheckResult> _decodeCheckResults(Object? json) => switch (json) {
    final List<Object?> items => List.unmodifiable([
      for (final item in items) CheckResultDto.fromJson(item).toEntity(),
    ]),
    _ => throw FormatException('Check results data is not a list: $json'),
  };
}
