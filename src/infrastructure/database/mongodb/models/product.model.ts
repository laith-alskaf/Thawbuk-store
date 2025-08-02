import mongoose, { Schema, Model, Document } from "mongoose";
import { IProduct } from "../../../../domain/entity/product";

type ProductDocument = IProduct & Document;

const productSchema = new Schema<ProductDocument>({
    _id: { type: String, default: () => crypto.randomUUID() },
    name: { type: String, required: true },
    nameAr: { type: String },
    price: { type: Number, required: true },
    description: { type: String },
    descriptionAr: { type: String },
    images: [{ type: String, match: [/^https?:\/\/.+/] }],
    sizes: [{ type: String }],
    colors: [{ type: String }],
    stock: { type: Number, default: 0 },
    brand: { type: String },
    ageRange: {
        minAge: { type: Number },
        maxAge: { type: Number },
    },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    reviewsCount: { type: Number, default: 0, min: 0 },
    favoritesCount: { type: Number, default: 0, min: 0 },
    viewsCount: { type: Number, default: 0, min: 0 },
    categoryId: { type: String, ref: 'Category', required: true },
    createdBy: {
        type: String,
        ref: 'User',
        required: true,
    },
}, {
    timestamps: true,
});

productSchema.index({ name: 'text', nameAr: 'text', description: 'text', descriptionAr: 'text' });
productSchema.index({ categoryId: 1 });
productSchema.index({ createdAt: -1 });
productSchema.index({ favoritesCount: -1 });
productSchema.index({ viewsCount: -1 });
productSchema.index({ rating: -1 });


export const ProductModel: Model<ProductDocument> = mongoose.model<ProductDocument>('Product', productSchema);