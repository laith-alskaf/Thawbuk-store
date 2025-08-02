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

    async filter(params: any): Promise<IProduct[]> {
        const query: any = {};

        if (params.category) {
            query.categoryId = params.category;
        }

        if (params.searchQuery) {
            query.$or = [
                { name: { $regex: params.searchQuery, $options: 'i' } },
                { description: { $regex: params.searchQuery, $options: 'i' } },
            ];
        }

        if (params.sizes && params.sizes.length > 0) {
            query.sizes = { $in: params.sizes };
        }

        if (params.colors && params.colors.length > 0) {
            query.colors = { $in: params.colors };
        }

        if (params.minPrice || params.maxPrice) {
            query.price = {};
            if (params.minPrice) {
                query.price.$gte = params.minPrice;
            }
            if (params.maxPrice) {
                query.price.$lte = params.maxPrice;
            }
        }

        let sort: any = {};
        if (params.sortBy) {
            switch (params.sortBy) {
                case 'newest':
                    sort.createdAt = -1;
                    break;
                case 'oldest':
                    sort.createdAt = 1;
                    break;
                case 'priceAsc':
                    sort.price = 1;
                    break;
                case 'priceDesc':
                    sort.price = -1;
                    break;
                case 'rating':
                    sort.rating = -1;
                    break;
            }
        }

        return await ProductModel.find(query).sort(sort).exec();
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
