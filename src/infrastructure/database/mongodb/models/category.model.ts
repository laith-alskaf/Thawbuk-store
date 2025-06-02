import mongoose, { Schema, Model, Document } from "mongoose";
import { ICategory } from "../../../../domain/entity/category";
import { ProductModel } from "./product.model";

type CategoryDocument = ICategory & Document;

const categorySchema = new Schema<CategoryDocument>({
  _id: { type: String, default: () => crypto.randomUUID() },
  name: { type: String, required: true, unique: true },
  image: { type: String, default: "", required: true },
  description: { type: String, maxlength: 500 },
  createdBy: {
    type: String,
    ref: 'User',
    required: true,
  },
}, {
  timestamps: true,

});

categorySchema.pre('deleteOne', { document: true, query: false }, async function () {
  const categoryId = this.get('_id');
  await ProductModel.deleteMany({ categoryId });
});

categorySchema.pre('deleteOne', { document: false, query: true }, async function () {
  const filter = this.getFilter();
  const category = await CategoryModel.findOne(filter);
  if (category) {
    await ProductModel.deleteMany({ categoryId: category._id });
  }
});

export const CategoryModel: Model<CategoryDocument> = mongoose.model<CategoryDocument>('Category', categorySchema);