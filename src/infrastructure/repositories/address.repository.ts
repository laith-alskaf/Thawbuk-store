import { IAddressRepository } from "../../domain/repository/address.repository";
import { IAddress } from "../../domain/entity/address";
import { CreateAddressDTO, UpdateAddressDTO } from "../../application/dtos/address.dto";
import { AddressModel } from "../database/mongodb/models/address.model";

export class AddressRepository implements IAddressRepository {
  async create(userId: string, addressData: CreateAddressDTO): Promise<IAddress> {
    const newAddress = new AddressModel({
      ...addressData,
      userId
    });
    await newAddress.save();
    return newAddress.toObject();
  }

  async findById(addressId: string): Promise<IAddress | null> {
    const address = await AddressModel.findById(addressId).lean();
    return address;
  }

  async findByUserId(userId: string): Promise<IAddress[]> {
    const addresses = await AddressModel.find({ userId }).sort({ isDefault: -1, createdAt: -1 }).lean();
    return addresses;
  }

  async findDefaultByUserId(userId: string): Promise<IAddress | null> {
    const address = await AddressModel.findOne({ userId, isDefault: true }).lean();
    return address;
  }

  async update(addressId: string, updateData: Partial<UpdateAddressDTO>): Promise<IAddress | null> {
    const updatedAddress = await AddressModel.findByIdAndUpdate(
      addressId,
      { $set: updateData },
      { new: true, runValidators: true }
    ).lean();
    return updatedAddress;
  }

  async delete(addressId: string): Promise<boolean> {
    const result = await AddressModel.deleteOne({ _id: addressId });
    return result.deletedCount > 0;
  }

  async setAsDefault(userId: string, addressId: string): Promise<IAddress | null> {
    // إزالة الافتراضي من العناوين الأخرى
    await AddressModel.updateMany(
      { userId, _id: { $ne: addressId } },
      { $set: { isDefault: false } }
    );

    // تعيين العنوان المحدد كافتراضي
    const updatedAddress = await AddressModel.findByIdAndUpdate(
      addressId,
      { $set: { isDefault: true } },
      { new: true }
    ).lean();

    return updatedAddress;
  }
}