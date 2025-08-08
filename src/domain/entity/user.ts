export interface IAddress {
  street: string;
  city: string;
}

export interface ISocialLinks {
  facebook?: string;
  instagram?: string;
  whatsapp?: string;
}

export interface ICompanyDetails {
  companyName: string;
  companyDescription?: string;
  companyAddress: IAddress;
  companyPhone: string;
  companyLogo?: string;
  socialLinks?: ISocialLinks;
}

export interface IChild {
  age: number;
  gender: 'male' | 'female';
}

export interface IUser {
  _id: string,
  email: string;
  password: string;
  role: 'admin' | 'customer' | 'superAdmin';
  age?: number;
  gender?: 'male' | 'female' | 'other';
  name: string;
  children?: IChild[];
  companyDetails?: ICompanyDetails;
  address?: IAddress;
  fcmToken?: string;
  isEmailVerified: boolean;
  lastLogin: Date;
  otpCode: string;
  otpCodeExpires: Date;
  createdAt: Date;
  updatedAt: Date;
}

