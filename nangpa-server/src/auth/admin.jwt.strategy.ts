import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SuperUser } from 'src/entities/admin/super_user.entity';

@Injectable()
export class AdminJwtStrategy extends PassportStrategy(Strategy, 'admin-jwt') {
  constructor(@InjectRepository(SuperUser) private readonly superUserRepository: Repository<SuperUser>) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SEC_KEY,
    });
  }

  async validate(payload: { account: string; email: string }) {
    const user = await this.superUserRepository.findOne({ where: { account: payload.account, email: payload.email } });
    if (!user) {
      throw new UnauthorizedException({ message: '어드민 유저가 아닙니다.' });
    }
    delete user.password;
    return user;
  }
}
