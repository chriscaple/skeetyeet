/// An `at://` URI: `at://<authority>/<collection>/<rkey>`.
///
/// The authority is a DID (`did:plc:…`) or a handle. Record URIs stored in a
/// repo always use the DID form.
final class AtUri {
  const AtUri({required this.authority, this.collection, this.rkey});

  /// Parses [input], throwing a [FormatException] if it is not an AT URI.
  factory AtUri.parse(String input) {
    const scheme = 'at://';
    if (!input.startsWith(scheme)) {
      throw FormatException('Not an AT URI', input);
    }
    final path = input
        .substring(scheme.length)
        .split('#')
        .first
        .split('?')
        .first;
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty || parts.length > 3) {
      throw FormatException('Malformed AT URI', input);
    }
    return AtUri(
      authority: parts[0],
      collection: parts.length > 1 ? parts[1] : null,
      rkey: parts.length > 2 ? parts[2] : null,
    );
  }

  /// Like [AtUri.parse], but returns `null` instead of throwing.
  static AtUri? tryParse(Object? input) {
    if (input is! String) return null;
    try {
      return AtUri.parse(input);
    } on FormatException {
      return null;
    }
  }

  final String authority;
  final String? collection;
  final String? rkey;

  /// Whether the authority is a DID rather than a handle.
  bool get hasDid => authority.startsWith('did:');

  @override
  String toString() => [
    'at://$authority',
    if (collection != null) collection,
    if (rkey != null) rkey,
  ].join('/');

  @override
  bool operator ==(Object other) =>
      other is AtUri &&
      other.authority == authority &&
      other.collection == collection &&
      other.rkey == rkey;

  @override
  int get hashCode => Object.hash(authority, collection, rkey);
}
