import 'package:freezed_annotation/freezed_annotation.dart';

part 'results_state.freezed.dart';

@freezed
class ResultState<T> with _$ResultState<T> {
  const factory ResultState.idle() = Idle<T>;

  const factory ResultState.loading() = Loading<T>;

  const factory ResultState.success(T data) = Success<T>;

  const factory ResultState.error(String message) = Error<T>;
}

///بدل إنشاء States كثيرة مثل:
///Initial
///Loading
///Success
///Error
///تم استخدام Generic State واحدة:
///ResultState<T>
