import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { UpdateProfileDto } from 'src/dto/user.dto';
import { User } from 'src/entities/user.entity';
import { RES_CODE } from 'src/utils/responseCode';
import { Repository } from 'typeorm';
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>, // private authService: AuthService,
  ) {}

  async update(id: number, profile: UpdateProfileDto) {
    const existingUser = await this.userRepository.findOne({ where: { nickname: profile.nickname } });
    if (existingUser) {
      throw new HttpException({ code: RES_CODE.error, message: '중복되는 닉네임입니다.' }, HttpStatus.BAD_REQUEST);
    }
    return await this.userRepository.update(id, profile);
  }
}
