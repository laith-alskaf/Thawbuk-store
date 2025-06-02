import { IProduct } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { ProductModel } from "../../database/mongodb/models/product.model";

export class MongoProductRepository implements ProductRepository {

    async allProduct(page: number, limit: number, filter: {}): Promise<{ products: IProduct[], total: number } | null> {
        const products = await ProductModel.find(filter)
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(limit);
        const total = await ProductModel.countDocuments().exec();
        return { products, total };

    }
    async findById(id: string): Promise<IProduct | null> {
        return await ProductModel.findById(id).exec();
    }
    async create(product: Partial<IProduct>): Promise<IProduct> {
        const newProduct = new ProductModel(product);
        await newProduct.save();
        return newProduct;
    }
    async update(productId: string, productData: Partial<IProduct>): Promise<IProduct | null> {
        return await ProductModel.findByIdAndUpdate(productId, productData, { new: true }).exec();
    }

    async delete(id: string): Promise<void> {
        await ProductModel.findByIdAndDelete(id).exec();
    }

    async findByCategoryId(categoryId: string): Promise<IProduct[] | null> {
        return await ProductModel.find({ categoryId: categoryId }).exec();
    }


    async findByUserId(page: number, limit: number, filter: any): Promise<{ products: IProduct[], total: number } | null> {
        const products = await ProductModel.find(filter)
            .sort({ createdAt: -1 })
            .skip((page - 1) * limit)
            .limit(limit).exec();
        const total = await ProductModel.countDocuments().exec();
        return { products, total };

    }
}
