import { ProductInfoDTO } from "../../dtos/product.dto";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { GetFilteredProductsParams } from "../../dtos/product-filter.dto";

export class GetFilteredProductsUseCase {
    constructor(private productRepository: ProductRepository) { }

    async execute(params: GetFilteredProductsParams): Promise<ProductInfoDTO[]> {
        return await this.productRepository.filter(params);
    }
}
