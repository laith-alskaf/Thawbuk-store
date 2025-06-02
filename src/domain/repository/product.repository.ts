import { IProduct } from "../entity/product";

export interface ProductRepository {
    create(product: Partial<IProduct>): Promise<IProduct>;
    findById(id: string): Promise<IProduct | null>;
    findByCategoryId(categoryId: string): Promise<IProduct[] | null>;
    allProduct(page: number, limit: number, filter: {}): Promise<{ products: IProduct[], total: number } | null>;
    findByUserId(page: number, limit: number, filter: any): Promise<{ products: IProduct[], total: number } | null>;
    update(productId: string, productData: Partial<IProduct>): Promise<IProduct | null>;
    delete(id: string): Promise<void>;
}