import { Request } from "express";
import { IProduct, ProductMapper } from "../../../domain/entity/product";
import { ProductRepository } from "../../../domain/repository/product.repository";
import { CloudService } from "../../../domain/services/cloud.service";
import { IdGeneratorService } from "../../../domain/services/id-generator.service";
import { NotificationService } from "../../../domain/services/notification.service";
import { CreateProductDTO, ProductInfoDTO } from "../../dtos/product.dto";
import { BadRequestError } from "../../errors/application-error";
import { Messages } from "../../../presentation/config/constant";
import { handlerExtractImage } from "../../../presentation/utils/handle-extract-image";

export class CreateProductUseCase {
    constructor(
        private readonly productRepository: ProductRepository,
        private readonly uuidGeneratorService: IdGeneratorService,
        private readonly newProductNotification: NotificationService,
        private readonly uploudImageService: CloudService,
    ) { }
    execute = async (productDTO: Partial<CreateProductDTO>, req: Request): Promise<void> => {
        const existing = await this.productRepository.allProduct(1, 1, { name: productDTO.name });
        if (existing) {
            new BadRequestError('Product name already exist');
        }
        const uuid = this.uuidGeneratorService.generate()
        const product = {
            ...productDTO,
            _id: uuid,
        }
        const urlsImages = await handlerExtractImage({
            req: req,
            uuid: uuid,
            folderName: product.createdBy!,
            userId: 'products',
            uploadToCloudinary: this.uploudImageService
        });

        if (!urlsImages || urlsImages.length === 0) {
            new BadRequestError(Messages.PRODUCT.VALIDATION.PRODUCT_VALIDATION.IMAGE_URI_INVALID_EN);
            return;
        }
        product.images = urlsImages;
        const newProduct: IProduct = await this.productRepository.create(product);
        if (newProduct) {
            const productData: ProductInfoDTO = ProductMapper.toDTO(newProduct);
            console.log(productData);
            await this.newProductNotification.send(productData);
            console.log('Notification sende successfuly');
        }

    }
}