import { ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { Messages } from "../../../presentation/config/constant";
import { ProductInfoDTO } from "../../dtos/product.dto";

export class GetProductsByCategoryIdUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }
    execute = async (categoryId: string): Promise<ProductInfoDTO[] | null> => {
        const products = await this.productRepository.findByCategoryId(categoryId);
        if (!products) throw new Error(Messages.PRODUCT.NOT_FOUND_PRODUCTS);
        const productData: ProductInfoDTO[] = products.map(ProductMapper.toDTO);


        return productData;

    }
}