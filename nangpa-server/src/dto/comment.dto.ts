import { IsEnum, IsInt, IsNotEmpty, IsString } from 'class-validator';
import { CommentFree } from '../entities/comment_free.entity';
import { Category } from './post.dto';

export class CreateCommentDto {
  user_id: number;
  contents: string;
  post_id: number;
  comment_id?: number;
}
export class UpdateCommentDto {
  user_id: number;
  contents: string;
}

export type CommentType = CommentFree;

export class CreateReportCommentDto {
  @IsEnum(Category)
  @IsNotEmpty()
  category: Category;

  @IsInt()
  @IsNotEmpty()
  comment_id: number;

  @IsString()
  @IsNotEmpty()
  reason: string;
}
