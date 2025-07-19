import { IOrderRepository } from "../../domain/repository/order.repository";
import { IOrder } from "../../domain/entity/order";
import { CreateOrderDTO, OrderFilterDTO, PaginationOrderDTO } from "../../application/dtos/order.dto";
import { OrderModel } from "../database/mongodb/models/order.model";
import { ProductModel } from "../database/mongodb/models/product.model";

export class OrderRepository implements IOrderRepository {
  async create(userId: string, orderData: CreateOrderDTO): Promise<IOrder> {
    // حساب الأسعار من المنتجات الحالية
    const itemsWithPrices = await Promise.all(
      orderData.items.map(async (item) => {
        const product = await ProductModel.findById(item.productId);
        if (!product) {
          throw new Error(`Product not found: ${item.productId}`);
        }
        return {
          ...item,
          price: product.price
        };
      })
    );

    const totalAmount = itemsWithPrices.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    const newOrder = new OrderModel({
      userId,
      items: itemsWithPrices,
      totalAmount,
      shippingAddress: orderData.shippingAddress,
      paymentMethod: orderData.paymentMethod,
      notes: orderData.notes
    });

    await newOrder.save();
    return newOrder.toObject();
  }

  async findById(orderId: string): Promise<IOrder | null> {
    const order = await OrderModel.findById(orderId)
      .populate('items.productId', 'name images')
      .lean();
    return order;
  }

  async findByUserId(userId: string, pagination: PaginationOrderDTO): Promise<{ orders: IOrder[], total: number }> {
    const skip = (pagination.page - 1) * pagination.limit;
    
    const [orders, total] = await Promise.all([
      OrderModel.find({ userId })
        .populate('items.productId', 'name images')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(pagination.limit)
        .lean(),
      OrderModel.countDocuments({ userId })
    ]);

    return { orders, total };
  }

  async findAll(pagination: PaginationOrderDTO, filter?: OrderFilterDTO): Promise<{ orders: IOrder[], total: number }> {
    const skip = (pagination.page - 1) * pagination.limit;
    const query: any = {};

    if (filter?.status) query.status = filter.status;
    if (filter?.paymentStatus) query.paymentStatus = filter.paymentStatus;
    if (filter?.userId) query.userId = filter.userId;

    const [orders, total] = await Promise.all([
      OrderModel.find(query)
        .populate('items.productId', 'name images')
        .populate('userId', 'name email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(pagination.limit)
        .lean(),
      OrderModel.countDocuments(query)
    ]);

    return { orders, total };
  }

  async updateStatus(orderId: string, status: IOrder['status']): Promise<IOrder | null> {
    const updatedOrder = await OrderModel.findByIdAndUpdate(
      orderId,
      { $set: { status } },
      { new: true }
    ).lean();
    return updatedOrder;
  }

  async updatePaymentStatus(orderId: string, paymentStatus: IOrder['paymentStatus']): Promise<IOrder | null> {
    const updatedOrder = await OrderModel.findByIdAndUpdate(
      orderId,
      { $set: { paymentStatus } },
      { new: true }
    ).lean();
    return updatedOrder;
  }

  async findByOrderNumber(orderNumber: string): Promise<IOrder | null> {
    const order = await OrderModel.findOne({ orderNumber })
      .populate('items.productId', 'name images')
      .lean();
    return order;
  }

  async delete(orderId: string): Promise<boolean> {
    const result = await OrderModel.deleteOne({ _id: orderId });
    return result.deletedCount > 0;
  }
}