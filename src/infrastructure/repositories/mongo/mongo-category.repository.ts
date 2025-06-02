import { ICategory } from "../../../domain/entity/category";
import { CategoryRepository } from "../../../domain/repository/category.repository";
import { CategoryModel } from "../../database/mongodb/models/category.model";

export class MongoCategoryRepository implements CategoryRepository {


    async allCategory(): Promise<ICategory[] | null> {
        return await CategoryModel.find({});
    }

    async create(category: Partial<ICategory>): Promise<void> {
        const newCategory = new CategoryModel(category);
        await newCategory.save();
    }

    async delete(id: string): Promise<void> {
        await CategoryModel.deleteOne({ _id: id });
    }

    async update(id: string, category: Partial<ICategory>): Promise<ICategory | null> {
        return await CategoryModel.findByIdAndUpdate(id, category, { new: true });
    }

    async findById(id: string): Promise<ICategory | null> {
        return await CategoryModel.findById(id);
    }
}
