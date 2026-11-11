import 'package:skeetyeet_core/skeetyeet_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  final ctx = MatchContext(now: DateTime.utc(2026, 11, 11));

  bool m(Filter f, RepoRecord r) => f.matches(r, ctx);

  group('target account', () {
    test('reposts of an account', () {
      const f = TargetAccount(alice, AccountRelation.repostOf);
      expect(m(f, repost(postUri(alice))), isTrue);
      expect(m(f, repost(postUri(bob))), isFalse);
      expect(m(f, like(postUri(alice))), isFalse);
    });

    test('replies to an account vs anywhere in their thread', () {
      final direct = post('x', reply: replyTo(postUri(alice)));
      final deep = post(
        'x',
        reply: replyTo(postUri(bob), rootUri: postUri(alice)),
      );
      expect(
        m(const TargetAccount(alice, AccountRelation.replyTo), direct),
        isTrue,
      );
      expect(
        m(const TargetAccount(alice, AccountRelation.replyTo), deep),
        isFalse,
      );
      expect(
        m(const TargetAccount(alice, AccountRelation.inThreadOf), deep),
        isTrue,
      );
    });

    test('quotes, mentions, likes and follows', () {
      expect(
        m(
          const TargetAccount(bob, AccountRelation.quoteOf),
          post('x', embed: quote(postUri(bob))),
        ),
        isTrue,
      );
      expect(
        m(
          const TargetAccount(alice, AccountRelation.mentions),
          post('x', facets: [facet(Nsid.facetMention, 'did', alice)]),
        ),
        isTrue,
      );
      expect(
        m(const TargetAccount(bob, AccountRelation.likeOf), like(postUri(bob))),
        isTrue,
      );
      expect(
        m(const TargetAccount(bob, AccountRelation.follows), follow(bob)),
        isTrue,
      );
    });
  });

  group('dates', () {
    final jan = post('x', createdAt: '2024-01-15T00:00:00Z');
    final jun = post('x', createdAt: '2024-06-15T00:00:00Z');

    test('between: after is inclusive, before is exclusive', () {
      final f = CreatedBetween(
        after: DateTime.utc(2024, 1, 15),
        before: DateTime.utc(2024, 6, 15),
      );
      expect(m(f, jan), isTrue);
      expect(m(f, jun), isFalse);
    });

    test('before a date', () {
      expect(m(CreatedBetween(before: DateTime.utc(2024, 3)), jan), isTrue);
      expect(m(CreatedBetween(before: DateTime.utc(2024, 3)), jun), isFalse);
    });

    test('older than a duration, relative to context now', () {
      final recent = post('x', createdAt: '2026-11-01T00:00:00Z');
      const f = OlderThan(Duration(days: 30));
      expect(m(f, jan), isTrue);
      expect(m(f, recent), isFalse);
    });

    test('undated records never match', () {
      expect(
        m(const OlderThan(Duration.zero), post('x', createdAt: 'bad')),
        isFalse,
      );
    });
  });

  group('media', () {
    test('specific kinds, any media, no media', () {
      final pic = post('x', embed: images());
      final vid = post('x', embed: video(alt: 'v'));
      final plain = post('x');
      expect(m(const HasMedia({MediaKind.images}), pic), isTrue);
      expect(m(const HasMedia({MediaKind.images}), vid), isFalse);
      expect(m(const HasMedia({MediaKind.video}), vid), isTrue);
      expect(m(const HasMedia(), vid), isTrue);
      expect(m(const Not(HasMedia()), plain), isTrue);
    });
  });

  group('text', () {
    final r = post('Going to the Beach today, then the beachfront bar');

    test('any keyword, case-insensitive by default', () {
      expect(m(TextContains(['beach']), r), isTrue);
      expect(m(TextContains(['beach'], caseSensitive: true), r), isTrue);
      expect(m(TextContains(['BEACH'], caseSensitive: true), r), isFalse);
    });

    test('all keywords', () {
      expect(m(TextContains(['beach', 'bar'], requireAll: true), r), isTrue);
      expect(m(TextContains(['beach', 'pool'], requireAll: true), r), isFalse);
    });

    test('whole word', () {
      expect(m(TextContains(['beachfront'], wholeWord: true), r), isTrue);
      expect(m(TextContains(['front'], wholeWord: true), r), isFalse);
    });

    test('regex, hashtags, domains, languages', () {
      expect(m(TextMatches(r'\bto(day|night)\b'), r), isTrue);
      expect(
        m(
          HasHashtag(['#SUNSET']),
          post('x', facets: [facet(Nsid.facetTag, 'tag', 'sunset')]),
        ),
        isTrue,
      );
      final link = post('x', embed: external('https://www.example.com/a'));
      expect(m(LinksToDomain('example.com'), link), isTrue);
      expect(m(LinksToDomain('ample.com'), link), isFalse);
      expect(m(LanguageIs(['en']), post('x', langs: ['en-CA'])), isTrue);
      expect(m(LanguageIs(['fr']), post('x', langs: ['en'])), isFalse);
    });

    test('empty term list matches nothing', () {
      expect(m(TextContains(['', '  ']), r), isFalse);
    });
  });

  test('engagement thresholds', () {
    final popular = post('x', engagement: const Engagement(likes: 120));
    final quiet = post('x', engagement: const Engagement(likes: 2));
    const f = EngagementIs(EngagementMetric.likes, fewerThan: 10);
    expect(m(f, quiet), isTrue);
    expect(m(f, popular), isFalse);
    expect(m(f, post('no data')), isFalse);
  });

  group('rules', () {
    final pinned = post('my pinned intro', createdAt: '2020-01-01T00:00:00Z');
    final keeper = post(
      'old but loved',
      createdAt: '2020-01-01T00:00:00Z',
      engagement: const Engagement(likes: 500),
    );
    final old = post('old and forgettable', createdAt: '2020-01-01T00:00:00Z');
    final spared = post(
      'user said keep this',
      createdAt: '2020-01-01T00:00:00Z',
    );
    final fresh = post('new', createdAt: '2026-11-10T00:00:00Z');

    test('select minus keep rules, pinned and never-delete', () {
      final rule = Rule(
        select: const AllOf([
          KindIs({RecordKind.original, RecordKind.reply}),
          OlderThan(Duration(days: 365)),
        ]),
        keep: const [EngagementIs(EngagementMetric.likes, atLeast: 50)],
      );
      final c = MatchContext(
        now: DateTime.utc(2026, 11, 11),
        pinnedPost: pinned.uri,
        neverDelete: {spared.uri},
      );
      expect(rule.apply([pinned, keeper, old, spared, fresh], c), [old]);
    });

    test('AnyOf combines alternatives', () {
      final rule = Rule(
        select: AnyOf([
          const TargetAccount(alice, AccountRelation.repostOf),
          TextContains(['forgettable']),
        ]),
      );
      final aliceRepost = repost(postUri(alice));
      expect(rule.apply([aliceRepost, old, fresh, repost(postUri(bob))], ctx), [
        aliceRepost,
        old,
      ]);
    });
  });
}
