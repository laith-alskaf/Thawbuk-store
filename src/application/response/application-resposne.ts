import { Response } from "express"

import { ApiResponse } from "../../domain/interface/response";

export class ApplicationResponse {
    constructor(
        private readonly res: Response,
        private readonly response: ApiResponse
    ) { }

    send = (): void => {
        this.res.status(this.response.statusCode).json(this.response);
    }
}
