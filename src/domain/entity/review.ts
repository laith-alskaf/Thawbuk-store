export interface IReview {
  _id: string;
  productId: string;
  userId: string;
  rating: number; // 1-5
  comment?: string;
  isVerifiedPurchase: boolean;
  createdAt: Date;
  updatedAt: Date;
}