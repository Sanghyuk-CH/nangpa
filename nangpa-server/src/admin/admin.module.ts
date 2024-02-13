import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from 'src/entities/user.entity';
import { BanUser } from 'src/entities/admin/ban_user.entity';
import { ReportPost } from 'src/entities/admin/report_post.entity';
import { ReportComment } from 'src/entities/admin/report_comment.entity';
import { PostFree } from 'src/entities/post_free.entity';
import { CommentFree } from 'src/entities/comment_free.entity';
import { CacheModule } from '@nestjs/cache-manager';
import * as redisStore from 'cache-manager-ioredis';
import { SuperUser } from 'src/entities/admin/super_user.entity';
import { JwtModule } from '@nestjs/jwt';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SEC_KEY,
      signOptions: { expiresIn: '1h' },
    }),
    TypeOrmModule.forFeature([User, BanUser, ReportPost, ReportComment, PostFree, CommentFree, SuperUser]),
    CacheModule.register({
      store: redisStore as any,
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT,
      ttl: 300, // 기본적으로 5분 (300초)
    }),
  ],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
