import { Module, OnApplicationBootstrap } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { IngredientCategory } from './entities/ingredient_category.entity';
import { Ingredient } from './entities/ingredient.entity';
import { IngredientsModule } from './ingredients/ingredients.module';
import { SeederModule } from './seeder/seeder.module';
import { SeederService } from './seeder/seeder.service';
import { Menu } from './entities/menu.entity';
import { MenusModule } from './menus/menus.module';
import { Hashtag } from './entities/hashtag.entity';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { AutoErrorInterceptor, HttpExceptionFilter } from './utils/errorHandler';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { PostModule } from './post/post.module';
import { CommentModule } from './comments/comments.module';
import { User } from './entities/user.entity';
import { PostFree } from './entities/post_free.entity';
import { CommentFree } from './entities/comment_free.entity';
import { AdminModule } from './admin/admin.module';
import { AwsService } from './aws/aws.service';
import { AwsModule } from './aws/aws.module';
import { MailerModule } from '@nestjs-modules/mailer';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env.' + process.env.NODE_ENV,
    }),
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.MYSQL_HOST,
      port: parseInt(process.env.MYSQL_PORT, 10),
      username: process.env.MYSQL_USERNAME,
      password: process.env.MYSQL_PASSWORD,
      database: process.env.MYSQL_DATABASE,
      entities: ['dist/**/*.entity.{ts,js}'],
      timezone: '+09:00',
      synchronize: true,
    }),
    MailerModule.forRoot({
      transport: {
        host: 'smtp.gmail.com',
        port: 587,
        auth: {
          user: process.env.NODEMAILER_USER,
          pass: process.env.NODEMAILER_PASS,
        },
      },
      defaults: {
        from: 'noreply@gmail.com',
      },
    }),
    TypeOrmModule.forFeature([Ingredient, IngredientCategory, Menu, Hashtag, CommentFree, PostFree, User]),
    IngredientsModule,
    SeederModule,
    MenusModule,
    UserModule,
    AuthModule,
    PostModule,
    CommentModule,
    AdminModule,
    AwsModule,
  ],
  controllers: [AppController],
  providers: [
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: AutoErrorInterceptor,
    },
    AppService,
    SeederService,
    AwsService,
  ],
})
export class AppModule implements OnApplicationBootstrap {
  constructor(private readonly seederService: SeederService) {}

  async onApplicationBootstrap() {
    await this.seederService.seed();
  }
}
