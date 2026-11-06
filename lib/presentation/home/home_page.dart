import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortest_path/presentation/home/home_cubit.dart';
import 'package:shortest_path/presentation/home/home_routes.dart';
import 'package:shortest_path/presentation/home/home_state.dart';
import 'package:shortest_path/presentation/theme/app_dimens.dart';
import 'package:shortest_path/presentation/widgets/bottom_action_button.dart';
import 'package:shortest_path/presentation/widgets/error_dialog.dart';

/// Screen 1.1: the user enters the API URL and loads the tasks from it.
///
/// Expects a [HomeCubit] above it in the tree.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.routes, this.initialUrl});

  final HomeRoutes routes;

  /// The URL saved on a previous launch, shown in the field at start.
  final Uri? initialUrl;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lives as long as the page, so the last URL is still there when the user
  // comes back from the Process screen.
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl?.toString());
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    unawaited(context.read<HomeCubit>().submit(_urlController.text));
  }

  /// One-off reactions to state changes; the UI itself is built in `builder`.
  void _onStateChanged(BuildContext context, HomeState state) {
    switch (state) {
      case HomeLoading():
        FocusScope.of(context).unfocus();
      case HomeLoadError(:final message):
        unawaited(showErrorDialog(context, message: message));
      case HomeLoaded(:final url, :final tasks):
        widget.routes.toProcess(url: url, tasks: tasks);
      case HomeIdle() || HomeInvalid():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home screen')),
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final isLoading = state is HomeLoading;
          return Column(
            children: [
              // Scrollable so the content still fits on small screens when the
              // keyboard takes half of the height.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Set valid API base URL in order to continue'),
                      const SizedBox(height: AppSpacing.medium),
                      TextField(
                        controller: _urlController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        enableSuggestions: false,
                        onChanged: (_) =>
                            context.read<HomeCubit>().onUrlChanged(),
                        onSubmitted: (_) => _submit(),
                        // iOS users expect a tap outside to hide the keyboard.
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          icon: const Icon(Icons.compare_arrows),
                          errorText: switch (state) {
                            HomeInvalid(:final message) => message,
                            _ => null,
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BottomActionButton(
                label: 'Start counting process',
                onPressed: _submit,
                isLoading: isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
