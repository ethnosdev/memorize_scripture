class TextFieldData {
  const TextFieldData({
    this.errorText,
    this.isObscured = false,
  });

  final String? errorText;
  final bool isObscured;
  bool get hasError => errorText != null;
}
