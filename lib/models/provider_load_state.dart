enum ProviderStatus {
  pending,
  loading,
  success,
  failed,
}

class ProviderLoadState {
  final String codeName;
  final String fullName;
  ProviderStatus status;
  String? errorMessage;

  ProviderLoadState({
    required this.codeName,
    required this.fullName,
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
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
