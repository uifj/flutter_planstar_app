// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketTier _$TicketTierFromJson(Map<String, dynamic> json) => _TicketTier(
  name: _readTierName(json, 'name') as String,
  price: _moneyFromCentsOrZero(_readTierPrice(json, 'price')),
  note: _readTierNote(json, 'note') as String?,
  remaining: (_readTierRemaining(json, 'remaining') as num?)?.toInt(),
  rewardType: _readTierRewardType(json, 'rewardType') as String? ?? '',
  items: _readTierItems(json, 'items') == null
      ? const <String>[]
      : _stringList(_readTierItems(json, 'items')),
  estimatedDeliveryTime:
      _readTierEstimatedDeliveryTime(json, 'estimatedDeliveryTime')
          as String? ??
      '',
);

Map<String, dynamic> _$TicketTierToJson(_TicketTier instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': _moneyToCents(instance.price),
      'note': instance.note,
      'remaining': instance.remaining,
      'rewardType': instance.rewardType,
      'items': instance.items,
      'estimatedDeliveryTime': instance.estimatedDeliveryTime,
    };

_ProjectFaq _$ProjectFaqFromJson(Map<String, dynamic> json) => _ProjectFaq(
  question: _readFaqQuestion(json, 'question') as String,
  answer: _readFaqAnswer(json, 'answer') as String,
  sort: (_readFaqSort(json, 'sort') as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProjectFaqToJson(_ProjectFaq instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'sort': instance.sort,
    };

_ProjectReview _$ProjectReviewFromJson(
  Map<String, dynamic> json,
) => _ProjectReview(
  userName: _readReviewUserName(json, 'userName') as String,
  rating: (_readReviewRating(json, 'rating') as num).toInt(),
  content: _readReviewContent(json, 'content') as String? ?? '',
  images: _readReviewImages(json, 'images') == null
      ? const <String>[]
      : _stringList(_readReviewImages(json, 'images')),
  isShow: _readReviewIsShow(json, 'isShow') as bool? ?? false,
  isAnonymous: _readReviewIsAnonymous(json, 'isAnonymous') as bool? ?? false,
  likeCount: (_readReviewLikeCount(json, 'likeCount') as num?)?.toInt() ?? 0,
  createdAt: _dateTime(_readReviewCreatedAt(json, 'createdAt')),
);

Map<String, dynamic> _$ProjectReviewToJson(_ProjectReview instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'rating': instance.rating,
      'content': instance.content,
      'images': instance.images,
      'isShow': instance.isShow,
      'isAnonymous': instance.isAnonymous,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_ProjectUpdate _$ProjectUpdateFromJson(Map<String, dynamic> json) =>
    _ProjectUpdate(
      title: _readUpdateTitle(json, 'title') as String,
      content: _readUpdateContent(json, 'content') as String,
      publishTime: _dateTime(_readUpdatePublishTime(json, 'publishTime')),
    );

Map<String, dynamic> _$ProjectUpdateToJson(_ProjectUpdate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'publishTime': instance.publishTime?.toIso8601String(),
    };

_ShowSession _$ShowSessionFromJson(Map<String, dynamic> json) => _ShowSession(
  startsAt: _dateTimeOrNow(_readSessionStartsAt(json, 'startsAt')),
  tierSummary: _readSessionTierSummary(json, 'tierSummary') as String,
  soldOut: _readSessionSoldOut(json, 'soldOut') as bool? ?? false,
);

Map<String, dynamic> _$ShowSessionToJson(_ShowSession instance) =>
    <String, dynamic>{
      'startsAt': instance.startsAt.toIso8601String(),
      'tierSummary': instance.tierSummary,
      'soldOut': instance.soldOut,
    };

_ShowSummary _$ShowSummaryFromJson(Map<String, dynamic> json) => _ShowSummary(
  id: _readShowId(json, 'id') as String,
  title: _readShowTitle(json, 'title') as String,
  artist: _readShowArtist(json, 'artist') as String,
  categoryId: (_readShowCategoryId(json, 'categoryId') as num).toInt(),
  categoryName: _readShowCategoryName(json, 'categoryName') as String,
  city: _readShowCity(json, 'city') as String,
  venue: _readShowVenue(json, 'venue') as String,
  venueAddress: _readShowVenueAddress(json, 'venueAddress') as String,
  firstSessionAt: _dateTimeOrNow(
    _readShowFirstSessionAt(json, 'firstSessionAt'),
  ),
  priceFrom: _moneyFromCentsOrZero(_readShowPriceFrom(json, 'priceFrom')),
  listPriceFrom: _moneyFromCentsOrNull(
    _readShowListPriceFrom(json, 'listPriceFrom'),
  ),
  discountPermille:
      (_readShowDiscountPermille(json, 'discountPermille') as num?)?.toInt(),
  tags: _readShowTags(json, 'tags') == null
      ? const <String>[]
      : _stringList(_readShowTags(json, 'tags')),
  wishCount: (_readShowWishCount(json, 'wishCount') as num?)?.toInt() ?? 0,
  soldOut: _readShowSoldOut(json, 'soldOut') as bool? ?? false,
  proxyBuy: _readShowProxyBuy(json, 'proxyBuy') as bool? ?? false,
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  ratingCount:
      (_readShowRatingCount(json, 'ratingCount') as num?)?.toInt() ?? 0,
  duration: _readShowDuration(json, 'duration') as String? ?? '',
  intro: _readShowIntro(json, 'intro') as String? ?? '',
  sessions: _readShowSessions(json, 'sessions') == null
      ? const <ShowSession>[]
      : _sessionList(_readShowSessions(json, 'sessions')),
  tiers: _readShowTiers(json, 'tiers') == null
      ? const <TicketTier>[]
      : _tierList(_readShowTiers(json, 'tiers')),
  lineup: _readShowLineup(json, 'lineup') == null
      ? const <String>[]
      : _stringList(_readShowLineup(json, 'lineup')),
  purchaseNotice: _readShowPurchaseNotice(json, 'purchaseNotice') == null
      ? const <String>[]
      : _stringList(_readShowPurchaseNotice(json, 'purchaseNotice')),
  goalAmount: _moneyFromCentsOrNull(_readShowGoalAmount(json, 'goalAmount')),
  raisedAmount: _moneyFromCentsOrNull(
    _readShowRaisedAmount(json, 'raisedAmount'),
  ),
  supporterCount:
      (_readShowSupporterCount(json, 'supporterCount') as num?)?.toInt() ?? 0,
  deadline: _dateTime(_readShowDeadline(json, 'deadline')),
  fundingStatus: _readShowFundingStatus(json, 'fundingStatus') as String? ?? '',
  riskNote: _readShowRiskNote(json, 'riskNote') as String? ?? '',
  deliveryPlan: _readShowDeliveryPlan(json, 'deliveryPlan') as String? ?? '',
  fundUsage: _readShowFundUsage(json, 'fundUsage') as String? ?? '',
  refundRule: _readShowRefundRule(json, 'refundRule') as String? ?? '',
  refundDays: (_readShowRefundDays(json, 'refundDays') as num?)?.toInt() ?? 7,
  faqs: _readShowFaqs(json, 'faqs') == null
      ? const <ProjectFaq>[]
      : _faqList(_readShowFaqs(json, 'faqs')),
  reviews: _readShowReviews(json, 'reviews') == null
      ? const <ProjectReview>[]
      : _reviewList(_readShowReviews(json, 'reviews')),
  ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
  apiReviewCount:
      (_readShowApiReviewCount(json, 'apiReviewCount') as num?)?.toInt() ?? 0,
  apiShowCount:
      (_readShowApiShowCount(json, 'apiShowCount') as num?)?.toInt() ?? 0,
  updates: _readShowUpdates(json, 'updates') == null
      ? const <ProjectUpdate>[]
      : _updateList(_readShowUpdates(json, 'updates')),
  creatorVerified:
      _readShowCreatorVerified(json, 'creatorVerified') as bool? ?? false,
  creatorProjectNum:
      (_readShowCreatorProjectNum(json, 'creatorProjectNum') as num?)
          ?.toInt() ??
      0,
  creatorSuccessNum:
      (_readShowCreatorSuccessNum(json, 'creatorSuccessNum') as num?)
          ?.toInt() ??
      0,
  creatorFulfillmentPermille:
      (_readShowCreatorFulfillmentPermille(json, 'creatorFulfillmentPermille')
              as num?)
          ?.toInt() ??
      0,
  creatorBio: _readShowCreatorBio(json, 'creatorBio') as String? ?? '',
);

Map<String, dynamic> _$ShowSummaryToJson(_ShowSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'city': instance.city,
      'venue': instance.venue,
      'venueAddress': instance.venueAddress,
      'firstSessionAt': instance.firstSessionAt.toIso8601String(),
      'priceFrom': _moneyToCents(instance.priceFrom),
      'listPriceFrom': _moneyToCentsOrNull(instance.listPriceFrom),
      'discountPermille': instance.discountPermille,
      'tags': instance.tags,
      'wishCount': instance.wishCount,
      'soldOut': instance.soldOut,
      'proxyBuy': instance.proxyBuy,
      'rating': instance.rating,
      'ratingCount': instance.ratingCount,
      'duration': instance.duration,
      'intro': instance.intro,
      'sessions': instance.sessions,
      'tiers': instance.tiers,
      'lineup': instance.lineup,
      'purchaseNotice': instance.purchaseNotice,
      'goalAmount': _moneyToCentsOrNull(instance.goalAmount),
      'raisedAmount': _moneyToCentsOrNull(instance.raisedAmount),
      'supporterCount': instance.supporterCount,
      'deadline': instance.deadline?.toIso8601String(),
      'fundingStatus': instance.fundingStatus,
      'riskNote': instance.riskNote,
      'deliveryPlan': instance.deliveryPlan,
      'fundUsage': instance.fundUsage,
      'refundRule': instance.refundRule,
      'refundDays': instance.refundDays,
      'faqs': instance.faqs,
      'reviews': instance.reviews,
      'ratingAvg': instance.ratingAvg,
      'apiReviewCount': instance.apiReviewCount,
      'apiShowCount': instance.apiShowCount,
      'updates': instance.updates,
      'creatorVerified': instance.creatorVerified,
      'creatorProjectNum': instance.creatorProjectNum,
      'creatorSuccessNum': instance.creatorSuccessNum,
      'creatorFulfillmentPermille': instance.creatorFulfillmentPermille,
      'creatorBio': instance.creatorBio,
    };
