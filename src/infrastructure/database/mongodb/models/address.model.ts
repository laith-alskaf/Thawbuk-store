import mongoose, { Schema, Model, Document } from "mongoose";
import { IAddress } from "../../../../domain/entity/address";

type AddressDocument = IAddress & Document;

const addressSchema = new Schema<AddressDocument>({
    _id: { type: String, default: () => crypto.randomUUID() },
    userId: { 
        type: String, 
        ref: 'User', 
        required: true,
        index: true 
    },
    street: { type: String, required: true, trim: true },
    city: { type: String, required: true, trim: true },
    country: { type: String, required: true, trim: true },
    postalCode: { type: String, trim: true },
    phone: { type: String, trim: true },
    isDefault: { type: Boolean, default: false }
}, { timestamps: true });

// التأكد من وجود عنوان افتراضي واحد فقط لكل مستخدم
addressSchema.pre('save', async function(next) {
    if (this.isDefault) {
        await AddressModel.updateMany(
            { userId: this.userId, _id: { $ne: this._id } },
            { isDefault: false }
        );
    }
    next();
});

export const AddressModel: Model<AddressDocument> = mongoose.model<AddressDocument>('Address', addressSchema);