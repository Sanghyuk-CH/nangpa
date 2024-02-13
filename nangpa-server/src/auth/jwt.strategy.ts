import { HttpException, HttpStatus, Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-jwt';
import { AuthService } from './auth.service';
import { InjectRepository } from '@nestjs/typeorm';
import { BanUser } from 'src/entities/admin/ban_user.entity';
import { Repository } from 'typeorm';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly authService: AuthService,
    @InjectRepository(BanUser)
    private readonly banUserRepository: Repository<BanUser>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SEC_KEY,
    });
  }

  async validate(payload: { phone_number: string }) {
    const user = await this.authService.findUserByPhoneNumber(payload.phone_number);

    const banUser = await this.banUserRepository.findOne({ where: { user_id: user.id } });
    if (banUser && banUser.ban_peroid > new Date()) {
      throw new HttpException('계정이 정지되었습니다.', HttpStatus.FORBIDDEN);
    }

    if (!user) {
      throw new UnauthorizedException();
    }
    delete user.password;
    return user;
  }
}
