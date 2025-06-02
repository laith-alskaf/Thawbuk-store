import { v4 as uuidv4 } from "uuid";

import { IdGeneratorService } from "../../domain/services/id-generator.service";

export class UuidGeneratorService implements IdGeneratorService {
    generate(): string {
        return uuidv4();
    }
}
