export interface CreateOrderDTO {
  items: {
    productId: string;
    quantity: number;
    selectedSize?: string;
    selectedColor?: string;
  }[];
  shippingAddress: {
    street: string;
    city: string;
    country: string;
    postalCode?: string;
    phone?: string;
  };
  paymentMethod: 'cash' | 'card' | 'online';
  notes?: string;
}

export interface UpdateOrderStatusDTO {
  orderId: string;
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled';
}

export interface UpdatePaymentStatusDTO {
  orderId: string;
  paymentStatus: 'pending' | 'paid' | 'failed';
}

export interface OrderInfoDTO {
  _id: string;
  userId: string;
  items: {
    productId: string;
    quantity: number;
    price: number;
    selectedSize?: string;
    selectedColor?: string;
    product?: {
      _id: string;
      name: string;
      images: string[];
    };
  }[];
  totalAmount: number;
  shippingAddress: {
    street: string;
    city: string;
    country: string;
    postalCode?: string;
    phone?: string;
  };
  status: 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled';
  paymentMethod: 'cash' | 'card' | 'online';
  paymentStatus: 'pending' | 'paid' | 'failed';
  orderNumber: string;
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface PaginationOrderDTO {
  page: number;
  limit: number;
}

export interface OrderFilterDTO {
  status?: 'pending' | 'confirmed' | 'shipped' | 'delivered' | 'cancelled';
  paymentStatus?: 'pending' | 'paid' | 'failed';
  userId?: string;
}