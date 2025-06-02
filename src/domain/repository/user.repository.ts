import { IUser } from "../entity/user";

export interface UserRepository {
    create(user: Partial<IUser>): Promise<IUser>;
    findById(id: string): Promise<IUser | null>;
    findByEmail(email: string): Promise<IUser | null>;
    findByCode(verificationToken: string): Promise<IUser | null>;
    findByRole(role: string): Promise<IUser | null>;
    update(userId: string, userData: Partial<IUser>): Promise<IUser | null>;
    delete(id: string): Promise<void>;
}