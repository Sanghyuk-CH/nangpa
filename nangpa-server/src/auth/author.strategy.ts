import { HttpException, HttpStatus, Injectable, Req } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-custom';

@Injectable()
export class AuthorStrategy extends PassportStrategy(Strategy, 'author') {
  constructor() {
    super();
  }

  async validate(@Req() req) {
    const contentsUserId = req.body.user_id;
    const reqUserId = req.user.id;

    if (contentsUserId === reqUserId) {
      return true;
    } else {
      throw new HttpException('글쓴이가 아님', HttpStatus.BAD_REQUEST);
    }
  }
}
