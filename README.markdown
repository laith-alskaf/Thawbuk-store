# Thawbuk - ثوب

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-v18+-green)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5+-blue)](https://www.typescriptlang.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-brightgreen)](https://www.mongodb.com/)
[![Vercel](https://img.shields.io/badge/Vercel-Deployed-black)](https://vercel.com/)

**Thawbuk** (meaning "ثوب" or "robe" in Arabic) is an e-commerce platform designed for clothing, combining traditional and modern fashion styles. It offers a seamless shopping experience with support for Arabic and English languages, personalized product recommendations based on user preferences, and push notifications for tailored offers. Built with a modern tech stack, Thawbuk ensures scalability, performance, and ease of use for both customers and store administrators.

---

## 📋 Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## ✨ Features

### For Customers
- 🛍️ **Browse and Shop**: Explore a wide range of clothing for men, women, teens, and kids.
- 🌐 **Multilingual Support**: Switch between Arabic and English seamlessly.
- 🎯 **Personalized Recommendations**: Get clothing suggestions based on age, gender, marital status, and children's ages.
- 🔔 **Push Notifications**: Receive tailored offers and order updates via Firebase Cloud Messaging.
- 📍 **Delivery Address Management**: Save and update delivery addresses easily.

### For Admins
- 📦 **Product Management**: Add, update, or remove clothing items with details like sizes, colors, and age ranges.
- 🏢 **Company Branding**: Upload company logo and manage store details (powered by Cloudinary).
- 📊 **Order Tracking**: Monitor and manage customer orders efficiently.

---

## 🛠️ Tech Stack

- **Backend**:
  - Node.js with TypeScript
  - Express.js for API development
  - MongoDB (Atlas) for database
  - Mongoose for schema modeling
- **Frontend** (Optional):
  - Flutter for mobile app (Arabic/English support with RTL)
  - Next.js for web interface (optional)
- **Deployment**:
  - Vercel for serverless deployment
- **Storage**:
  - Cloudinary for image management (product images, company logos)
- **Notifications**:
  - Firebase Cloud Messaging (FCM) for push notifications
- **Localization**:
  - i18next for web or intl for Flutter to handle Arabic/English translations
- **Verification** (Planned):
  - Telegram Bot API for OTP verification
  - CallMeBot API for WhatsApp verification (testing phase)

---

## 🚀 Installation

### Prerequisites
- Node.js (v18 or higher)
- MongoDB Atlas account
- Vercel account
- Cloudinary account
- Firebase project for FCM
- Git installed

### Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/Thawbuk.git
   cd Thawbuk
   ```

2. **Install Dependencies**:
   ```bash
   npm install
   ```

3. **Set Up Environment Variables**:
   Create a `.env` file in the root directory and add the following:
   ```env
   MONGODB_URI=your-mongodb-atlas-uri
   CLOUDINARY_CLOUD_NAME=your-cloudinary-cloud-name
   CLOUDINARY_API_KEY=your-cloudinary-api-key
   CLOUDINARY_API_SECRET=your-cloudinary-api-secret
   FIREBASE_FCM_SERVER_KEY=your-fcm-server-key
   TELEGRAM_BOT_TOKEN=your-telegram-bot-token
   CALLMEBOT_API_KEY=your-callmebot-api-key
   PORT=3000
   ```

4. **Run the Application**:
   ```bash
   npm run dev
   ```
   The server will start at `http://localhost:3000`.

5. **Deploy to Vercel**:
   - Install Vercel CLI:
     ```bash
     npm install -g vercel
     ```
   - Deploy:
     ```bash
     vercel
     ```

---

## 📖 Usage

1. **Customer Flow**:
   - Sign up with an email and password.
   - Update your profile with optional details (age, gender, marital status, children's ages) to receive personalized recommendations.
   - Browse products, add to cart, and place orders.
   - Receive push notifications for new offers or order updates.

2. **Admin Flow**:
   - Sign up as an admin with company details (name, address, logo).
   - Manage products (add/edit/delete) via the admin dashboard.
   - Monitor orders and update their status.

3. **Localization**:
   - Switch between Arabic and English from the app settings.
   - Product names and descriptions are displayed in the selected language.

---

## 🌐 API Endpoints

Here are some key API endpoints (base URL: `http://your-vercel-app.vercel.app/api`):

- **User Management**:
  - `POST /api/register`: Register a new user (admin/customer).
  - `POST /api/login`: Log in and receive a JWT token.
  - `POST /api/update-language`: Update user language preference (ar/en).
- **Product Management**:
  - `GET /api/products`: Fetch products (filtered by user language).
  - `POST /api/products`: Add a new product (admin only).
- **Verification**:
  - `POST /api/send-verification`: Send OTP via WhatsApp or Telegram.
- **Image Upload**:
  - `POST /api/upload-image`: Upload product images or company logo to Cloudinary.

For detailed API documentation, check the `/docs` folder (TBD).

---

## 🤝 Contributing

We welcome contributions to Thawbuk! To contribute:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your feature"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/your-feature
   ```
5. Open a Pull Request.

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md) and check the [Contributing Guidelines](CONTRIBUTING.md).

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

For questions or feedback, reach out to:
- **Email**: your-email@example.com
- **GitHub Issues**: [Create an issue](https://github.com/your-username/Thawbuk/issues)

---

*Thawbuk - Where tradition meets modernity in fashion.*