import { RandomStringGenerator } from "../../domain/services/number-generateor.service";

export class OTPGeneratorService implements RandomStringGenerator {
    generate(): string {
        return Math.floor(100000 + Math.random() * 900000).toString();
    }
}
