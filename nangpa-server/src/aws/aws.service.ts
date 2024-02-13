import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

@Injectable()
export class AwsService {
  private s3: S3Client;

  constructor(private configService: ConfigService) {
    this.s3 = new S3Client({
      credentials: {
        accessKeyId: configService.get('AWS_ACCESS_KEY'),
        secretAccessKey: configService.get('AWS_SECRET_ACCESS_KEY'),
      },
      region: configService.get('AWS_REGION'),
    });
  }

  async getPresignedUrl(filename: string): Promise<string> {
    const params = {
      Bucket: this.configService.get('AWS_S3_BUCKET_NAME'),
      Key: `nangpa/${filename}`,
    };

    try {
      const command = new PutObjectCommand(params);
      const presignedUrl = await getSignedUrl(this.s3, command, { expiresIn: 60 * 5 }); // 5 minutes
      return presignedUrl;
    } catch (error) {
      throw new Error(`Presigned URL generation failed: ${(error as any).message}`);
    }
  }
}
