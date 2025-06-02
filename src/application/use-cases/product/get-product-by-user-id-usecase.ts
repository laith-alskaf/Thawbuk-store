import { ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { Messages } from "../../../presentation/config/constant";
import { GetProductsByUserIdDTO, ProductInfoDTO } from "../../dtos/product.dto";

export class GetProductsByUserIdUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
    ) { }
    execute = async (getProductsByUserIdDTO: GetProductsByUserIdDTO): Promise<{ productData: ProductInfoDTO[], total: number }> => {
        console.log(getProductsByUserIdDTO.filter);
        const result = await this.productRepository.findByUserId(
            getProductsByUserIdDTO.peginationProduct.page,
            getProductsByUserIdDTO.peginationProduct.limit,
            getProductsByUserIdDTO.filter);

        if (!result) throw new Error(Messages.PRODUCT.NOT_FOUND_PRODUCTS);

        const { products, total } = result;

        const productData: ProductInfoDTO[] = products.map(ProductMapper.toDTO);

        return { productData, total };

    }
}