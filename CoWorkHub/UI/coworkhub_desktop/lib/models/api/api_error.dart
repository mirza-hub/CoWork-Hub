class UserError {
  final Map<String, List<String>> errors;

  UserError({required this.errors});

  factory UserError.fromJson(Map<String, dynamic> json) {
    return UserError(
      errors: (json['errors'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );
  }

  String get message {
    return errors.values.expand((e) => e).join("\n");
  }
}
