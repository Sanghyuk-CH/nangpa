import { Body, Controller, Post, Res, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ChangeUserPasswordDto, LoginDto, ResetUserPasswordDto, SignUpDto } from 'src/dto/auth.dto';
import { AuthGuard } from '@nestjs/passport';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // @Post('verify')
  // async verifycationUser(@Body('imp_uid') imp_uid: string) {
  //   return await this.authService.verifyRealName(imp_uid);
  // }

  @Post('sms/send')
  async sendVerificationCode(
    @Body('phone') phone: string,
    @Body('is_reset_verify') isResetVerify: boolean,
  ): Promise<void> {
    await this.authService.sendVerificationCode(phone, isResetVerify);
  }

  @Post('sms/verify')
  async verificationCode(@Body('phone') phone: string, @Body('code') code: string): Promise<boolean> {
    return await this.authService.verifyCode(phone, code);
  }

  @Post('signup')
  async signUpUser(@Body() signUpDto: SignUpDto) {
    return await this.authService.signUpUser(signUpDto);
  }

  @UseGuards(AuthGuard('login'))
  @Post('login')
  async login(@Body() loginDto: LoginDto, @Res({ passthrough: true }) response) {
    return await this.authService.login(loginDto, response);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('logout')
  async logout(@Res({ passthrough: true }) response) {
    return await this.authService.logout(response);
  }

  @Post('reset-password')
  async resetUserPassword(@Body() body: ResetUserPasswordDto) {
    return await this.authService.resetUserPassword(body);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('change-password')
  async test(@Body() body: ChangeUserPasswordDto) {
    return await this.authService.changeUserPassword(body);
  }
}
