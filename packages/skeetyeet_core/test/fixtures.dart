import 'package:skeetyeet_core/skeetyeet_core.dart';

const me = 'did:plc:me000000000000000000000';
const alice = 'did:plc:alice00000000000000000000';
const bob = 'did:plc:bob0000000000000000000000';

var _rkey = 0;

RepoRecord record(
  String collection,
  Map<String, Object?> value, {
  Engagement? engagement,
}) {
  _rkey++;
  return RepoRecord.fromJson({
    'uri': 'at://$me/$collection/3k${_rkey.toString().padLeft(11, '0')}',
    'cid': 'bafyrei$_rkey',
    'value': {r'$type': collection, ...value},
  }, engagement: engagement);
}

String postUri(String did, [String rkey = '3kabc']) =>
    'at://$did/${Nsid.post}/$rkey';

Map<String, Object?> strongRef(String uri) => {'uri': uri, 'cid': 'bafyx'};

RepoRecord post(
  String text, {
  String createdAt = '2024-06-01T12:00:00.000Z',
  Map<String, Object?>? embed,
  Map<String, Object?>? reply,
  List<Map<String, Object?>>? facets,
  List<String>? langs,
  Engagement? engagement,
}) => record(Nsid.post, {
  'text': text,
  'createdAt': createdAt,
  'embed': ?embed,
  'reply': ?reply,
  'facets': ?facets,
  'langs': ?langs,
}, engagement: engagement);

RepoRecord repost(
  String subjectUri, {
  String createdAt = '2024-06-01T12:00:00.000Z',
}) => record(Nsid.repost, {
  'subject': strongRef(subjectUri),
  'createdAt': createdAt,
});

RepoRecord like(
  String subjectUri, {
  String createdAt = '2024-06-01T12:00:00.000Z',
}) => record(Nsid.like, {
  'subject': strongRef(subjectUri),
  'createdAt': createdAt,
});

RepoRecord follow(
  String did, {
  String createdAt = '2024-06-01T12:00:00.000Z',
}) => record(Nsid.follow, {'subject': did, 'createdAt': createdAt});

Map<String, Object?> replyTo(String parentUri, {String? rootUri}) => {
  'parent': strongRef(parentUri),
  'root': strongRef(rootUri ?? parentUri),
};

Map<String, Object?> images({List<String> alts = const ['a photo']}) => {
  r'$type': Nsid.embedImages,
  'images': [
    for (final alt in alts)
      {
        'alt': alt,
        'image': {'ref': 'blob'},
      },
  ],
};

Map<String, Object?> video({String? alt}) => {
  r'$type': Nsid.embedVideo,
  'video': {'ref': 'blob'},
  'alt': ?alt,
};

Map<String, Object?> external(String uri) => {
  r'$type': Nsid.embedExternal,
  'external': {'uri': uri, 'title': 't', 'description': 'd'},
};

Map<String, Object?> quote(String uri) => {
  r'$type': Nsid.embedRecord,
  'record': strongRef(uri),
};

Map<String, Object?> quoteWithMedia(String uri, Map<String, Object?> media) => {
  r'$type': Nsid.embedRecordWithMedia,
  'record': {r'$type': Nsid.embedRecord, 'record': strongRef(uri)},
  'media': media,
};

Map<String, Object?> facet(String type, String key, String value) => {
  'index': {'byteStart': 0, 'byteEnd': 1},
  'features': [
    {r'$type': type, key: value},
  ],
};
