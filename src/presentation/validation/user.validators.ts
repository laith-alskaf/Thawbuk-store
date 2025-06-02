
import { createValidationMiddleware } from "../middleware/validation.middleware";
import { updateUserInfoShema } from "./schemas/user.shema";

export const validateUpdateUserInfo = createValidationMiddleware({
    schema: updateUserInfoShema,
    dataSource: 'body',
});
