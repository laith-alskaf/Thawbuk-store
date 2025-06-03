import { ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { ProductInfoDTO, SearchProductDTO } from "../../dtos/product.dto";

export class SearchProductsUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }
    execute = async (searchProductDTO: SearchProductDTO): Promise<{ productData: ProductInfoDTO[] | null, total: number }> => {
        const filter: any = {};
        filter.name = { $regex: searchProductDTO.name, $options: 'i' };
        if (searchProductDTO.categoryId != null) {
            filter.categoryId = searchProductDTO.categoryId;
        }
        if (searchProductDTO.createdId != null) {
            filter.createdBy = searchProductDTO.createdId;
        }
        const result = await this.productRepository.allProduct(
            searchProductDTO.peginationProduct.page,
            searchProductDTO.peginationProduct.limit,
            filter);
        if (!result) throw new Error("Product not found");
        const { products, total } = result;
        const productData: ProductInfoDTO[] = products.map(ProductMapper.toDTO);
        return { productData, total };

    }
}