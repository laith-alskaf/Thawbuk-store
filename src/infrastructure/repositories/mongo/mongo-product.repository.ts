import { IProduct } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { ProductModel } from "../../database/mongodb/models/product.model";

export class MongoProductRepository implements ProductRepository {

    async allProduct(page: number, limit: number, filter: {}): Promise<{ products: IProduct[], total: number } | null> {
        try {
            // التحقق من صحة المعاملات
            if (page < 1) page = 1;
            if (limit < 1) limit = 10;
            if (limit > 100) limit = 100; // حد أقصى للحماية من الاستعلامات الكبيرة

            const products = await ProductModel.find(filter)
                .sort({ createdAt: -1 })
                .skip((page - 1) * limit)
                .limit(limit)
                .exec();
            
            // استخدام نفس filter في countDocuments
            const total = await ProductModel.countDocuments(filter).exec();
            
            return { products, total };
        } catch (error) {
            console.error('Error in allProduct:', error);
            throw error;
        }
    }
    async findById(id: string): Promise<IProduct | null> {
        try {
            if (!id) {
                throw new Error('Product ID is required');
            }
            return await ProductModel.findById(id).exec();
        } catch (error) {
            console.error('Error in findById:', error);
            throw error;
        }
    }
    async create(product: Partial<IProduct>): Promise<IProduct> {
        try {
            if (!product.name || !product.price || !product.categoryId || !product.createdBy) {
                throw new Error('Required fields are missing: name, price, categoryId, createdBy');
            }
            
            const newProduct = new ProductModel(product);
            await newProduct.save();
            return newProduct;
        } catch (error) {
            console.error('Error in create:', error);
            throw error;
        }
    }
    async update(productId: string, productData: Partial<IProduct>): Promise<IProduct | null> {
        try {
            if (!productId) {
                throw new Error('Product ID is required');
            }
            
            // إضافة updatedAt timestamp
            const updateData = {
                ...productData,
                updatedAt: new Date()
            };
            
            return await ProductModel.findByIdAndUpdate(productId, updateData, { new: true }).exec();
        } catch (error) {
            console.error('Error in update:', error);
            throw error;
        }
    }

    async delete(id: string): Promise<void> {
        try {
            if (!id) {
                throw new Error('Product ID is required');
            }
            
            const result = await ProductModel.findByIdAndDelete(id).exec();
            if (!result) {
                throw new Error('Product not found');
            }
        } catch (error) {
            console.error('Error in delete:', error);
            throw error;
        }
    }

    async findByCategoryId(categoryId: string): Promise<IProduct[] | null> {
        try {
            if (!categoryId) {
                throw new Error('Category ID is required');
            }
            
            return await ProductModel.find({ 
                categoryId: categoryId,
                isActive: { $ne: false } // فقط المنتجات النشطة
            }).sort({ createdAt: -1 }).exec();
        } catch (error) {
            console.error('Error in findByCategoryId:', error);
            throw error;
        }
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
        try {
            // التحقق من صحة المعاملات
            if (page < 1) page = 1;
            if (limit < 1) limit = 10;
            if (limit > 100) limit = 100; // حد أقصى للحماية من الاستعلامات الكبيرة

            const products = await ProductModel.find(filter)
                .sort({ createdAt: -1 })
                .skip((page - 1) * limit)
                .limit(limit)
                .exec();
            
            // استخدام نفس filter في countDocuments - هذا هو الإصلاح الرئيسي
            const total = await ProductModel.countDocuments(filter).exec();
            
            return { products, total };
        } catch (error) {
            console.error('Error in findByUserId:', error);
            throw error;
        }
    }

    async incrementFavoritesCount(productId: string): Promise<void> {
        await ProductModel.findByIdAndUpdate(productId, { $inc: { favoritesCount: 1 } }).exec();
    }

    async decrementFavoritesCount(productId: string): Promise<void> {
        await ProductModel.findByIdAndUpdate(productId, { $inc: { favoritesCount: -1 } }).exec();
    }
}
