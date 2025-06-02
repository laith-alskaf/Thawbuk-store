import { ProductInfoDTO } from "../../application/dtos/product.dto";
import { NotificationService } from "../../domain/services/notification.service";
import { messaging } from "../../presentation/config/firebase";
export class NewProductNotification implements NotificationService {
    async send(product: ProductInfoDTO): Promise<void> {
        console.log(JSON.stringify(product));
        const message = {
            data: {
                title: 'New Product Added!',
                body: JSON.stringify(product)
            },
            topic: 'new_product',
        };

        try {
            await messaging.send(message);
            console.log('Notification sent successfully');
        } catch (error) {
            console.error('Error sending notification:', error);
        }
    }
    async sendByFcm(fcmTokens: string[], product: ProductInfoDTO): Promise<void> {
      console.log(JSON.stringify(product));
    }
}


