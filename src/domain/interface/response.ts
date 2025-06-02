export interface ApiResponse {
    success: boolean;
    statusCode: number;
    message: string;
    body?: unknown;
}