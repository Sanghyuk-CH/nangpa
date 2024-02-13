import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../entities/user.entity';
import { LoginStrategy } from './login.strategy';
import { AuthController } from './auth.controller';
import { AuthorStrategy } from './author.strategy';
import { PostModule } from 'src/post/post.module';
import { CacheModule } from '@nestjs/cache-manager';
import * as redisStore from 'cache-manager-ioredis';
import { BanUser } from 'src/entities/admin/ban_user.entity';
import { AdminJwtStrategy } from './admin.jwt.strategy';
import { SuperUser } from 'src/entities/admin/super_user.entity';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SEC_KEY,
      signOptions: { expiresIn: '365d' },
    }),
    TypeOrmModule.forFeature([User, BanUser, SuperUser]),
    CacheModule.register({
      store: redisStore as any,
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT,
      ttl: 300, // 기본적으로 5분 (300초)
    }),
    PostModule,
  ],
  providers: [AuthService, LoginStrategy, JwtStrategy, AuthorStrategy, AdminJwtStrategy],
  exports: [AuthService, JwtModule],
  controllers: [AuthController],
})
export class AuthModule {}
