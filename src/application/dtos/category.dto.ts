export interface CreateCategoryDTO {
    name: string,
    nameAr: string,
    description: string,
    descriptionAr: string,
    createdBy: string,
    image?: string
}


export interface UpdateCategoryDTO {
    categoryId: string,
    category: CategoryInfoDTO,
    updatedAt: Date
}
export interface CategoryInfoDTO {
    _id: string,
    name: string,
    nameAr: string,
    image: string,
    description: string | null,
    descriptionAr: string | null,
    productsCount?: number,
}


export interface DeleteCategoryDTO {
    categoryId: string
}
