import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortest_path/core/network/network_exception.dart';
import 'package:shortest_path/domain/repositories/tasks_repository.dart';
import 'package:shortest_path/domain/repositories/url_repository.dart';
import 'package:shortest_path/presentation/errors/network_error_message.dart';
import 'package:shortest_path/presentation/home/home_state.dart';
import 'package:shortest_path/presentation/home/url_validator.dart';

/// Logic of the Home screen: validates the URL, saves it and loads the tasks
/// from it.
///
/// The request is not cancellable: Home is the root screen and is only
/// disposed together with the app. A hanging request still ends with the
/// ApiClient's timeout.
class HomeCubit extends Cubit<HomeState> {
  /// Callers pass `tasksRepository:`, `urlRepository:` and `urlValidator:` —
  /// for a private named parameter Dart drops the underscore from the
  /// argument name.
  HomeCubit({
    required this._tasksRepository,
    required this._urlRepository,
    this._urlValidator = const UrlValidator(),
  }) : super(const HomeIdle());

  final TasksRepository _tasksRepository;
  final UrlRepository _urlRepository;
  final UrlValidator _urlValidator;

  /// Clears the validation error as soon as the user edits the URL.
  void onUrlChanged() {
    if (state is HomeInvalid) {
      emit(const HomeIdle());
    }
  }

  /// Validates [input] and, if it is a valid URL, saves it and loads the
  /// tasks from it.
  Future<void> submit(String input) async {
    // The UI disables input while loading; this also covers a fast double tap.
    if (state is HomeLoading) {
      return;
    }

    switch (_urlValidator.validate(input)) {
      case InvalidUrl(:final message):
        emit(HomeInvalid(message));
      case ValidUrl(:final url):
        await _saveUrlAndLoadTasks(url);
    }
  }

  Future<void> _saveUrlAndLoadTasks(Uri url) async {
    // Emitted before saving, so the guard in [submit] already blocks a
    // second tap while the URL is being written.
    emit(const HomeLoading());
    // Start is what stores the URL (task 1.1), so it is saved before the
    // request and regardless of its result. Never throws: see UrlRepository.
    await _urlRepository.saveUrl(url);
    try {
      final tasks = await _tasksRepository.fetchTasks(url);
      emit(
        tasks.isEmpty
            ? const HomeLoadError('No tasks received')
            : HomeLoaded(url: url, tasks: tasks),
      );
    } on NetworkException catch (exception) {
      // `null` only for a cancelled request, which cannot happen here.
      final message = networkErrorMessage(exception);
      if (message != null) {
        emit(HomeLoadError(message));
      }
    }
  }
}
