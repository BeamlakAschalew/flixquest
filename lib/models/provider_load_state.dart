enum ProviderStatus {
  pending,
  loading,
  success,
  failed,
}

class ProviderLoadState {
  final String codeName;
  final String fullName;
  final String? content;
  ProviderStatus status;
  String? errorMessage;

  ProviderLoadState({
    required this.codeName,
    required this.fullName,
    this.content,
    this.status = ProviderStatus.pending,
    this.errorMessage,
  });

  ProviderLoadState copyWith({
    ProviderStatus? status,
    String? errorMessage,
  }) {
    return ProviderLoadState(
      codeName: codeName,
      fullName: fullName,
      content: content,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
