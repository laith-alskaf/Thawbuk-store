import jwt, { Secret, SignOptions } from "jsonwebtoken";
import { TokenService } from "../../domain/services/token.service";


export class JwtTokenService implements TokenService {

    generate = async (payload: object, key: string, expiresIn: string): Promise<string> => {
        const options: SignOptions = { expiresIn: expiresIn as any };
        return jwt.sign(payload, key as Secret, options);
    }

    verify = async (token: string, key: string): Promise<object | null> => {
        const decoded = jwt.verify(token, key as Secret) as object;
        return decoded;
    }
}
