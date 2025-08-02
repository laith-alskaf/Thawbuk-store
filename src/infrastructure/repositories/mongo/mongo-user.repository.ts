import { IUser } from '../../../domain/entity/user';
import { UserRepository } from '../../../domain/repository/user.repository';
import { UserModel } from '../../database/mongodb/models/user.model';
import { WishlistModel } from '../../database/mongodb/models/wishlist.model';

export class MongoUserRepository implements UserRepository {


  async create(user: Partial<IUser>): Promise<IUser> {
    const newUser = new UserModel(user);
    const savedUser = await newUser.save();
    return savedUser;
  }

  findById = async (id: string): Promise<IUser | null> => {
    return await UserModel.findOne({ _id: id }).exec()
  }

  findByEmail = async (email: string): Promise<IUser | null> => {
    return await UserModel.findOne({ email }).exec();

  }

  findByCode = async (code: string): Promise<IUser | null> => {
    return await UserModel.findOne({ otpCode: code }).exec()
  }

  update = async (userId: string, userData: Partial<IUser>): Promise<IUser | null> => {
    return await UserModel.findByIdAndUpdate(userId, { $set: userData }, { new: true }).exec();
  }

  delete = async (id: string): Promise<void> => {
    await UserModel.findByIdAndDelete(id).exec();
  }
  findByRole = async (role: string): Promise<IUser | null> => {
    return await UserModel.findOne({ role: role }).exec();
  }
}