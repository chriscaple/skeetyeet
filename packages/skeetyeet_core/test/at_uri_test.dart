import 'package:skeetyeet_core/skeetyeet_core.dart';
import 'package:test/test.dart';

void main() {
  test('parses a full record URI', () {
    final uri = AtUri.parse('at://did:plc:abc/app.bsky.feed.post/3kxyz');
    expect(uri.authority, 'did:plc:abc');
    expect(uri.collection, 'app.bsky.feed.post');
    expect(uri.rkey, '3kxyz');
    expect(uri.hasDid, isTrue);
    expect(uri.toString(), 'at://did:plc:abc/app.bsky.feed.post/3kxyz');
  });

  test('parses handle-only and collection URIs', () {
    expect(AtUri.parse('at://alice.bsky.social').hasDid, isFalse);
    expect(AtUri.parse('at://did:plc:abc/app.bsky.feed.like').rkey, isNull);
  });

  test('ignores query and fragment', () {
    expect(AtUri.parse('at://did:plc:abc/c/r?x=1#frag').rkey, 'r');
  });

  test('rejects non-AT URIs', () {
    expect(() => AtUri.parse('https://bsky.app'), throwsFormatException);
    expect(() => AtUri.parse('at://'), throwsFormatException);
    expect(AtUri.tryParse('nope'), isNull);
    expect(AtUri.tryParse(42), isNull);
  });

  test('has value equality', () {
    expect(
      AtUri.parse('at://did:plc:a/c/r'),
      AtUri.parse('at://did:plc:a/c/r'),
    );
  });
}
