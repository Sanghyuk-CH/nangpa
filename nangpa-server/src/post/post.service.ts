import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Category, CreatePostFreeDTO, PostType, UpdatePostFreeDTO } from 'src/dto/post.dto';
import { PostFree } from '../entities/post_free.entity';
import { RES_CODE } from '../utils/responseCode';
import { DeleteResult, In, Not, Repository, UpdateResult } from 'typeorm';
import { ReportPost } from 'src/entities/admin/report_post.entity';

@Injectable()
export class PostService {
  categoryRepositories: Record<Category, Repository<PostType>>;

  constructor(
    @InjectRepository(PostFree)
    private readonly postFreeRepository: Repository<PostFree>,
    @InjectRepository(ReportPost)
    private readonly reportPostRepository: Repository<ReportPost>,
  ) {
    this.categoryRepositories = {
      [Category.FREE]: this.postFreeRepository,
    };
  }

  async findAll({ category, skip, take }: { category: Category; skip: number; take: number }): Promise<PostType[]> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }

    // Get reported post ids
    const reportedPostIds = (await this.reportPostRepository.find({ where: { category, isCompleted: false } })).map(
      (report) => report.post_id,
    );

    return await this.categoryRepositories[category].find({
      where: {
        id: Not(In(reportedPostIds)),
      },
      order: {
        created_at: 'DESC',
      },
      relations: ['user'],
      skip,
      take,
    });
  }

  async findOne({ category, id }: { category: Category; id: number }): Promise<PostType> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }

    const reportedPostIds = (await this.reportPostRepository.find({ where: { category, isCompleted: false } })).map(
      (report) => report.post_id,
    );

    if (reportedPostIds.includes(+id)) {
      throw new HttpException({ code: RES_CODE.error, message: '신고된 게시물입니다.' }, HttpStatus.BAD_REQUEST);
    }

    const post = await this.categoryRepositories[category].findOne({ where: { id }, relations: ['user'] });
    post.view_count += 1;
    return await this.categoryRepositories[category].save(post);
  }

  async create({ category, post }: { category: Category; post: CreatePostFreeDTO }): Promise<PostType> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }
    return await this.categoryRepositories[category].save(post);
  }

  async update({
    category,
    id,
    post,
  }: {
    category: Category;
    id: number;
    post: UpdatePostFreeDTO;
  }): Promise<UpdateResult> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }
    return await this.categoryRepositories[category].update(id, post);
  }

  async delete({ id, category }: { id: number; category: Category }): Promise<DeleteResult> {
    if (!this.categoryRepositories[category]) {
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    }

    return await this.categoryRepositories[category].delete(id);
  }
}
