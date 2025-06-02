import { ICategory } from "../entity/category";

export interface CategoryRepository {
    allCategory(): Promise<ICategory[] | null>;
    create(category: Partial<ICategory>): Promise<void>;
    delete(id: string): Promise<void>;
    update(id: string, category: Partial<ICategory>): Promise<ICategory | null>;
    findById(id: string): Promise<ICategory | null>;
}