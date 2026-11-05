import 'package:shortest_path/core/network/api_client.dart';
import 'package:shortest_path/data/models/task_dto.dart';
import 'package:shortest_path/domain/entities/task.dart';
import 'package:shortest_path/domain/repositories/tasks_repository.dart';

/// [TasksRepository] backed by the Webspark API.
class TasksRepositoryImpl implements TasksRepository {
  const TasksRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Task>> fetchTasks(Uri url) {
    return _apiClient.get(url, decode: _decodeTasks);
  }

  /// A [FormatException] thrown here is reported by [ApiClient] as
  /// `InvalidResponseException`.
  static List<Task> _decodeTasks(Object? json) => switch (json) {
    final List<Object?> items => List.unmodifiable([
      for (final item in items) TaskDto.fromJson(item).toEntity(),
    ]),
    _ => throw FormatException('Tasks data is not a list: $json'),
  };
}
