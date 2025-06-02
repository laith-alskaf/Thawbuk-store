import mongoose, { Schema, Model, Document } from "mongoose";
import { IProduct } from "../../../../domain/entity/product";

type ProductDocument = IProduct & Document;

const productSchema = new Schema<ProductDocument>({
    _id: { type: String, default: () => crypto.randomUUID() },
    name: { type: String, required: true },
    price: { type: Number, required: true },
    description: { type: String },
    images: [{ type: String, match: [/^https?:\/\/.+/] }],
    sizes: [{ type: String }],
    colors: [{ type: String }],
    stock: { type: Number, default: 0 },
    brand: { type: String },
    ageRange: {
        minAge: { type: Number },
        maxAge: { type: Number },
    },
    categoryId: { type: String, ref: 'Category', required: true },
    createdBy: {
        type: String,
        ref: 'User',
        required: true,
    },
}, {
    timestamps: true,
});

productSchema.index({ title: 'text' });
productSchema.index({ categoryId: 1 });
productSchema.index({ createdAt: -1 });


export const ProductModel: Model<ProductDocument> = mongoose.model<ProductDocument>('Product', productSchema);