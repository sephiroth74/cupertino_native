import Foundation

/// Shared text-length enforcement for text input widgets.
///
/// Counts by `Character` (extended grapheme clusters) to match the behaviour of
/// Flutter's `LengthLimitingTextInputFormatter`, so the native hard cap and the
/// Dart-side formatters agree on what "length" means.
enum CNTextTruncation {
    /// Returns `text` truncated to at most `maxLength` grapheme clusters.
    /// A `nil` or negative `maxLength` returns the text unchanged.
    static func truncate(_ text: String, maxLength: Int?) -> String {
        guard let maxLength, maxLength >= 0, text.count > maxLength else { return text }
        return String(text.prefix(maxLength))
    }
}
