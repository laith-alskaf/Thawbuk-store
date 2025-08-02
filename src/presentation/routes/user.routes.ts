import { Router } from 'express';
import { UserController } from '../controllers/user.controllers';
import { validateUpdateUserInfo, validateUpdateSocialLinks } from '../validation/user.validators';

const userRoutes = (userController: UserController): Router => {
  const router = Router();

  router.get('/me', userController.getUserInfo.bind(userController));
  router.put('/me', validateUpdateUserInfo, userController.updateUserInfo.bind(userController));
  router.put('/me/social-links', validateUpdateSocialLinks, userController.updateSocialLinks.bind(userController));
  router.delete('/me', userController.deleteAccount.bind(userController));

  return router;
};

export default userRoutes;
