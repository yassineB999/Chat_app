import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/core/utils/logger.dart';

/// Base BLoC with common functionality
/// All BLoCs should extend this for consistent logging and error handling
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState) {
    // Log bloc creation
    AppLogger.debug('${runtimeType.toString()} created');
  }

  /// Override to provide bloc name for logging
  String get blocName => runtimeType.toString();

  /// Log events for debugging
  @override
  void onEvent(Event event) {
    super.onEvent(event);
    AppLogger.debug('Event: ${event.runtimeType}', tag: blocName);
  }

  /// Log state transitions for debugging
  @override
  void onTransition(Transition<Event, State> transition) {
    super.onTransition(transition);
    AppLogger.debug(
      'Transition: ${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}',
      tag: blocName,
    );
  }

  /// Log errors
  @override
  void onError(Object error, StackTrace stackTrace) {
    AppLogger.error(
      'Error occurred',
      tag: blocName,
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(error, stackTrace);
  }

  @override
  Future<void> close() {
    AppLogger.debug('${blocName} closed');
    return super.close();
  }
}
