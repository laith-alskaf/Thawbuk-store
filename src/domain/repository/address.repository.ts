import { IAddress } from "../entity/address";
import { CreateAddressDTO, UpdateAddressDTO } from "../../application/dtos/address.dto";

export interface IAddressRepository {
  create(userId: string, addressData: CreateAddressDTO): Promise<IAddress>;
  findById(addressId: string): Promise<IAddress | null>;
  findByUserId(userId: string): Promise<IAddress[]>;
  findDefaultByUserId(userId: string): Promise<IAddress | null>;
  update(addressId: string, updateData: Partial<UpdateAddressDTO>): Promise<IAddress | null>;
  delete(addressId: string): Promise<boolean>;
  setAsDefault(userId: string, addressId: string): Promise<IAddress | null>;
}