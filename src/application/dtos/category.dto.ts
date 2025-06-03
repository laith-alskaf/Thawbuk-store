export interface CreateCategoryDTO {
    name: string,
    description: string,
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
    image: string
    description: string | null,
}


export interface DeleteCategoryDTO {
    categoryId: string
}



