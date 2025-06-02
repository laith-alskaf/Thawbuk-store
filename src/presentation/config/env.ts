import dotenv from "dotenv";

dotenv.config();

export const CONFIG = {
    DEV_MONGODB_URI: process.env.MONGODB_URI!,
    PORT: process.env.PORT || 8080,
    CLIENT_URL: process.env.CLIENT_URL || "http://localhost:8080",
    SERVER_URL: process.env.SERVER_URL || "http://localhost:8080",
    JWT_SECRET_ACCESS_TOKEN: process.env.JWT_SECRET || "",
    GMAIL_USER: process.env.GMAIL_USER,
    GMAIL_PASS: process.env.GMAIL_PASS,


    POSTGRES_USER: process.env.POSTGRES_USER,
    POSTGRES_HOST: process.env.POSTGRES_URL,
    POSTGRES_PASSWORD: process.env.POSTGRES_PASSWORD,
    POSTGRES_DATABASE: process.env.POSTGRES_DATABASE,
    POSTGRES_PORT: process.env.POSTGRES_PORT || 5432,

    SALT_ROUNDS_BCRYPT: 10
};
