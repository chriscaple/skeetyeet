import 'at_uri.dart';
import 'nsid.dart';

/// What a record is, for filtering. A post can be several at once: a reply
/// that quotes another post is both [reply] and [quote].
enum RecordKind {
  /// A post that is not a reply.
  original,
  reply,
  quote,
  repost,
  like,
  follow,
  other,
}

/// Media attached to a post.
enum MediaKind { images, video, gif, externalLink }

/// Engagement counts for a post, fetched from the app view at scan time.
final class Engagement {
  const Engagement({
    this.likes = 0,
    this.reposts = 0,
    this.replies = 0,
    this.quotes = 0,
  });

  final int likes;
  final int reposts;
  final int replies;
  final int quotes;
}

/// One record from the user's repo, as returned by
/// `com.atproto.repo.listRecords` or decoded from a CAR export.
///
/// Everything filters need is derived from [value] on first use, so building
/// a large index of records stays cheap.
final class RepoRecord {
  RepoRecord({
    required this.uri,
    required this.cid,
    required this.value,
    this.engagement,
  });

  /// Builds a record from one entry of a `listRecords` response.
  factory RepoRecord.fromJson(
    Map<String, Object?> json, {
    Engagement? engagement,
  }) {
    return RepoRecord(
      uri: AtUri.parse(json['uri'] as String),
      cid: json['cid'] as String,
      value: _asMap(json['value']) ?? const {},
      engagement: engagement,
    );
  }

  final AtUri uri;
  final String cid;
  final Map<String, Object?> value;
  final Engagement? engagement;

  String get collection => uri.collection ?? '';

  late final DateTime? createdAt = switch (value['createdAt']) {
    final String s => DateTime.tryParse(s)?.toUtc(),
    _ => null,
  };

  late final Set<RecordKind> kinds = _computeKinds();

  /// Post text; empty for non-post records.
  String get text => value['text'] as String? ?? '';

  /// BCP-47 language tags declared on the post.
  late final List<String> langs = _strings(value['langs']);

  late final AtUri? replyParent = AtUri.tryParse(
    _path(value, ['reply', 'parent', 'uri']),
  );

  late final AtUri? replyRoot = AtUri.tryParse(
    _path(value, ['reply', 'root', 'uri']),
  );

  /// The post this record quotes, if any.
  late final AtUri? quoted = switch (_embedType) {
    Nsid.embedRecord => AtUri.tryParse(_path(_embed, ['record', 'uri'])),
    Nsid.embedRecordWithMedia => AtUri.tryParse(
      _path(_embed, ['record', 'record', 'uri']),
    ),
    _ => null,
  };

  /// For a repost or like: the post it points at.
  late final AtUri? subject = AtUri.tryParse(_path(value, ['subject', 'uri']));

  /// The DID this record is "about": the reposted or liked post's author, or
  /// the followed account.
  late final String? subjectDid = collection == Nsid.follow
      ? value['subject'] as String?
      : subject?.authority;

  late final Set<MediaKind> media = _computeMedia();

  /// True when any attached image or video has no alt text.
  late final bool missingAltText = _computeMissingAlt();

  /// DIDs mentioned in the post text.
  late final Set<String> mentionedDids = _facetValues(Nsid.facetMention, 'did');

  /// Hashtags, lower-cased and without the leading `#`.
  late final Set<String> hashtags = {
    ..._facetValues(Nsid.facetTag, 'tag'),
    ..._strings(value['tags']),
  }.map((t) => t.replaceFirst('#', '').toLowerCase()).toSet();

  /// Every link in the post: link facets and an external embed's URI.
  late final Set<Uri> links = {
    ..._facetValues(Nsid.facetLink, 'uri'),
    ?_externalUri,
  }.map(Uri.tryParse).whereType<Uri>().toSet();

  // --- internals -----------------------------------------------------------

  Map<String, Object?>? get _embed => _asMap(value['embed']);

  String? get _embedType => _embed?[r'$type'] as String?;

  /// The media part of the embed (unwrapping `recordWithMedia`).
  Map<String, Object?>? get _mediaEmbed =>
      _embedType == Nsid.embedRecordWithMedia
      ? _asMap(_embed?['media'])
      : _embed;

  String? get _externalUri {
    final m = _mediaEmbed;
    if (m?[r'$type'] != Nsid.embedExternal) return null;
    return _path(m, ['external', 'uri']) as String?;
  }

  Set<RecordKind> _computeKinds() {
    switch (collection) {
      case Nsid.repost:
        return {RecordKind.repost};
      case Nsid.like:
        return {RecordKind.like};
      case Nsid.follow:
        return {RecordKind.follow};
      case Nsid.post:
        return {
          value['reply'] == null ? RecordKind.original : RecordKind.reply,
          if (quoted != null) RecordKind.quote,
        };
      default:
        return {RecordKind.other};
    }
  }

  Set<MediaKind> _computeMedia() {
    final m = _mediaEmbed;
    return switch (m?[r'$type']) {
      Nsid.embedImages => {MediaKind.images},
      Nsid.embedVideo => {MediaKind.video},
      Nsid.embedExternal =>
        _isGif(_externalUri) ? {MediaKind.gif} : {MediaKind.externalLink},
      _ => const {},
    };
  }

  bool _computeMissingAlt() {
    final m = _mediaEmbed;
    switch (m?[r'$type']) {
      case Nsid.embedImages:
        final images = m?['images'];
        if (images is! List) return false;
        return images.any(
          (i) => ((_asMap(i)?['alt'] as String?) ?? '').trim().isEmpty,
        );
      case Nsid.embedVideo:
        return ((m?['alt'] as String?) ?? '').trim().isEmpty;
      default:
        return false;
    }
  }

  Set<String> _facetValues(String featureType, String key) {
    final facets = value['facets'];
    if (facets is! List) return const {};
    return {
      for (final facet in facets)
        for (final feature in (_asMap(facet)?['features'] as List?) ?? const [])
          if (_asMap(feature)?[r'$type'] == featureType)
            if (_asMap(feature)?[key] case final String v) v,
    };
  }

  static bool _isGif(String? uri) {
    if (uri == null) return false;
    final parsed = Uri.tryParse(uri);
    if (parsed == null) return false;
    final host = parsed.host.toLowerCase();
    return host.endsWith('tenor.com') ||
        host.endsWith('giphy.com') ||
        parsed.path.toLowerCase().endsWith('.gif');
  }
}

Map<String, Object?>? _asMap(Object? o) =>
    o is Map ? o.cast<String, Object?>() : null;

List<String> _strings(Object? o) =>
    o is List ? o.whereType<String>().toList() : const [];

Object? _path(Map<String, Object?>? root, List<String> keys) {
  Object? node = root;
  for (final k in keys) {
    node = _asMap(node)?[k];
    if (node == null) return null;
  }
  return node;
}
