enum FailureType {
  invalidCredentials,
  connection,
  server,
  rejected,
  unexpected,
}

class AppFailure implements Exception {
  final FailureType type;

  const AppFailure(this.type);
}
