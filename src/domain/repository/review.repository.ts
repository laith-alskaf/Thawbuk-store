import { IReview } from "../entity/review";
import { CreateReviewDTO, UpdateReviewDTO, ProductReviewStatsDTO } from "../../application/dtos/review.dto";

export interface IReviewRepository {
  create(userId: string, reviewData: CreateReviewDTO): Promise<IReview>;
  findById(reviewId: string): Promise<IReview | null>;
  findByProductId(productId: string): Promise<IReview[]>;
  findByUserId(userId: string): Promise<IReview[]>;
  findByUserAndProduct(userId: string, productId: string): Promise<IReview | null>;
  update(reviewId: string, updateData: Partial<UpdateReviewDTO>): Promise<IReview | null>;
  delete(reviewId: string): Promise<boolean>;
  getProductStats(productId: string): Promise<ProductReviewStatsDTO>;
  checkVerifiedPurchase(userId: string, productId: string): Promise<boolean>;
}