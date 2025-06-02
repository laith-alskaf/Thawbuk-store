import { ProductRepository } from "../../../domain/repository/product.repository";
import { DeleteProductDTO } from "../../dtos/product.dto";

export class DeleteProductUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }
    execute = async (deleteProductDTO: DeleteProductDTO): Promise<void> => {
        await this.productRepository.delete(deleteProductDTO.productId);
    }
}