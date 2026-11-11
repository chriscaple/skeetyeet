/// Namespaced identifiers (NSIDs) for the AT Protocol record and embed types
/// SkeetYeet works with.
abstract final class Nsid {
  static const post = 'app.bsky.feed.post';
  static const repost = 'app.bsky.feed.repost';
  static const like = 'app.bsky.feed.like';
  static const follow = 'app.bsky.graph.follow';

  static const embedImages = 'app.bsky.embed.images';
  static const embedVideo = 'app.bsky.embed.video';
  static const embedExternal = 'app.bsky.embed.external';
  static const embedRecord = 'app.bsky.embed.record';
  static const embedRecordWithMedia = 'app.bsky.embed.recordWithMedia';

  static const facetMention = 'app.bsky.richtext.facet#mention';
  static const facetLink = 'app.bsky.richtext.facet#link';
  static const facetTag = 'app.bsky.richtext.facet#tag';

  /// Collections a deletion or unfollow job may touch.
  static const deletable = {post, repost, like, follow};
}
