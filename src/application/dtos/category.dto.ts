export interface CreateCategoryDTO {
    name: string,
    description: string,
    createdBy: string,
}


export interface UpdateCategoryDTO {
    categoryId: string,
    category: CategoryInfoDTO,
    updatedAt: Date
}
export interface CategoryInfoDTO {
    _id: string,
    name: string,
    description: string | null,
}


export interface DeleteCategoryDTO {
    categoryId: string
}



