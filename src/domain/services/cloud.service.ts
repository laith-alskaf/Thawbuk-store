export interface CloudService {
  uploadImage(fileBuffer: Buffer, path: string, contentType: string): Promise<string>;
}
