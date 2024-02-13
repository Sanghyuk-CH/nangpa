import { IsEnum, IsInt, IsNotEmpty, IsString } from 'class-validator';
import { PostFree } from '../entities/post_free.entity';

export enum Category {
  FREE = 'free',
}

export class CreatePostFreeDTO {
  userName: string;
  title: string;
  contents: Array<Record<string, any>>;
  userId: number;
  viewCount: number;
}

export class UpdatePostFreeDTO {
  user_id: number;
  title: string;
  contents: Array<Record<string, any>>;
}

export type PostType = PostFree;

export class CreateReportPostDto {
  @IsEnum(Category)
  @IsNotEmpty()
  category: Category;

  @IsInt()
  @IsNotEmpty()
  post_id: number;

  @IsString()
  @IsNotEmpty()
  reason: string;
}
