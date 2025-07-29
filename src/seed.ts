import Database from './infrastructure/database/mongodb';
import { ProductModel } from './infrastructure/database/mongodb/models/product.model';
import { CategoryModel } from './infrastructure/database/mongodb/models/category.model';
import { UserModel } from './infrastructure/database/mongodb/models/user.model';
import mongoose from 'mongoose';
import bcrypt from 'bcrypt';

async function seedDatabase() {
  try {
    const db = Database.getInstance();
    await db.connect();

    console.log('Clearing existing data...');
    await ProductModel.deleteMany({});
    await CategoryModel.deleteMany({});
    await UserModel.deleteMany({});
    console.log('Data cleared.');

    console.log('Seeding user...');
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('password123', salt);

    const adminUser = await UserModel.create({
      email: 'admin@example.com',
      password: hashedPassword,
      name: 'Admin User',
      role: 'admin',
      companyDetails: {
        companyName: 'Thawbuk',
        companyAddress: {
            city: 'Damascus',
        }
      },
      isEmailVerified: true,
    });
    console.log('User seeded.');

    const userId = adminUser._id;

    const categories = [
      { name: 'أحذية رجالية', description: 'أفضل الأحذية الرجالية', image: 'https://via.placeholder.com/150', createdBy: userId },
      { name: 'أحذية نسائية', description: 'أفضل الأحذية النسائية', image: 'https://via.placeholder.com/150', createdBy: userId },
      { name: 'ملابس رجالية', description: 'أفضل الملابس الرجالية', image: 'https://via.placeholder.com/150', createdBy: userId },
      { name: 'ملابس نسائية', description: 'أفضل الملابس النسائية', image: 'https://via.placeholder.com/150', createdBy: userId },
    ];

    console.log('Seeding categories...');
    const createdCategories = await CategoryModel.insertMany(categories);
    console.log('Categories seeded.');

    const categoryMap = new Map(createdCategories.map(cat => [cat.name, cat._id]));

    const products = [
      // Men's Shoes
      { name: 'حذاء رياضي للجري', description: 'حذاء رياضي مريح للجري والتمارين', price: 120, stock: 50, images: ['https://via.placeholder.com/150'], categoryName: 'أحذية رجالية', createdBy: userId },
      { name: 'حذاء رسمي جلد', description: 'حذاء جلد أنيق للمناسبات الرسمية', price: 250, stock: 30, images: ['https://via.placeholder.com/150'], categoryName: 'أحذية رجالية', createdBy: userId },
      { name: 'صندل صيفي', description: 'صندل خفيف ومريح للصيف', price: 80, stock: 100, images: ['https://via.placeholder.com/150'], categoryName: 'أحذية رجالية', createdBy: userId },

      // Women's Shoes
      { name: 'حذاء بكعب عالي', description: 'حذاء أنيق بكعب عالي للسهرات', price: 180, stock: 40, images: ['https://via.placeholder.com/150'], categoryName: 'أحذية نسائية', createdBy: userId },
      { name: 'حذاء رياضي نسائي', description: 'حذاء رياضي نسائي مريح وأنيق', price: 130, stock: 60, images: ['https://via.placeholder.com/150'], categoryName: 'أحذية نسائية', createdBy: userId },
      { name: 'بوت شتوي', description: 'بوت دافئ وأنيق لفصل الشتاء', price: 220, stock: 25, images: ['https://via.placeholder.com/150'], categoryName: 'أحذية نسائية', createdBy: userId },

      // Men's Clothing
      { name: 'قميص قطن', description: 'قميص قطني مريح للاستخدام اليومي', price: 90, stock: 80, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس رجالية', createdBy: userId },
      { name: 'بنطلون جينز', description: 'بنطلون جينز بتصميم عصري', price: 150, stock: 70, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس رجالية', createdBy: userId },
      { name: 'جاكيت شتوي', description: 'جاكيت دافئ للشتاء القارس', price: 300, stock: 35, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس رجالية', createdBy: userId },
      { name: 'تيشيرت رياضي', description: 'تيشيرت رياضي بتقنية طرد العرق', price: 70, stock: 120, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس رجالية', createdBy: userId },

      // Women's Clothing
      { name: 'فستان سهرة', description: 'فستان سهرة طويل وأنيق', price: 400, stock: 20, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس نسائية', createdBy: userId },
      { name: 'بلوزة صيفية', description: 'بلوزة خفيفة ومريحة للصيف', price: 110, stock: 90, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس نسائية', createdBy: userId },
      { name: 'تنورة قصيرة', description: 'تنورة قصيرة بتصميم جذاب', price: 100, stock: 75, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس نسائية', createdBy: userId },
      { name: 'معطف طويل', description: 'معطف طويل وأنيق لفصل الشتاء', price: 350, stock: 30, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس نسائية', createdBy: userId },
      { name: 'ليقنز رياضي', description: 'ليقنز رياضي مريح للتمارين', price: 85, stock: 110, images: ['https://via.placeholder.com/150'], categoryName: 'ملابس نسائية', createdBy: userId },
    ];

    const productsWithCategoryIds = products.map(product => {
      const { categoryName, ...rest } = product;
      return {
        ...rest,
        categoryId: categoryMap.get(categoryName),
      };
    });

    console.log('Seeding products...');
    await ProductModel.insertMany(productsWithCategoryIds);
    console.log('Products seeded.');

    console.log('Database seeding completed successfully.');
  } catch (error) {
    console.error('Error seeding database:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB.');
  }
}

seedDatabase();
