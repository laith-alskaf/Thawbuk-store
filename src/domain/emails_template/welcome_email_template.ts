export const WELCOME_EMAIL_TEMPLATE = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Welcome to Your App!</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f9f9f9;
        }
        .container {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 25px;
        }
        .logo {
            width: 150px;
            height: auto;
        }
        .welcome-text {
            font-size: 18px;
            margin: 20px 0;
        }
        .cta-button {
            display: inline-block;
            background-color: #4CAF50; /* لون أخضر للترحيب */
            color: white !important;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 4px;
            font-weight: bold;
            margin: 15px 0;
        }
        .features {
            margin: 25px 0;
        }
        .feature-item {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }
        .feature-icon {
            width: 24px;
            height: 24px;
            margin-right: 10px;
        }
        .footer {
            margin-top: 30px;
            font-size: 12px;
            color: #7f8c8d;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="https://yourwebsite.com/logo.png" alt="Your Logo" class="logo">
            <h2>Welcome to [Your App Name]! 🎉</h2>
        </div>
        
        <p class="welcome-text">Dear {USER_NAME},</p>
        
        <p>Thank you for joining [Your App Name]! We're thrilled to have you on board.</p>
        
        <div class="features">
            <h3>Get started with these features:</h3>
            <div class="feature-item">
                <img src="https://cdn-icons-png.flaticon.com/512/157/157933.png" class="feature-icon" alt="Profile">
                <span>Complete your profile to personalize your experience</span>
            </div>
            <div class="feature-item">
                <img src="https://cdn-icons-png.flaticon.com/512/157/157954.png" class="feature-icon" alt="Explore">
                <span>Explore our exclusive content</span>
            </div>
            <div class="feature-item">
                <img src="https://cdn-icons-png.flaticon.com/512/157/157912.png" class="feature-icon" alt="Support">
                <span>24/7 customer support</span>
            </div>
        </div>
        
        <a href="https://yourwebsite.com/dashboard" class="cta-button">Go to Dashboard</a>
        
        <p>If you have any questions, feel free to reply to this email or contact our support team.</p>
        
        <p>Best regards,<br>The [Your App Name] Team</p>
        
        <div class="footer">
            <p>&copy; 2023 [Your Company Name]. All rights reserved.</p>
            <p>
                <a href="https://twitter.com/yourapp" style="color: #7f8c8d; text-decoration: none;">Twitter</a> | 
                <a href="https://facebook.com/yourapp" style="color: #7f8c8d; text-decoration: none;">Facebook</a> | 
                <a href="https://yourwebsite.com" style="color: #7f8c8d; text-decoration: none;">Website</a>
            </p>
            <p>123 Main St, City, Country</p>
        </div>
    </div>
</body>
</html>`