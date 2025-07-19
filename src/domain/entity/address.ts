export interface IAddress {
  _id: string;
  userId: string;
  street: string;
  city: string;
  country: string;
  postalCode?: string;
  phone?: string;
  isDefault: boolean;
  createdAt: Date;
  updatedAt: Date;
}