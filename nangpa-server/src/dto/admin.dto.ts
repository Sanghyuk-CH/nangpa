// ban-user.dto.ts
import { IsNumber, IsNotEmpty, IsEnum, IsArray, IsInt, ValidateNested } from 'class-validator';
import { Category } from './post.dto';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class BanUserDto {
  // todo: swagger
  @ApiProperty({
    example: 'swagger',
    description: 'this is name of swagger study',
  })
  @IsNotEmpty()
  @IsNumber()
  userId: number;

  @IsNotEmpty()
  days: number | 'infinite';
}

export class GetReportedPostsDto {
  @IsNotEmpty()
  @IsNumber()
  page: number;

  @IsNotEmpty()
  @IsNumber()
  row: number;
}

class PostIdentifier {
  @IsNotEmpty()
  @IsEnum(Category)
  category: string;

  @IsNotEmpty()
  @IsInt()
  id: number;
}

export class DeleteReportedPostsDto {
  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => PostIdentifier)
  postIds: PostIdentifier[];
}

export class GetReportedCommentsDto {
  @IsNotEmpty()
  @IsNumber()
  page: number;

  @IsNotEmpty()
  @IsNumber()
  row: number;
}

class CommentIdentifier {
  @IsNotEmpty()
  @IsEnum(Category)
  category: string;

  @IsNotEmpty()
  @IsInt()
  id: number;
}

export class DeleteReportedCommentsDto {
  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CommentIdentifier)
  commentsIds: CommentIdentifier[];
}

export class AdminLoginDto {
  @IsNotEmpty()
  account: string;

  @IsNotEmpty()
  password: string;

  @IsNotEmpty()
  code: string;
}
