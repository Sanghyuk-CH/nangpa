import { Controller, Get, Post, Put, Param, Body, UseGuards, Query } from '@nestjs/common';
import { PostService } from './post.service';
import { PostType, Category, CreatePostFreeDTO, UpdatePostFreeDTO } from 'src/dto/post.dto';
import { DeleteResult, UpdateResult } from 'typeorm';
import { AuthGuard } from '@nestjs/passport';
import { AwsService } from 'src/aws/aws.service';

@Controller('post/:category')
export class PostController {
  constructor(private readonly postService: PostService, private readonly awsService: AwsService) {}

  @Get('/presigned-url')
  async getPresignedUrl(@Query('filename') filename: string): Promise<{ presignedUrl: string }> {
    const presignedUrl = await this.awsService.getPresignedUrl(filename);
    return { presignedUrl };
  }

  @Get('')
  async findAll(
    @Param('category') category: Category,
    @Query('page') page: number,
    @Query('row') row: number,
  ): Promise<PostType[]> {
    return await this.postService.findAll({ category, skip: (page - 1) * row, take: row });
  }

  @Get(':id')
  async findOne(@Param('category') category: Category, @Param('id') id: number): Promise<PostType> {
    return await this.postService.findOne({ category, id });
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('')
  async create(@Param('category') category: Category, @Body() post: CreatePostFreeDTO): Promise<PostType> {
    return await this.postService.create({ category, post });
  }

  @UseGuards(AuthGuard('jwt'), AuthGuard('author'))
  @Put(':id')
  async update(
    @Param('category') category: Category,
    @Param('id') id: number,
    @Body() post: UpdatePostFreeDTO,
  ): Promise<UpdateResult> {
    return await this.postService.update({ category, id, post });
  }

  @UseGuards(AuthGuard('jwt'), AuthGuard('author'))
  @Post(':id') // payload {user_id: number} 필요
  async delete(@Param('category') category: Category, @Param('id') id: number): Promise<DeleteResult> {
    return await this.postService.delete({ category, id });
  }
}
