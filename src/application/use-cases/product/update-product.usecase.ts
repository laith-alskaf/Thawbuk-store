import { ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { ProductInfoDTO, UpdateProductDTO } from "../../dtos/product.dto";

export class UpdatedProductUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }
    execute = async (updateProductDTO: Partial<UpdateProductDTO>): Promise<ProductInfoDTO | null> => {
        updateProductDTO.updatedAt = new Date();

        const product = await this.productRepository.update(
            updateProductDTO.productId!,
            updateProductDTO.product!
        );
        if (!product) throw new Error("Please, try again after 1m");
        const productData: ProductInfoDTO = ProductMapper.toDTO(product);

        return productData;

    }
}