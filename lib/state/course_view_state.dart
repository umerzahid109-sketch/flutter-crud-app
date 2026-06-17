// lib/state/course_view_state.dart

/// The mutually-exclusive UI states the course list can be in.
///
/// Keeping these explicit (instead of juggling booleans) lets the UI render
/// exactly one of: first-load spinner, populated list, empty placeholder, or
/// an error view.
enum CourseViewState {
  /// Nothing has been requested yet.
  initial,

  /// A first-time / full-screen load is in progress (no data to show yet).
  loading,

  /// Data is available and non-empty.
  loaded,

  /// The request succeeded but there are no courses to show.
  empty,

  /// The request failed and there is no cached data to fall back on.
  error,
}
