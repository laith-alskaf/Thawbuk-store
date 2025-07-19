import { IReviewRepository } from "../../domain/repository/review.repository";
import { IReview } from "../../domain/entity/review";
import { CreateReviewDTO, UpdateReviewDTO, ProductReviewStatsDTO } from "../../application/dtos/review.dto";
import { ReviewModel } from "../database/mongodb/models/review.model";
import { OrderModel } from "../database/mongodb/models/order.model";

export class ReviewRepository implements IReviewRepository {
  async create(userId: string, reviewData: CreateReviewDTO): Promise<IReview> {
    const isVerifiedPurchase = await this.checkVerifiedPurchase(userId, reviewData.productId);
    
    const newReview = new ReviewModel({
      ...reviewData,
      userId,
      isVerifiedPurchase
    });
    
    await newReview.save();
    return newReview.toObject();
  }

  async findById(reviewId: string): Promise<IReview | null> {
    const review = await ReviewModel.findById(reviewId)
      .populate('userId', 'name')
      .lean();
    return review;
  }

  async findByProductId(productId: string): Promise<IReview[]> {
    const reviews = await ReviewModel.find({ productId })
      .populate('userId', 'name')
      .sort({ createdAt: -1 })
      .lean();
    return reviews;
  }

  async findByUserId(userId: string): Promise<IReview[]> {
    const reviews = await ReviewModel.find({ userId })
      .populate('productId', 'name images')
      .sort({ createdAt: -1 })
      .lean();
    return reviews;
  }

  async findByUserAndProduct(userId: string, productId: string): Promise<IReview | null> {
    const review = await ReviewModel.findOne({ userId, productId }).lean();
    return review;
  }

  async update(reviewId: string, updateData: Partial<UpdateReviewDTO>): Promise<IReview | null> {
    const updatedReview = await ReviewModel.findByIdAndUpdate(
      reviewId,
      { $set: updateData },
      { new: true, runValidators: true }
    ).lean();
    return updatedReview;
  }

  async delete(reviewId: string): Promise<boolean> {
    const result = await ReviewModel.deleteOne({ _id: reviewId });
    return result.deletedCount > 0;
  }

  async getProductStats(productId: string): Promise<ProductReviewStatsDTO> {
    const stats = await ReviewModel.aggregate([
      { $match: { productId } },
      {
        $group: {
          _id: null,
          totalReviews: { $sum: 1 },
          averageRating: { $avg: "$rating" },
          ratings: { $push: "$rating" }
        }
      }
    ]);

    if (!stats.length) {
      return {
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
      };
    }

    const stat = stats[0];
    const ratingDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    
    stat.ratings.forEach((rating: number) => {
      ratingDistribution[rating as keyof typeof ratingDistribution]++;
    });

    return {
      averageRating: Math.round(stat.averageRating * 10) / 10,
      totalReviews: stat.totalReviews,
      ratingDistribution
    };
  }

  async checkVerifiedPurchase(userId: string, productId: string): Promise<boolean> {
    const order = await OrderModel.findOne({
      userId,
      'items.productId': productId,
      status: 'delivered'
    });
    return !!order;
  }
}