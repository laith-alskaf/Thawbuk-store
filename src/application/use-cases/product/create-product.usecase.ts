import { IProduct, ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { IdGeneratorService } from "../../../domain/services/id-generator.service";
import { NotificationService } from "../../../domain/services/notification.service";
import { CreateProductDTO, ProductInfoDTO } from "../../dtos/product.dto";

export class CreateProductUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
        private readonly uuidGeneratorService: IdGeneratorService,
        private readonly newProductNotification: NotificationService,
    ) { }
    execute = async (productDTO: Partial<CreateProductDTO>): Promise<void> => {
        const product = {
            ...productDTO, 
            _id: this.uuidGeneratorService.generate(),
        }
        const newProduct: IProduct = await this.productRepository.create(product);
        if (newProduct) {
            const productData: ProductInfoDTO = ProductMapper.toDTO(newProduct);
            console.log(productData);
            await this.newProductNotification.send(productData);
            console.log('Notification sende successfuly');
        }

    }
}