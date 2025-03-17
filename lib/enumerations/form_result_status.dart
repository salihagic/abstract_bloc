/// An enumeration representing the various statuses of a form's result.
enum FormResultStatus {
  /// The form is in the process of initializing.
  initializing,

  /// The form has been initialized and is ready for user interaction.
  initialized,

  /// An error has occurred, preventing successful submission or processing.
  error,

  /// The form is currently in the process of being submitted.
  submitting,

  /// The form was submitted successfully.
  submittingSuccess,

  /// The form was submitted successfully but only for local processing.
  submittingLocalSuccess,

  /// An error occurred during the submission process.
  submittingError,

  /// An error occurred during local submission processing.
  submittingLocalError,

  /// There was a validation error in the submitted data.
  validationError,
}
