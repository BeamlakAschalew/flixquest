import 'package:shared_preferences/shared_preferences.dart';

/// Remembers how someone answered Home's invite to the Telegram channel.
///
/// The invite shows at most once a launch. "Don't show again" quiets it for
/// [snoozeFor]; joining quiets it for good, until the channel link changes.
class TelegramChannelPromptStore {
  TelegramChannelPromptStore(this._preferences, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  static const snoozeFor = Duration(days: 14);
  static const snoozedUntilKey = 'telegram_prompt_snoozed_until';
  static const joinedUrlKey = 'telegram_prompt_joined_url';

  final SharedPreferences _preferences;
  final DateTime Function() _now;

  /// Whether this launch has asked already; static so a rebuilt Home doesn't
  /// ask twice.
  static bool _askedThisLaunch = false;

  /// For tests, which run many launches in one process.
  static void resetLaunch() => _askedThisLaunch = false;

  bool shouldAsk(Uri channel) {
    if (_askedThisLaunch) return false;
    if (_preferences.getString(joinedUrlKey) == channel.toString()) {
      return false;
    }
    final until = _preferences.getInt(snoozedUntilKey);
    return until == null || !_now().isBefore(_dateOf(until));
  }

  void markAsked() => _askedThisLaunch = true;

  Future<void> snooze() => _preferences.setInt(
      snoozedUntilKey, _now().add(snoozeFor).millisecondsSinceEpoch);

  Future<void> markJoined(Uri channel) =>
      _preferences.setString(joinedUrlKey, channel.toString());

  static DateTime _dateOf(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis);
}
