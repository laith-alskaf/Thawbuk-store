export interface CreateProductDTO {
    title: string,
    stockQuantity: number,
    description: string,
    price: number,
    categoryId: string,
    createdBy: string,
    images: [type: string] | null;
}


export interface UpdateProductDTO {
    productId: string,
    product: ProductInfoDTO,
    updatedAt: Date
}
export interface ProductInfoDTO {
    _id: string,
    title: string,
    stockQuantity: number,
    description: string,
    price: number,
    categoryId: string,
    images: [type: string] | null;
}
export interface PeginationProductDTO {
    limit: number | 10,
    page: number | 1,
}

export interface SearchProductDTO {
    peginationProduct: PeginationProductDTO,
    title: string,
    categoryId: string | null,
    createdId: string | null,
}

export interface GetProductsByUserIdDTO {
    peginationProduct: PeginationProductDTO,
    filter: { createdBy: string }
}
export interface DeleteProductDTO {
    productId: string
}



