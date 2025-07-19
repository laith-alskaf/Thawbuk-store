import mongoose, { Schema, Model, Document } from "mongoose";
import { IReview } from "../../../../domain/entity/review";

type ReviewDocument = IReview & Document;

const reviewSchema = new Schema<ReviewDocument>({
    _id: { type: String, default: () => crypto.randomUUID() },
    productId: { 
        type: String, 
        ref: 'Product', 
        required: true,
        index: true 
    },
    userId: { 
        type: String, 
        ref: 'User', 
        required: true,
        index: true 
    },
    rating: { 
        type: Number, 
        required: true, 
        min: 1, 
        max: 5 
    },
    comment: { type: String, trim: true, maxlength: 1000 },
    isVerifiedPurchase: { type: Boolean, default: false }
}, { timestamps: true });

// فهرس مركب لضمان مراجعة واحدة لكل مستخدم لكل منتج
reviewSchema.index({ productId: 1, userId: 1 }, { unique: true });

export const ReviewModel: Model<ReviewDocument> = mongoose.model<ReviewDocument>('Review', reviewSchema);