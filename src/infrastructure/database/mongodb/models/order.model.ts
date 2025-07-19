import mongoose, { Schema, Model, Document } from "mongoose";
import { IOrder, IOrderItem } from "../../../../domain/entity/order";

type OrderDocument = IOrder & Document;

const orderItemSchema = new Schema<IOrderItem>({
    productId: { type: String, ref: 'Product', required: true },
    quantity: { type: Number, required: true, min: 1 },
    price: { type: Number, required: true, min: 0 },
    selectedSize: { type: String },
    selectedColor: { type: String }
}, { _id: false });

const shippingAddressSchema = new Schema({
    street: { type: String, required: true },
    city: { type: String, required: true },
    country: { type: String, required: true },
    postalCode: { type: String },
    phone: { type: String }
}, { _id: false });

const orderSchema = new Schema<OrderDocument>({
    _id: { type: String, default: () => crypto.randomUUID() },
    userId: { 
        type: String, 
        ref: 'User', 
        required: true,
        index: true 
    },
    items: [orderItemSchema],
    totalAmount: { type: Number, required: true, min: 0 },
    shippingAddress: shippingAddressSchema,
    status: { 
        type: String, 
        enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
        default: 'pending',
        index: true
    },
    paymentMethod: { 
        type: String, 
        enum: ['cash', 'card', 'online'],
        required: true
    },
    paymentStatus: { 
        type: String, 
        enum: ['pending', 'paid', 'failed'],
        default: 'pending',
        index: true
    },
    orderNumber: { 
        type: String, 
        required: true, 
        unique: true,
        index: true
    },
    notes: { type: String, trim: true }
}, { timestamps: true });

// إنشاء رقم الطلب قبل الحفظ
orderSchema.pre('save', function(next) {
    if (this.isNew && !this.orderNumber) {
        const timestamp = Date.now().toString();
        const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
        this.orderNumber = `ORD${timestamp}${random}`;
    }
    next();
});

export const OrderModel: Model<OrderDocument> = mongoose.model<OrderDocument>('Order', orderSchema);