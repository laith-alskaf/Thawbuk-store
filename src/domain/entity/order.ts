export interface IOrderItem {
  productId: string;
  quantity: number;
  price: number;
  selectedSize?: string;
  selectedColor?: string;
}

export interface IOrder {
  _id: string;
  userId: string;
  items: IOrderItem[];
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