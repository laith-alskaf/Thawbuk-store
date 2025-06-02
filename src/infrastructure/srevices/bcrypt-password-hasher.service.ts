import bcrypt from "bcryptjs";

import { EncryptionService } from "../../domain/services/encryption.service";

export class BcryptPasswordHasher implements EncryptionService {
  constructor(
    private readonly saltRounds: number = 10
  ) { }

  hash = async (password: string): Promise<string> => {
    return bcrypt.hash(password, this.saltRounds);
  }

  compare = async (password: string, hashedPassword: string): Promise<boolean> => {
    return bcrypt.compare(password, hashedPassword);
  }
}
