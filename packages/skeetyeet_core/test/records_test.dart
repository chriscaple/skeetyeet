import 'package:skeetyeet_core/skeetyeet_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('kinds', () {
    test('original post', () {
      expect(post('hi').kinds, {RecordKind.original});
    });

    test('reply', () {
      expect(post('hi', reply: replyTo(postUri(alice))).kinds, {
        RecordKind.reply,
      });
    });

    test('quote reply is both reply and quote', () {
      final r = post(
        'hi',
        reply: replyTo(postUri(alice)),
        embed: quote(postUri(bob)),
      );
      expect(r.kinds, {RecordKind.reply, RecordKind.quote});
      expect(r.quoted?.authority, bob);
    });

    test('quote with media', () {
      final r = post('hi', embed: quoteWithMedia(postUri(bob), images()));
      expect(r.kinds, {RecordKind.original, RecordKind.quote});
      expect(r.media, {MediaKind.images});
    });

    test('repost, like and follow carry their subject DID', () {
      expect(repost(postUri(alice)).subjectDid, alice);
      expect(like(postUri(bob)).subjectDid, bob);
      expect(follow(alice).subjectDid, alice);
      expect(follow(alice).kinds, {RecordKind.follow});
    });
  });

  group('media', () {
    test('images, video and links', () {
      expect(post('x', embed: images()).media, {MediaKind.images});
      expect(post('x', embed: video(alt: 'v')).media, {MediaKind.video});
      expect(post('x', embed: external('https://example.com/a')).media, {
        MediaKind.externalLink,
      });
      expect(post('x').media, isEmpty);
    });

    test('Tenor and .gif links are GIFs', () {
      expect(
        post('x', embed: external('https://media.tenor.com/abc/x.gif')).media,
        {MediaKind.gif},
      );
      expect(
        post('x', embed: external('https://cdn.example.com/dance.GIF')).media,
        {MediaKind.gif},
      );
    });

    test('missing alt text', () {
      expect(
        post('x', embed: images(alts: ['ok', ' '])).missingAltText,
        isTrue,
      );
      expect(post('x', embed: images(alts: ['ok'])).missingAltText, isFalse);
      expect(post('x', embed: video()).missingAltText, isTrue);
    });
  });

  group('facets', () {
    test('mentions, hashtags and links', () {
      final r = post(
        'hey @alice #Sunset',
        facets: [
          facet(Nsid.facetMention, 'did', alice),
          facet(Nsid.facetTag, 'tag', 'Sunset'),
          facet(Nsid.facetLink, 'uri', 'https://news.example.org/story'),
        ],
      );
      expect(r.mentionedDids, {alice});
      expect(r.hashtags, {'sunset'});
      expect(r.links.single.host, 'news.example.org');
    });
  });

  test('createdAt is parsed as UTC; bad dates are null', () {
    expect(
      post('x', createdAt: '2024-01-02T03:04:05-05:00').createdAt,
      DateTime.utc(2024, 1, 2, 8, 4, 5),
    );
    expect(post('x', createdAt: 'yesterday').createdAt, isNull);
  });
}
