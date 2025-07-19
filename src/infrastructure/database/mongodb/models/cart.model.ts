import mongoose, { Schema, Model, Document } from "mongoose";
import { ICart, ICartItem } from "../../../../domain/entity/cart";

type CartDocument = ICart & Document;

const cartItemSchema = new Schema<ICartItem>({
    productId: { type: String, ref: 'Product', required: true },
    quantity: { type: Number, required: true, min: 1 },
    selectedSize: { type: String },
    selectedColor: { type: String }
}, { _id: false });

const cartSchema = new Schema<CartDocument>({
    _id: { type: String, default: () => crypto.randomUUID() },
    userId: { 
        type: String, 
        ref: 'User', 
        required: true, 
        unique: true,
        index: true 
    },
    items: [cartItemSchema],
    totalAmount: { type: Number, default: 0, min: 0 }
}, { timestamps: true });

// حساب المبلغ الإجمالي قبل الحفظ
cartSchema.pre('save', async function(next) {
    if (this.isModified('items')) {
        const ProductModel = mongoose.model('Product');
        let total = 0;
        
        for (const item of this.items) {
            const product = await ProductModel.findById(item.productId);
            if (product) {
                total += product.price * item.quantity;
            }
        }
        
        this.totalAmount = total;
    }
    next();
});

export const CartModel: Model<CartDocument> = mongoose.model<CartDocument>('Cart', cartSchema);