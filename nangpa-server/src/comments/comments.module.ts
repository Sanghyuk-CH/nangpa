import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommentFree } from '../entities/comment_free.entity';
import { CommentsController } from './comments.controller';
import { CommentsService } from './comments.service';
import { ReportComment } from 'src/entities/admin/report_comment.entity';

@Module({
  imports: [TypeOrmModule.forFeature([CommentFree, ReportComment])],
  controllers: [CommentsController],
  providers: [CommentsService],
  exports: [CommentsService],
})
export class CommentModule {}
