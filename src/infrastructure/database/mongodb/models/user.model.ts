import mongoose, { Schema, Model, Document } from "mongoose";
import { IUser } from "../../../../domain/entity/user";

type UserDocument = IUser & Document;

const userSchema = new Schema<UserDocument>({
    _id: { type: String, default: () => crypto.randomUUID() },
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        match: [/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/, 'Invalid email format']
    },
    password: { type: String, required: true },
    name: { type: String, trim: true },
    role: {
        type: String,
        enum: ['admin', 'customer', 'superAdmin'],
        default: 'customer'
    },
    companyDetails: {
        companyName: { 
            type: String, 
            unique: true, 
            sparse: true, // This allows multiple null values
            required: function () { return this.role === 'admin'; } 
        },
        companyDescription: { type: String },
        companyAddress: {
            street: { type: String },
            city: { type: String , required: function () { return this.role === 'admin'; }},
            country: { type: String },
        },
        companyPhone: { type: String },
        companyLogo: { type: String, match: [/^https?:\/\/.+/] },
    },
    address: {
        street: { type: String },
        city: { type: String, required: function () { return this.role === 'customer'; } },
    },
    children: [{
        age: { type: Number, min: 0, max: 18 },
        gender: { type: String, enum: ['male', 'female'] },
    }],
    age: { type: Number, min: 18, max: 120 },
    gender: { type: String, enum: ['male', 'female', 'other'], default: null },
    lastLogin: {
        type: Date,
        default: Date.now,
    },
    fcmToken: { type: String, default: null },
    isEmailVerified: {
        type: Boolean,
        default: false,
    },
    otpCode: { type: String, default: "" },
    otpCodeExpires: { type: Date, },
}, { timestamps: true },);

export const UserModel: Model<UserDocument> = mongoose.model<UserDocument>('User', userSchema);