import { CategoryRepository } from "../../../domain/repository/category.repository";
import { CreateCategoryDTO } from "../../dtos/category.dto";
import { IdGeneratorService } from "../../../domain/services/id-generator.service";
import { Request } from "express";
import { BadRequestError } from "../../errors/application-error";
import { CloudService } from "../../../domain/services/cloud.service";
import { handlerExtractImage } from "../../../presentation/utils/handle-extract-image";

export class CreateCategoryUseCase {
    constructor(
        private readonly categoryRepository: CategoryRepository,
        private readonly uuidGeneratorService: IdGeneratorService,
        private readonly uploudImageService: CloudService,
    ) { }
    execute = async (createCategoryDTO: Partial<CreateCategoryDTO>, req: Request): Promise<void> => {
        const uuid = this.uuidGeneratorService.generate();
        const imageUrl = await handlerExtractImage({
            req: req,
            uuid: uuid,
            folderName: createCategoryDTO.createdBy!,
            userId: 'Categories',
            uploadToCloudinary: this.uploudImageService
        });

        if (!imageUrl) {
            new BadRequestError();
        }
        createCategoryDTO.image = imageUrl![0];
        const category = {
            ...createCategoryDTO,
            _id: uuid,
        }

        await this.categoryRepository.create(category);

    }
}