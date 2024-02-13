import { Controller, Get, Post, Put, Body, Param, UseGuards, Query } from '@nestjs/common';
import { CommentsService } from './comments.service';
import { CommentType, CreateCommentDto, UpdateCommentDto } from '../dto/comment.dto';
import { UpdateResult } from 'typeorm';
import { AuthGuard } from '@nestjs/passport';
import { Category } from 'src/dto/post.dto';

@Controller('comment/:category')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Get(':post_id')
  async getCommentsAndReplies(
    @Param('category') category: Category,
    @Param('post_id') post_id: number,
  ): Promise<CommentType[]> {
    return await this.commentsService.getCommentsAndReplies({ category, post_id });
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('')
  async create(
    @Param('category') category: Category,
    @Body() createCommentDto: CreateCommentDto,
  ): Promise<CommentType> {
    return await this.commentsService.create({ category, createCommentDto });
  }

  @UseGuards(AuthGuard('jwt'), AuthGuard('author'))
  @Put(':id')
  async update(
    @Param('category') category: Category,
    @Param('id') id: number,
    @Body() updateCommentDto: UpdateCommentDto,
  ): Promise<UpdateResult> {
    return await this.commentsService.update({ category, id, updateCommentDto });
  }

  @UseGuards(AuthGuard('jwt'), AuthGuard('author'))
  @Post(':id') // payload {user_id: number} 필요
  async remove(@Param('category') category: Category, @Param('id') id: number): Promise<void> {
    await this.commentsService.remove({ category, id });
  }
}
