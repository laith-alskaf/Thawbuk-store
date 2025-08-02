
import { createValidationMiddleware } from "../middleware/validation.middleware";
import { updateUserInfoShema, updateSocialLinksSchema } from "./schemas/user.shema";

export const validateUpdateUserInfo = createValidationMiddleware({
    schema: updateUserInfoShema,
    dataSource: 'body',
});

export const validateUpdateSocialLinks = createValidationMiddleware({
    schema: updateSocialLinksSchema,
    dataSource: 'body',
});
