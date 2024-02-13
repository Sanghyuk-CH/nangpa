import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DeleteResult, Repository, UpdateResult } from 'typeorm';
import { CommentFree } from '../entities/comment_free.entity';
import { CommentType, CreateCommentDto, UpdateCommentDto } from '../dto/comment.dto';
import { Category } from 'src/dto/post.dto';
import { RES_CODE } from 'src/utils/responseCode';
import { ReportComment } from 'src/entities/admin/report_comment.entity';

@Injectable()
export class CommentsService {
  categoryRepositories: Record<Category, Repository<CommentType>>;

  constructor(
    @InjectRepository(CommentFree)
    private readonly commentsFreeRepository: Repository<CommentFree>,
    @InjectRepository(ReportComment)
    private readonly reportCommentRepository: Repository<ReportComment>,
  ) {
    this.categoryRepositories = {
      [Category.FREE]: this.commentsFreeRepository,
    };
  }

  async getCommentsAndReplies({ category, post_id }: { category: Category; post_id: number }): Promise<CommentType[]> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }

    const reportedCommentIds = (
      await this.reportCommentRepository.find({ where: { category, isCompleted: false } })
    ).map((report) => report.comment_id);

    const query = this.categoryRepositories[category]
      .createQueryBuilder('comment')
      .leftJoinAndSelect('comment.comments', 'replies')
      .leftJoinAndSelect('replies.user', 'replyUser')
      .leftJoinAndSelect('comment.user', 'user')
      .where('comment.post_id = :post_id', { post_id })
      .andWhere('comment.comment_id IS NULL');

    if (reportedCommentIds.length > 0) {
      query.andWhere('comment.id NOT IN (:...reportedCommentIds)', { reportedCommentIds });
    }

    function filterReportedComments(comments: CommentType[], reportedCommentIds: number[]): CommentType[] {
      return comments
        .map((comment) => {
          const filteredReplies = comment.comments.filter((reply) => !reportedCommentIds.includes(reply.id));
          return { ...comment, comments: filteredReplies };
        })
        .filter((comment) => !reportedCommentIds.includes(comment.id));
    }

    const comments = await query.orderBy('comment.created_at', 'ASC').getMany();
    let filteredComments = filterReportedComments(comments, reportedCommentIds);

    filteredComments = filteredComments.map((comment) => {
      // Remove password from user
      const user = { ...comment.user };
      delete user.password;
      comment.user = user;

      // Remove password from user in comments
      comment.comments = comment.comments.map((reply) => {
        const replyUser = { ...reply.user };
        delete replyUser.password;
        reply.user = replyUser;

        return reply;
      });

      return comment;
    });

    return filteredComments;
  }

  async create({
    category,
    createCommentDto,
  }: {
    category: Category;
    createCommentDto: CreateCommentDto;
  }): Promise<CommentType> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }

    return await this.categoryRepositories[category].save(createCommentDto);
  }

  async update({
    category,
    id,
    updateCommentDto,
  }: {
    category: Category;
    id: number;
    updateCommentDto: UpdateCommentDto;
  }): Promise<UpdateResult> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }
    return await this.categoryRepositories[category].update(id, updateCommentDto);
  }

  async remove({ category, id }: { id: number; category: Category }): Promise<DeleteResult> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }
    return await this.categoryRepositories[category].delete(id);
  }
}
