class GetRatings {
  bool? success;
  String? message;
  RatingsData? data;

  GetRatings({this.success, this.message, this.data});

  GetRatings.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? RatingsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RatingsData {
  double? averageRating;
  int? totalReviews;
  List<Review>? reviews;

  RatingsData({this.averageRating, this.totalReviews, this.reviews});

  RatingsData.fromJson(Map<String, dynamic> json) {
    averageRating = (json['averageRating'] as num?)?.toDouble();
    totalReviews = json['totalReviews'];

    if (json['reviews'] != null) {
      reviews =
          (json['reviews'] as List).map((v) => Review.fromJson(v)).toList();
    } else {
      reviews = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['averageRating'] = averageRating;
    data['totalReviews'] = totalReviews;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Review {
  String? review;
  int? rating;

  Review({this.review, this.rating});

  Review.fromJson(Map<String, dynamic> json) {
    review = json['review'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['review'] = review;
    data['rating'] = rating;
    return data;
  }
}
