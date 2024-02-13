import { Controller, Post, Body, Delete, UseGuards, Req, Res, Get } from '@nestjs/common';
import { AdminService } from './admin.service';
import {
  AdminLoginDto,
  BanUserDto,
  DeleteReportedCommentsDto,
  DeleteReportedPostsDto,
  GetReportedCommentsDto,
  GetReportedPostsDto,
} from 'src/dto/admin.dto';
import { AuthGuard } from '@nestjs/passport';
import { CreateReportPostDto } from 'src/dto/post.dto';
import { ReportPost } from 'src/entities/admin/report_post.entity';
import { CreateReportCommentDto } from 'src/dto/comment.dto';
import { ReportComment } from 'src/entities/admin/report_comment.entity';

@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @UseGuards(AuthGuard('admin-jwt'))
  @Get('ban-user')
  async findAllBanUsers() {
    return await this.adminService.findAllBanUsers();
  }

  @UseGuards(AuthGuard('admin-jwt'))
  @Post('ban-user')
  async banUser(@Body() banUserDto: BanUserDto) {
    return await this.adminService.banUser(banUserDto);
  }

  @UseGuards(AuthGuard('admin-jwt'))
  @Post('get-reported-posts')
  async getReportedPosts(@Body() getReportedPostsDto: GetReportedPostsDto) {
    return await this.adminService.getReportedPosts(getReportedPostsDto);
  }

  @UseGuards(AuthGuard('admin-jwt'))
  @Delete('delete-reported-posts')
  async deleteReportedPosts(@Body() deleteReportedPostsDto: DeleteReportedPostsDto): Promise<void> {
    return await this.adminService.deleteReportedPosts(deleteReportedPostsDto);
  }

  @UseGuards(AuthGuard('admin-jwt'))
  @Post('get-reported-comments')
  async getReportedComments(@Body() getReportedCommentsDto: GetReportedCommentsDto) {
    return await this.adminService.getReportedComments(getReportedCommentsDto);
  }

  @UseGuards(AuthGuard('admin-jwt'))
  @Delete('delete-reported-comments')
  async deleteReportedComments(@Body() deleteReportedCommentsDto: DeleteReportedCommentsDto): Promise<void> {
    return await this.adminService.deleteReportedComments(deleteReportedCommentsDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('create-report-post')
  async createReportPost(@Req() req, @Body() createReportPostDto: CreateReportPostDto): Promise<ReportPost> {
    return await this.adminService.createReportPost(req.user.id, createReportPostDto);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('create-report-comment')
  async createReportComment(
    @Req() req,
    @Body() createReportCommentDto: CreateReportCommentDto,
  ): Promise<ReportComment> {
    return await this.adminService.createReportComment(req.user.id, createReportCommentDto);
  }

  @Post('send-admin-verify-code')
  async sendVerificationAdminCode(@Body('account') account: string, @Body('password') password: string) {
    return await this.adminService.sendVerificationAdminCode(account, password);
  }

  @Post('login')
  async adminLogin(@Body() adminLoginDto: AdminLoginDto, @Res({ passthrough: true }) response) {
    return await this.adminService.adminLogin(adminLoginDto, response);
  }
}
