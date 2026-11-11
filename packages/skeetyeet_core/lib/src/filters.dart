import 'at_uri.dart';
import 'records.dart';

/// State a filter may need beyond the record itself.
final class MatchContext {
  MatchContext({DateTime? now, this.pinnedPost, this.neverDelete = const {}})
    : now = (now ?? DateTime.now()).toUtc();

  /// "Now", fixed for the whole selection so relative dates are stable.
  final DateTime now;

  /// The account's pinned post. It is never selected.
  final AtUri? pinnedPost;

  /// Records the user marked "never delete" in the preview.
  final Set<AtUri> neverDelete;
}

/// A predicate over records. Filters compose with [AllOf], [AnyOf] and [Not].
sealed class Filter {
  const Filter();

  bool matches(RepoRecord record, MatchContext context);
}

// --- combinators -------------------------------------------------------------

final class AllOf extends Filter {
  const AllOf(this.filters);
  final List<Filter> filters;

  @override
  bool matches(RepoRecord r, MatchContext c) =>
      filters.every((f) => f.matches(r, c));
}

final class AnyOf extends Filter {
  const AnyOf(this.filters);
  final List<Filter> filters;

  @override
  bool matches(RepoRecord r, MatchContext c) =>
      filters.any((f) => f.matches(r, c));
}

final class Not extends Filter {
  const Not(this.filter);
  final Filter filter;

  @override
  bool matches(RepoRecord r, MatchContext c) => !filter.matches(r, c);
}

// --- content type ------------------------------------------------------------

/// Matches records of any of [kinds].
final class KindIs extends Filter {
  const KindIs(this.kinds);
  final Set<RecordKind> kinds;

  @override
  bool matches(RepoRecord r, MatchContext c) => r.kinds.any(kinds.contains);
}

// --- target account ----------------------------------------------------------

enum AccountRelation {
  /// A repost of a post by the account.
  repostOf,

  /// A reply whose direct parent is by the account.
  replyTo,

  /// A reply anywhere in a thread the account started.
  inThreadOf,

  /// A quote post of a post by the account.
  quoteOf,

  /// A post that mentions the account.
  mentions,

  /// A like of a post by the account.
  likeOf,

  /// A follow of the account.
  follows,
}

final class TargetAccount extends Filter {
  const TargetAccount(this.did, this.relation);
  final String did;
  final AccountRelation relation;

  @override
  bool matches(RepoRecord r, MatchContext c) => switch (relation) {
    AccountRelation.repostOf =>
      r.kinds.contains(RecordKind.repost) && r.subjectDid == did,
    AccountRelation.likeOf =>
      r.kinds.contains(RecordKind.like) && r.subjectDid == did,
    AccountRelation.follows =>
      r.kinds.contains(RecordKind.follow) && r.subjectDid == did,
    AccountRelation.replyTo => r.replyParent?.authority == did,
    AccountRelation.inThreadOf =>
      r.replyRoot?.authority == did || r.replyParent?.authority == did,
    AccountRelation.quoteOf => r.quoted?.authority == did,
    AccountRelation.mentions => r.mentionedDids.contains(did),
  };
}

// --- dates -------------------------------------------------------------------

/// Matches records created on or after [after] and strictly before [before].
/// Either bound may be omitted. Records without a valid date never match.
final class CreatedBetween extends Filter {
  const CreatedBetween({this.after, this.before});
  final DateTime? after;
  final DateTime? before;

  @override
  bool matches(RepoRecord r, MatchContext c) {
    final t = r.createdAt;
    if (t == null) return false;
    if (after != null && t.isBefore(after!.toUtc())) return false;
    if (before != null && !t.isBefore(before!.toUtc())) return false;
    return true;
  }
}

/// Matches records older than [age], measured from [MatchContext.now].
final class OlderThan extends Filter {
  const OlderThan(this.age);
  final Duration age;

  @override
  bool matches(RepoRecord r, MatchContext c) =>
      r.createdAt?.isBefore(c.now.subtract(age)) ?? false;
}

// --- media -------------------------------------------------------------------

/// Matches posts with any of [kinds] attached, or with any media at all when
/// [kinds] is null. Combine with [Not] for "has no media".
final class HasMedia extends Filter {
  const HasMedia([this.kinds]);
  final Set<MediaKind>? kinds;

  @override
  bool matches(RepoRecord r, MatchContext c) =>
      kinds == null ? r.media.isNotEmpty : r.media.any(kinds!.contains);
}

