/// A class that holds the abstract translations for various UI prompts and messages.
class AbstractTranslations {
  /// The text to prompt the user to reload the data.
  final String? reload;

  /// The message displayed when an error occurs and the user is asked to try again.
  final String? thereWasAnErrorPleaseTryAgain;

  /// The message indicating that cached data is being shown.
  final String? showingCachedData;

  /// The text for the confirmation action, typically means "okay".
  final String? okay;

  /// The text for the cancellation action.
  final String? cancel;

  /// The message displayed when there is no data available to show.
  final String? thereIsNoData;

  /// The message displayed when an error occurred and prompts the user to try again.
  final String? anErrorOccuredPleaseTryAgain;

  /// Constructs an instance of AbstractTranslations with optional translation values.
  const AbstractTranslations({
    this.reload,
    this.thereWasAnErrorPleaseTryAgain,
    this.showingCachedData,
    this.okay,
    this.cancel,
    this.thereIsNoData,
    this.anErrorOccuredPleaseTryAgain,
  });
}
