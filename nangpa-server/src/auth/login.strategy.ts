import { Strategy } from 'passport-local';
import { PassportStrategy } from '@nestjs/passport';
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { LoginDto } from 'src/dto/auth.dto';
import { AuthService } from './auth.service';
import { InjectRepository } from '@nestjs/typeorm';
import { BanUser } from 'src/entities/admin/ban_user.entity';
import { Repository } from 'typeorm';
import { comparePasswords } from 'src/utils/hashHandler';

@Injectable()
export class LoginStrategy extends PassportStrategy(Strategy, 'login') {
  constructor(
    private readonly authService: AuthService,
    @InjectRepository(BanUser)
    private readonly banUserRepository: Repository<BanUser>,
  ) {
    super({
      usernameField: 'phone_number',
      password: 'password',
    });
  }

  async validateUser({ phone_number, password }: LoginDto): Promise<any> {
    const user = await this.authService.findUserByPhoneNumber(phone_number);
    if (!user || (user && !comparePasswords(password, user.password))) return null;

    const banUser = await this.banUserRepository.findOne({ where: { user_id: user.id } });
    if (banUser && banUser.ban_peroid > new Date()) {
      throw new HttpException('계정이 정지되었습니다.', HttpStatus.FORBIDDEN);
    }
    return user;
  }

  async validate(phone_number: string, password: string): Promise<any> {
    const user = await this.validateUser({ phone_number, password });
    if (!user) {
      throw new HttpException('로그인 실패!', HttpStatus.BAD_REQUEST);
    }
    return true;
  }
}