final class MissingAltText extends Filter {
  const MissingAltText();

  @override
  bool matches(RepoRecord r, MatchContext c) => r.missingAltText;
}

// --- text --------------------------------------------------------------------

/// Matches posts containing any (or, with [requireAll], every) term.
final class TextContains extends Filter {
  TextContains(
    List<String> terms, {
    this.requireAll = false,
    bool caseSensitive = false,
    bool wholeWord = false,
  }) : _patterns = [
         for (final t in terms.where((t) => t.trim().isNotEmpty))
           RegExp(
             wholeWord
                 ? '(?<!\\w)${RegExp.escape(t)}(?!\\w)'
                 : RegExp.escape(t),
             caseSensitive: caseSensitive,
             unicode: true,
           ),
       ];

  final bool requireAll;
  final List<RegExp> _patterns;

  @override
  bool matches(RepoRecord r, MatchContext c) {
    if (_patterns.isEmpty) return false;
    return requireAll
        ? _patterns.every((p) => p.hasMatch(r.text))
        : _patterns.any((p) => p.hasMatch(r.text));
  }
}

/// Matches posts whose text matches a user-supplied regular expression.
final class TextMatches extends Filter {
  TextMatches(String pattern, {bool caseSensitive = false})
    : _pattern = RegExp(pattern, caseSensitive: caseSensitive, unicode: true);

  final RegExp _pattern;

  @override
  bool matches(RepoRecord r, MatchContext c) => _pattern.hasMatch(r.text);
}

final class HasHashtag extends Filter {
  HasHashtag(Iterable<String> tags)
    : tags = tags.map((t) => t.replaceFirst('#', '').toLowerCase()).toSet();
  final Set<String> tags;

  @override
  bool matches(RepoRecord r, MatchContext c) => r.hashtags.any(tags.contains);
}

/// Matches posts linking to [domain] or any of its subdomains.
final class LinksToDomain extends Filter {
  LinksToDomain(String domain) : domain = domain.toLowerCase();
  final String domain;

  @override
  bool matches(RepoRecord r, MatchContext c) => r.links.any((u) {
    final host = u.host.toLowerCase();
    return host == domain || host.endsWith('.$domain');
  });
}

/// Matches posts in any of [languages]; `en` also matches `en-US`.
final class LanguageIs extends Filter {
  LanguageIs(Iterable<String> languages)
    : languages = languages.map((l) => l.toLowerCase()).toSet();
  final Set<String> languages;

  @override
  bool matches(RepoRecord r, MatchContext c) => r.langs.any((tag) {
    final t = tag.toLowerCase();
    return languages.contains(t) || languages.contains(t.split('-').first);
  });
}

// --- engagement --------------------------------------------------------------

enum EngagementMetric { likes, reposts, replies, quotes }

/// Matches posts whose [metric] is at least [atLeast] and/or fewer than
/// [fewerThan]. Records without engagement data never match.
final class EngagementIs extends Filter {
  const EngagementIs(this.metric, {this.atLeast, this.fewerThan});
  final EngagementMetric metric;
  final int? atLeast;
  final int? fewerThan;

  @override
  bool matches(RepoRecord r, MatchContext c) {
    final e = r.engagement;
    if (e == null) return false;
    final n = switch (metric) {
      EngagementMetric.likes => e.likes,
      EngagementMetric.reposts => e.reposts,
      EngagementMetric.replies => e.replies,
      EngagementMetric.quotes => e.quotes,
    };
    if (atLeast != null && n < atLeast!) return false;
    if (fewerThan != null && n >= fewerThan!) return false;
    return true;
  }
}

// --- rules -------------------------------------------------------------------

/// A selection rule: everything [select] matches, minus anything a [keep]
/// filter matches. Keep filters always win, and the pinned post and the
/// "never delete" list are always protected.
final class Rule {
  const Rule({required this.select, this.keep = const []});

  final Filter select;
  final List<Filter> keep;

  bool selects(RepoRecord r, MatchContext c) {
    if (r.uri == c.pinnedPost || c.neverDelete.contains(r.uri)) return false;
    return select.matches(r, c) && !keep.any((k) => k.matches(r, c));
  }

  Iterable<RepoRecord> apply(Iterable<RepoRecord> records, MatchContext c) =>
      records.where((r) => selects(r, c));
}
