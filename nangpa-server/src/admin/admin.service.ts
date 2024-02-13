// admin.service.ts
import { HttpException, HttpStatus, Inject, Injectable, Res } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BanUser } from 'src/entities/admin/ban_user.entity';
import { User } from 'src/entities/user.entity';
import { MailerService } from '@nestjs-modules/mailer';
import { RES_CODE } from 'src/utils/responseCode';
import { ReportPost } from 'src/entities/admin/report_post.entity';
import { ReportComment } from 'src/entities/admin/report_comment.entity';
import { Category, CreateReportPostDto, PostType } from 'src/dto/post.dto';
import { CommentType, CreateReportCommentDto } from 'src/dto/comment.dto';
import { PostFree } from 'src/entities/post_free.entity';
import { CommentFree } from 'src/entities/comment_free.entity';
import {
  AdminLoginDto,
  DeleteReportedCommentsDto,
  DeleteReportedPostsDto,
  GetReportedCommentsDto,
  GetReportedPostsDto,
} from 'src/dto/admin.dto';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import { SuperUser } from 'src/entities/admin/super_user.entity';
import { sendMailConfig } from 'src/utils/mailHandler';
import { comparePasswords, hashPassword } from 'src/utils/hashHandler';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AdminService {
  categoryPostRepositories: Record<Category, Repository<PostType>>;
  categoryCommentRepositories: Record<Category, Repository<CommentType>>;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(BanUser)
    private readonly banUserRepository: Repository<BanUser>,
    @InjectRepository(ReportPost)
    private readonly reportPostRepository: Repository<ReportPost>,
    @InjectRepository(ReportComment)
    private readonly reportCommentRepository: Repository<ReportComment>,
    @InjectRepository(PostFree)
    private readonly postFreeRepository: Repository<PostFree>,
    @InjectRepository(CommentFree)
    private readonly commentsFreeRepository: Repository<CommentFree>,
    @InjectRepository(SuperUser)
    private readonly superUserRepository: Repository<SuperUser>,
    @Inject(CACHE_MANAGER)
    private readonly cacheManager: Cache,
    private readonly mailerService: MailerService,
    private readonly jwtService: JwtService,
  ) {
    this.categoryPostRepositories = {
      [Category.FREE]: this.postFreeRepository,
    };
    this.categoryCommentRepositories = {
      [Category.FREE]: this.commentsFreeRepository,
    };
  }

  async findAllBanUsers() {
    const banUsers = await this.banUserRepository
      .createQueryBuilder('banUser')
      .leftJoinAndSelect('banUser.user', 'user')
      .getMany();

    return banUsers;
  }

  async banUser({ userId, days }: { userId: number; days: number | 'infinite' }): Promise<BanUser> {
    const user = await this.userRepository.findOne({ where: { id: userId } });

    if (!user) {
      throw new HttpException(
        { code: RES_CODE.error, message: '일치하는 계정 정보가 없습니다.' },
        HttpStatus.BAD_REQUEST,
      );
    }

    const banEndDate = new Date();

    if (days === 'infinite') {
      banEndDate.setFullYear(9999);
    } else {
      banEndDate.setDate(banEndDate.getDate() + days);
    }

    const banUser = new BanUser();
    banUser.user_id = userId;
    banUser.ban_peroid = banEndDate;

    return await this.banUserRepository.save(banUser);
  }

  async getReportedPosts({ page, row }: GetReportedPostsDto): Promise<any[]> {
    const reportedPosts = await this.reportPostRepository.find({
      skip: (page - 1) * row,
      take: row,
      order: { created_at: 'ASC' },
    });

    const postPromises = reportedPosts.map(async (reportPost) => {
      if (!this.categoryPostRepositories[reportPost.category]) {
        throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
      }

      const post = await this.categoryPostRepositories[reportPost.category].findOne({
        where: { id: reportPost.post_id },
      });

      return {
        reportPost,
        post,
      };
    });

    const result = await Promise.all(postPromises);
    return result;
  }

  async deleteReportedPosts({ postIds }: DeleteReportedPostsDto): Promise<void> {
    for (const postIdentifier of postIds) {
      const { category, id } = postIdentifier;
      if (!this.categoryPostRepositories[category]) {
        throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
      }
      await this.categoryPostRepositories[category].delete(id);
    }
  }

  async getReportedComments({ page, row }: GetReportedCommentsDto): Promise<any[]> {
    const reportedComments = await this.reportCommentRepository.find({
      skip: (page - 1) * row,
      take: row,
      order: { created_at: 'ASC' },
    });

    const commentPromises = reportedComments.map(async (reportComment) => {
      if (!this.categoryCommentRepositories[reportComment.category]) {
        throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
      }

      const comment = await this.categoryCommentRepositories[reportComment.category].findOne({
        where: { id: reportComment.comment_id },
      });

      return {
        reportComment,
        comment,
      };
    });

    const result = await Promise.all(commentPromises);
    return result;
  }

  async deleteReportedComments({ commentsIds }: DeleteReportedCommentsDto): Promise<void> {
    for (const commentIdentifier of commentsIds) {
      const { category, id } = commentIdentifier;
      if (!this.categoryCommentRepositories[category]) {
        throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
      }
      await this.categoryCommentRepositories[category].delete(id);
    }
  }

  async createReportPost(report_user_id: number, createReportPostDto: CreateReportPostDto): Promise<ReportPost> {
    if (!Object.values(Category).includes(createReportPostDto.category))
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    const reportPost = this.reportPostRepository.create({ report_user_id, ...createReportPostDto });
    return await this.reportPostRepository.save(reportPost);
  }

  async createReportComment(
    report_user_id: number,
    createReportCommentDto: CreateReportCommentDto,
  ): Promise<ReportComment> {
    if (!Object.values(Category).includes(createReportCommentDto.category))
      throw new HttpException({ code: RES_CODE.error, message: '카테고리 오류' }, HttpStatus.BAD_REQUEST);
    const reportPost = this.reportCommentRepository.create({ report_user_id, ...createReportCommentDto });
    return await this.reportCommentRepository.save(reportPost);
  }

  async adminLogin(adminLoginDto: AdminLoginDto, @Res() response) {
    const { account, password, code } = adminLoginDto;
    const adminUser = await this.superUserRepository.findOne({ where: { account } });
    const isVerifyCode = await this.verifyAdminCode(account, code);
    if (!adminUser) {
      throw new HttpException({ code: RES_CODE.error, message: '어드민 유저가 아닙니다.' }, HttpStatus.UNAUTHORIZED);
    }
    if (adminUser && !comparePasswords(password, adminUser.password)) {
      throw new HttpException({ code: RES_CODE.error, message: '비밀번호가 맞지 않습니다.' }, HttpStatus.BAD_REQUEST);
    }
    if (!isVerifyCode) {
      throw new HttpException({ code: RES_CODE.error, message: '코드가 맞지 않습니다.' }, HttpStatus.BAD_REQUEST);
    }

    const access_token = this.jwtService.sign(
      { account: adminUser.account, email: adminUser.email },
      { secret: process.env.JWT_SEC_KEY },
    );
    response.setHeader('Authorization', 'Bearer ' + access_token);
    response.status(200).json({ message: 'Logged in successfully' });
  }

  async sendVerificationAdminCode(account: string, password: string): Promise<void> {
    const adminUser = await this.superUserRepository.findOne({ where: { account } });
    if (!adminUser) {
      throw new HttpException({ code: RES_CODE.error, message: '어드민 유저가 아닙니다.' }, HttpStatus.UNAUTHORIZED);
    }
    if (adminUser && !comparePasswords(password, adminUser.password)) {
      throw new HttpException({ code: RES_CODE.error, message: '비밀번호가 맞지 않습니다.' }, HttpStatus.BAD_REQUEST);
    }
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    await this.cacheManager.set(`admin-${account}`, verificationCode);
    await this.mailerService.sendMail(sendMailConfig(adminUser.email, verificationCode));
  }

  async verifyAdminCode(account: string, code: string): Promise<boolean> {
    const cachedCode = await this.cacheManager.get<string>(`admin-${account}`);
    if (cachedCode === code) {
      await this.cacheManager.del(`admin-${account}`);
      return true;
    } else {
      return false;
    }
  }
}
