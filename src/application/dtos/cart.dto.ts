export interface AddItemToCartDTO {
  productId: string;
  quantity: number;
  selectedSize?: string;
  selectedColor?: string;
}

export interface UpdateCartItemDTO {
  productId: string;
  quantity: number;
  selectedSize?: string;
  selectedColor?: string;
}

export interface RemoveFromCartDTO {
  productId: string;
}

export interface CartInfoDTO {
  _id: string;
  userId: string;
  items: {
    productId: string;
    quantity: number;
    selectedSize?: string;
    selectedColor?: string;
    product?: {
      _id: string;
      name: string;
      price: number;
      images: string[];
    };
  }[];
  totalAmount: number;
  totalItems: number;
}