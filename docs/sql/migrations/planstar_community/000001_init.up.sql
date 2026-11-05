-- ========================================================================
--  migrations/planstar_community/000001_init.up.sql
--  由 08_community.sql 生成（去掉 USE，供迁移工具按库执行）
-- ========================================================================

-- ----------------------------------------------------------------------
--  域 6 · 内容与社区（UGC / feed / content）
-- ----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `reviews` (
  `id` BIGINT NOT NULL COMMENT '评论ID | Review.id',
  `user_id` BIGINT COMMENT '用户ID | Review.userId',
  `activity_id` BIGINT COMMENT '演出ID | Review.activityId',
  `content` TEXT COMMENT '内容 | Review.content',
  `rank` INT COMMENT '星级 | Review.rank / CreateReviewRequestBody.rank',
  `images` JSON COMMENT '图片（原 List<String>）| Review.images',
  `videos` JSON COMMENT '视频（原 List<JSONObject> / JSONArray）| Review.videos',
  `liked` TINYINT(1) COMMENT '已赞 | Review.liked',
  `likes` INT COMMENT '赞数 | Review.likes',
  `reply_count` INT COMMENT '回复数 | Review.replyCount',
  `status` INT COMMENT '状态 | Review.status',
  `num_plus_related` INT COMMENT '相关数 | Review.numPlusRelated',
  `page_index` INT COMMENT '页码（DTO 复用）| Review.pageIndex',
  `page_size` INT COMMENT '页大小（DTO 复用）| Review.pageSize',
  `total_num` INT COMMENT '总数（DTO 复用）| Review.totalNum',
  `data` JSON COMMENT '自嵌套列表（原 List<Review>）| Review.data',
  `activity` JSON COMMENT '演出快照 | Review.activity',
  `user` JSON COMMENT '用户快照 | Review.user',
  `add_time` BIGINT COMMENT '创建时间 | Review.addTime',
  `update_time` BIGINT COMMENT '更新时间 | Review.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_review_act` (`activity_id`),
  KEY `idx_review_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论 / 评价 | Review / CreateReviewRequestBody（v1/reviews · v3/reviews）';

CREATE TABLE IF NOT EXISTS `review_replies` (
  `id` BIGINT NOT NULL COMMENT '回复ID | Reply.id',
  `review_id` BIGINT COMMENT '评论ID | Reply.reviewId',
  `user_id` BIGINT COMMENT '用户ID | Reply.userId',
  `reply_to_user_id` BIGINT COMMENT '被回复用户 | Reply.replyToUserId',
  `reply_to_user_name` VARCHAR(128) COMMENT '被回复用户名 | Reply.replyToUserName',
  `content` TEXT COMMENT '内容 | Reply.content',
  `is_top` TINYINT(1) COMMENT '是否置顶 | Reply.isTop',
  `page_index` INT COMMENT '页码 | Reply.pageIndex',
  `page_size` INT COMMENT '页大小 | Reply.pageSize',
  `total_num` INT COMMENT '总数 | Reply.totalNum',
  `data` JSON COMMENT '自嵌套列表（原 List<Reply>）| Reply.data',
  `user` JSON COMMENT '用户快照 | Reply.user',
  `add_time` BIGINT COMMENT '创建时间 | Reply.addTime',
  PRIMARY KEY (`id`),
  KEY `idx_reply_review` (`review_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论回复 | Reply / ReplySendRequestBody（v1/reviews/{id}/replies）';

CREATE TABLE IF NOT EXISTS `review_todos` (
  `id` BIGINT NOT NULL COMMENT 'ID | ReviewToDo.id',
  `user_id` BIGINT COMMENT '用户ID | ReviewToDo.userId',
  `activity_id` BIGINT COMMENT '演出ID | ReviewToDo.activityId',
  `activity_event_id` BIGINT COMMENT '场次ID | ReviewToDo.activityEventId',
  `event_time` BIGINT COMMENT '场次时间 | ReviewToDo.eventTime',
  `status` INT COMMENT '状态 | ReviewToDo.status',
  `activity` JSON COMMENT '演出快照 | ReviewToDo.activity',
  `add_time` BIGINT COMMENT '创建时间 | ReviewToDo.addTime',
  `update_time` BIGINT COMMENT '更新时间 | ReviewToDo.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_todo_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='待评价 | ReviewToDo（v1/reviews/todo）';

CREATE TABLE IF NOT EXISTS `feeds` (
  `id` BIGINT NOT NULL COMMENT '动态ID | FeedBean.id / Tweet.id',
  `type` INT COMMENT '动态类型（见 dict_enums.FeedType）| FeedBean.type / FeedContentBean.type',
  `user_id` BIGINT COMMENT '作者 | FeedContentBean.userId / Tweet.userId',
  `user` JSON COMMENT '作者快照（原 UserBean）| FeedContentBean.user',
  `content` TEXT COMMENT '正文 | FeedContentBean.content / Tweet.content',
  `title` VARCHAR(512) COMMENT '标题 | FeedContentBean.title',
  `name` VARCHAR(256) COMMENT '名称 | FeedContentBean.name',
  `desc` TEXT COMMENT '描述 | FeedContentBean.desc',
  `poster` VARCHAR(1024) COMMENT '海报 | FeedContentBean.poster',
  `head_img` VARCHAR(1024) COMMENT '头图 | FeedContentBean.headImg',
  `background_img` VARCHAR(1024) COMMENT '背景图 | FeedContentBean.backgroundImg',
  `schema` VARCHAR(1024) COMMENT '跳转 scheme | FeedContentBean.schema',
  `price` DECIMAL(12,2) COMMENT '价格 | FeedContentBean.price',
  `amount` INT COMMENT '数量 | FeedContentBean.amount',
  `liked` TINYINT(1) COMMENT '已赞 | FeedContentBean.liked / Tweet.liked',
  `likes` INT COMMENT '赞数 | FeedContentBean.likes / Tweet.likes',
  `reply_count` INT COMMENT '回复数 | FeedContentBean.replyCount / Tweet.replyCount',
  `shares` INT COMMENT '分享数 | FeedContentBean.shares',
  `views` INT COMMENT '浏览数 | FeedContentBean.views / Tweet.views',
  `click_num` INT COMMENT '点击数 | FeedContentBean.clickNum / Tweet.clickNum',
  `rank` INT COMMENT '权重 | FeedContentBean.rank',
  `quality` TINYINT(1) COMMENT '精华 | FeedContentBean.quality',
  `status` INT COMMENT '状态 | FeedContentBean.status / Tweet.status',
  `feed_num` INT COMMENT '动态数 | FeedContentBean.feedNum',
  `want_watch_num` INT COMMENT '想看数 | FeedContentBean.wantWatchNum',
  `relative_activity_count` INT COMMENT '关联演出数 | FeedContentBean.relativeActivityCount',
  `top_feed` VARCHAR(64) COMMENT '置顶标记 | FeedContentBean.topFeed',
  `top_feed_id` BIGINT COMMENT '置顶ID | FeedContentBean.topFeedId',
  `top_feed_type` INT COMMENT '置顶类型 | FeedContentBean.topFeedType',
  `next_page_key` VARCHAR(256) COMMENT '下一页游标 | FeedPagination.nextPageKey',
  `has_more` TINYINT(1) COMMENT '是否有更多 | FeedPagination.hasMore',
  `content_obj` JSON COMMENT '内容体（原 FeedContentBean）| FeedBean.content',
  `addition` JSON COMMENT '自嵌套附加内容（原 FeedContentBean）| FeedContentBean.addition',
  `images` JSON COMMENT '图片（原 List<ImageInfo> / List<String>）| FeedContentBean.images',
  `videos` JSON COMMENT '视频（原 List<VideoItemBean> / List<JSONObject>）| FeedContentBean.videos',
  `tags` JSON COMMENT '标签（原 List<TagBean>）| FeedContentBean.tags',
  `topic_list` JSON COMMENT '话题（原 List<TopicBean>）| FeedContentBean.topicList',
  `users` JSON COMMENT '用户列表（原 List<UserBean>）| FeedContentBean.users',
  `group` JSON COMMENT '群组（原 CommunityBean）| FeedContentBean.group',
  `activity` JSON COMMENT '演出快照（原 ActivityBean）| FeedContentBean.activity',
  `activity_event` JSON COMMENT '场次快照（原 ActivityEventBean）| FeedContentBean.activityEvent',
  `ticket_category` JSON COMMENT '票档快照 | FeedContentBean.ticketCategory',
  `relative_activities` JSON COMMENT '关联演出（原 List<RelativeActivityBean>）| FeedContentBean.relativeActivities',
  `recommend_tweets` JSON COMMENT '推荐（原 List<FeedContentBean>）| FeedContentBean.recommendTweets',
  `follow_groups` JSON COMMENT '推荐群组（原 List<CommunityBean>）| FeedContentBean.followGroups',
  `follow_recommends` JSON COMMENT '推荐用户（原 List<RecommendUser>）| FeedContentBean.followRecommends',
  `add_time` BIGINT COMMENT '创建时间 | FeedContentBean.addTime / Tweet.addTime',
  `update_time` BIGINT COMMENT '更新时间 | FeedContentBean.updateTime / Tweet.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_feed_user` (`user_id`),
  KEY `idx_feed_type` (`type`),
  KEY `idx_feed_addtime` (`add_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态 / 推文 | FeedBean / FeedContentBean / Tweet / FeedPagination';

CREATE TABLE IF NOT EXISTS `feed_media` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `feed_id` BIGINT COMMENT '动态ID | 推断',
  `media_type` VARCHAR(32) COMMENT 'image / video | 推断',
  `format` VARCHAR(32) COMMENT '图片格式 | ImageInfo.format',
  `thumbnail` VARCHAR(1024) COMMENT '缩略图 | ImageInfo.thumbnail',
  `url` VARCHAR(1024) COMMENT '资源地址 | ImageInfo.url / VideoItemBean.url',
  `title` VARCHAR(512) COMMENT '视频标题 | VideoItemBean.title',
  `poster` VARCHAR(1024) COMMENT '视频封面 | VideoItemBean.poster / TweetVideo.poster',
  `duration` VARCHAR(64) COMMENT '时长 | VideoItemBean.duration / TweetVideo.duration',
  `height` INT COMMENT '高 | VideoItemBean.height',
  `width` INT COMMENT '宽 | VideoItemBean.width',
  PRIMARY KEY (`id`),
  KEY `idx_feedmedia_feed` (`feed_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态媒体 | ImageInfo / VideoItemBean / TweetVideo';

CREATE TABLE IF NOT EXISTS `topics` (
  `id` BIGINT NOT NULL COMMENT '话题ID | TopicBean.id',
  `name` VARCHAR(256) COMMENT '话题名 | TopicBean.name',
  `desc` TEXT COMMENT '描述 | TopicBean.desc',
  `background_img` VARCHAR(1024) COMMENT '背景图 | TopicBean.backgroundImg',
  `activity_id` BIGINT COMMENT '关联演出 | TopicBean.activityId',
  `feed_num` INT COMMENT '动态数 | TopicBean.feedNum',
  `status` INT COMMENT '状态 | TopicBean.status',
  `top_feed_id` BIGINT COMMENT '置顶动态ID | TopicBean.topFeedId',
  `top_feed_type` INT COMMENT '置顶类型 | TopicBean.topFeedType',
  `type` INT COMMENT '类型 | TopicBean.type',
  `background_color` VARCHAR(32) COMMENT '背景色 | TopicWithColorBean.backgroundColor',
  `text_color` VARCHAR(32) COMMENT '文字色 | TopicWithColorBean.textColor',
  `text` VARCHAR(256) COMMENT '文案 | TopicWithColorBean.name',
  `add_time` BIGINT COMMENT '创建时间 | TopicBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | TopicBean.updateTime',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='话题 | TopicBean / TopicWithColorBean / FeedListTopicBean';

CREATE TABLE IF NOT EXISTS `communities` (
  `id` BIGINT NOT NULL COMMENT '群组ID | CommunityBean.id',
  `name` VARCHAR(256) COMMENT '名称 | CommunityBean.name / ActivityGroupBean.groupName',
  `icon` VARCHAR(1024) COMMENT '图标 | CommunityBean.icon / ActivityGroupBean.icon',
  `desc` TEXT COMMENT '简介 | CommunityBean.desc / ActivityGroupBean.intro',
  `background_img` VARCHAR(1024) COMMENT '背景图 | CommunityBean.backgroundImg',
  `feed_num` INT COMMENT '动态数 | CommunityBean.feedNum',
  `participant_num` INT COMMENT '参与人数 | CommunityBean.participantNum',
  `update_num` INT COMMENT '更新数 | CommunityBean.updateNum',
  `subscribed` TINYINT(1) COMMENT '已订阅 | CommunityBean.subscribed',
  `tid` VARCHAR(128) COMMENT '环信群ID | ActivityGroupBean.tid',
  `is_my_team` TINYINT(1) COMMENT '我的队伍 | ActivityGroupBean.isMyTeam',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社群 / 圈子 | CommunityBean / CommunityCategoryBean / ActivityGroupBean';

CREATE TABLE IF NOT EXISTS `user_articles` (
  `id` BIGINT NOT NULL COMMENT '文章ID | ArticleBean.id / Article.id',
  `user_id` BIGINT COMMENT '作者 | ArticleBean.userId',
  `title` VARCHAR(512) COMMENT '标题 | ArticleBean.title / Article.title',
  `desc` TEXT COMMENT '摘要 | ArticleBean.desc / Article.desc',
  `head_img` VARCHAR(1024) COMMENT '头图 | ArticleBean.headImg / Article.headImg',
  `content` JSON COMMENT '内容块（原 List<ContentBean>）| ArticleBean.content',
  `text` TEXT COMMENT '正文文本 | ArticleBean.text',
  `poster` VARCHAR(1024) COMMENT '海报 | ArticleBean.poster',
  `image` VARCHAR(1024) COMMENT '图片 | ArticleBean.image',
  `author` VARCHAR(256) COMMENT '作者名 | Article.author',
  `friendly_time` VARCHAR(128) COMMENT '时间文案 | Article.friendlyTime',
  `time_range` VARCHAR(128) COMMENT '时间范围 | ArticleBean.timeRange',
  `type` INT COMMENT '类型 | ArticleBean.type',
  `status` INT COMMENT '状态 | ArticleBean.status',
  `liked` TINYINT(1) COMMENT '已赞 | ArticleBean.liked',
  `likes` INT COMMENT '赞数 | ArticleBean.likes',
  `reply_count` INT COMMENT '回复数 | ArticleBean.replyCount',
  `venue_city_id` INT COMMENT '场馆城市 | ArticleBean.venueCityId',
  `name` VARCHAR(256) COMMENT '名称 | ArticleBean.name',
  `attributes` JSON COMMENT '属性（原 JSONObject）| ArticleBean.attributes',
  `tags` JSON COMMENT '标签（原 List<TagBean>）| ArticleBean.tags',
  `group` JSON COMMENT '群组（原 CommunityBean）| ArticleBean.group',
  `user` JSON COMMENT '用户快照 | ArticleBean.user',
  `activities` JSON COMMENT '关联演出（原 List<ActivityBean>）| Article.activities',
  `related_activies` JSON COMMENT '相关演出（原 List<ActivityBean>）| ArticleDetailBean.relatedActivies',
  `related_user_article` JSON COMMENT '相关文章（原 List<FeedBean>）| ArticleDetailBean.relatedUserArticle',
  `add_time` BIGINT COMMENT '创建时间 | ArticleBean.addTime',
  `update_time` BIGINT COMMENT '更新时间 | ArticleBean.updateTime',
  PRIMARY KEY (`id`),
  KEY `idx_article_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='长文章 / 用户文章 | ArticleBean / Article / ArticleDetailBean';

CREATE TABLE IF NOT EXISTS `likes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '代理主键',
  `user_id` BIGINT COMMENT '用户ID | 推断',
  `subject_id` BIGINT COMMENT '主体ID | ReplySendRequestBody.subjectId',
  `subject_type` INT COMMENT '主体类型 | 推断',
  `type` INT COMMENT '类型 | ReplySendRequestBody.type',
  `content` TEXT COMMENT '回复内容 | ReplySendRequestBody.content',
  `reply_to_user_id` BIGINT COMMENT '被回复用户 | ReplySendRequestBody.replyToUserId',
  `status` INT COMMENT '状态 | 推断',
  `add_time` BIGINT COMMENT '创建时间 | 推断',
  PRIMARY KEY (`id`),
  KEY `idx_like_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='点赞 / 回复关系 | v1/userLike · v1/userReply · userLike 删除';

CREATE TABLE IF NOT EXISTS `video_channels` (
  `id` BIGINT NOT NULL COMMENT '视频ID | VideoDetailBean.id',
  `featured_video_id` INT COMMENT '精选视频ID | FeaturedVideoBean.featuredVideoId',
  `featured_video_name` VARCHAR(256) COMMENT '精选名 | FeaturedVideoBean.featuredVideoName',
  `user_id` BIGINT COMMENT '作者 | VideoDetailBean.user.userId',
  `content` TEXT COMMENT '内容 | VideoDetailBean.content',
  `group` JSON COMMENT '群组（原 CommunityBean）| VideoDetailBean.group',
  `video` JSON COMMENT '视频体（原 VideoItemBean）| VideoDetailBean.video',
  `tweet_vo` JSON COMMENT '推文（原 Tweet）| FeaturedVideoBean.tweetVO',
  `tag` JSON COMMENT '标签（原 TagBean）| VideoChannelBean.tag',
  `tags` JSON COMMENT '标签列表 | VideoDetailBean.tags',
  `related_activities` JSON COMMENT '关联演出 | VideoDetailBean.relatedActivities',
  `is_liked` TINYINT(1) COMMENT '已赞 | VideoDetailBean.isLiked',
  `likes` INT COMMENT '赞数 | VideoDetailBean.likes',
  `rank` INT COMMENT '权重 | VideoDetailBean.rank',
  `reply_count` INT COMMENT '回复数 | VideoDetailBean.replyCount',
  `shares` INT COMMENT '分享数 | VideoDetailBean.shares',
  `views` INT COMMENT '浏览数 | VideoDetailBean.views',
  `type` INT COMMENT '类型 | VideoDetailBean.type',
  `add_time` BIGINT COMMENT '创建时间 | VideoDetailBean.addTime',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='视频频道 / 视频详情 | VideoChannelBean / VideoDetailBean / FeaturedVideoBean';
