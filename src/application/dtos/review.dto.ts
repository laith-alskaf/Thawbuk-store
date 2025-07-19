export interface CreateReviewDTO {
  productId: string;
  rating: number;
  comment?: string;
}

export interface UpdateReviewDTO {
  reviewId: string;
  rating?: number;
  comment?: string;
}

export interface DeleteReviewDTO {
  reviewId: string;
}

export interface ReviewInfoDTO {
  _id: string;
  productId: string;
  userId: string;
  rating: number;
  comment?: string;
  isVerifiedPurchase: boolean;
  createdAt: Date;
  user?: {
    _id: string;
    name?: string;
  };
}

export interface ProductReviewStatsDTO {
  averageRating: number;
  totalReviews: number;
  ratingDistribution: {
    1: number;
    2: number;
    3: number;
    4: number;
    5: number;
  };
}