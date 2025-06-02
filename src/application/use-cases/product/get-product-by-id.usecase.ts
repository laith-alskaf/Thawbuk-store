import { ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { Messages } from "../../../presentation/config/constant";
import { ProductInfoDTO } from "../../dtos/product.dto";

export class GetProductByIdUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }
    execute = async (id: string): Promise<ProductInfoDTO | null> => {
        const product = await this.productRepository.findById(id);
        if (!product) throw new Error(Messages.PRODUCT.NOT_FOUND_PRODUCTS_EN);
        const productData: ProductInfoDTO = ProductMapper.toDTO(product);
        return productData;

    }
}