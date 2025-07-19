export interface CreateAddressDTO {
  street: string;
  city: string;
  country: string;
  postalCode?: string;
  phone?: string;
  isDefault?: boolean;
}

export interface UpdateAddressDTO {
  addressId: string;
  street?: string;
  city?: string;
  country?: string;
  postalCode?: string;
  phone?: string;
  isDefault?: boolean;
}

export interface DeleteAddressDTO {
  addressId: string;
}

export interface AddressInfoDTO {
  _id: string;
  userId: string;
  street: string;
  city: string;
  country: string;
  postalCode?: string;
  phone?: string;
  isDefault: boolean;
}