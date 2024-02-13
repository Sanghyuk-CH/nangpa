import { HttpException, HttpStatus, Inject, Injectable, Res } from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';

import { JwtService } from '@nestjs/jwt';
import { ChangeUserPasswordDto, LoginDto, ResetUserPasswordDto, SignUpDto } from 'src/dto/auth.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from 'src/entities/user.entity';
import { Repository } from 'typeorm';
// import { Iamport } from 'iamport-rest-client-nodejs';
import { RES_CODE } from 'src/utils/responseCode';
import { sendSms } from 'src/utils/smsHandler';
import { generateRandomPassword } from 'src/utils/randomPassword';
import { comparePasswords, hashPassword } from 'src/utils/hashHandler';
// import { Certifications } from 'iamport-rest-client-nodejs/dist/request';

@Injectable()
export class AuthService {
  // private iamport: Iamport;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
    @Inject(CACHE_MANAGER)
    private readonly cacheManager: Cache,
  ) {}

  // async verifyRealName(imp_uid: string) {
  //   /* 휴대폰 본인인증 정보 조회 */
  //   const getCertification = Certifications.getCertification({
  //     imp_uid,
  //   });
  //   await getCertification
  //     .request(this.iamport)
  //     .then((response) => console.log('response: ', response.data))
  //     .catch((error) => console.log('error: ', error.response.data));

  //   /* 휴대폰 본인인증 정보 삭제 */
  //   const deleteCertification = Certifications.deleteCertification({
  //     imp_uid,
  //   });
  //   await deleteCertification
  //     .request(this.iamport)
  //     .then((response) => console.log('response: ', response.data))
  //     .catch((error) => console.log('error: ', error.response.data));
  // }

  async sendVerificationCode(phone: string, isResetVerify = false): Promise<void> {
    if (isResetVerify == false) {
      // 사용자 중복 체크
      const isUserExists = await this.findUserByPhoneNumber(phone);
      // 사용자가 이미 존재하는 경우 에러 응답을 반환합니다.
      if (isUserExists) {
        throw new HttpException(
          { code: RES_CODE.error, message: '전화번호가 이미 사용 중입니다.' },
          HttpStatus.BAD_REQUEST,
        );
      }
    }

    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    await this.cacheManager.set(phone, verificationCode);
    const sendSmsResult = await sendSms({ phone, message: `Your verification code is: ${verificationCode}` });

    if (parseInt(sendSmsResult.data.result_code) < 0) {
      throw new HttpException({ code: RES_CODE.error, message: '발송에 실패했습니다.' }, HttpStatus.FORBIDDEN);
    }
  }

  async verifyCode(phone: string, code: string): Promise<boolean> {
    const cachedCode = await this.cacheManager.get<string>(phone);
    if (cachedCode === code) {
      await this.cacheManager.del(phone);
      return true;
    } else {
      return false;
    }
  }

  async signUpUser(signUpDto: SignUpDto): Promise<any> {
    const { phone_number, password, name, marketing } = signUpDto;

    // 닉네임 중복 체크
    const existingUser = await this.userRepository.findOne({ where: { nickname: name } });
    if (existingUser) {
      throw new HttpException({ code: RES_CODE.error, message: '중복되는 닉네임입니다.' }, HttpStatus.BAD_REQUEST);
    }

    const user = new User();
    user.nickname = name;
    user.phone_number = phone_number;
    user.password = hashPassword(password);
    user.marketing = marketing;

    await this.userRepository.save(user);
    return { code: RES_CODE.success, message: '회원가입이 완료되었습니다.' };
  }

  async resetUserPassword(changeUserPasswordDto: ResetUserPasswordDto) {
    const { phone_number } = changeUserPasswordDto;
    const user = await this.findUserByPhoneNumber(phone_number);
    if (!user) {
      throw new HttpException(
        { code: RES_CODE.error, message: '일치하는 계정 정보가 없습니다.' },
        HttpStatus.BAD_REQUEST,
      );
    } else {
      const randomPassword = generateRandomPassword();
      user.password = hashPassword(randomPassword);
      await this.userRepository.update(user.id, user);
      await sendSms({ phone: phone_number, message: `Your reset password is:\n${randomPassword}` });
      return { code: RES_CODE.success, message: 'password 초기화가 완료되었습니다.' };
    }
  }

  async changeUserPassword(changeUserPasswordDto: ChangeUserPasswordDto) {
    const { phone_number, new_password, password } = changeUserPasswordDto;
    const user = await this.findUserByPhoneNumber(phone_number);
    if (!user) {
      throw new HttpException(
        { code: RES_CODE.error, message: '일치하는 계정 정보가 없습니다.' },
        HttpStatus.BAD_REQUEST,
      );
    } else if (comparePasswords(user.password, hashPassword(password))) {
      throw new HttpException(
        { code: RES_CODE.error, message: '현재 비밀번호가 올바르지 않습니다.' },
        HttpStatus.BAD_REQUEST,
      );
    } else if (comparePasswords(new_password, user.password)) {
      throw new HttpException({ code: RES_CODE.error, message: '현재 비밀번호와 일치합니다.' }, HttpStatus.BAD_REQUEST);
    } else {
      user.password = hashPassword(new_password);
      await this.userRepository.update(user.id, user);
      return { code: RES_CODE.success, message: 'password 변경이 완료되었습니다.' };
    }
  }

  async findUserByPhoneNumber(phone_number: string): Promise<User> {
    return await this.userRepository.findOne({ where: { phone_number } });
  }

  async login(loginDto: LoginDto, @Res() response) {
    const userData = await this.findUserByPhoneNumber(loginDto.phone_number);
    const access_token = this.jwtService.sign(
      { phone_number: userData.phone_number, name: userData.nickname },
      { secret: process.env.JWT_SEC_KEY },
    );
    const user = new User();
    user.id = userData.id;
    user.nickname = userData.nickname;
    user.phone_number = userData.phone_number;
    user.profile_img_url = userData.profile_img_url;
    user.created_at = userData.created_at;
    user.updated_at = userData.updated_at;
    user.marketing = userData.marketing;
    response.setHeader('Authorization', 'Bearer ' + access_token);
    response.status(200).json({
      message: 'Logged in successfully',
      user: {
        id: userData.id,
        nickname: userData.nickname,
        phone_number: userData.phone_number,
        profile_img_url: userData.profile_img_url,
        created_at: userData.created_at,
        updated_at: userData.updated_at,
        marketing: userData.marketing,
      },
    });
  }

  async logout(@Res() response) {
    response.setHeader('Authorization', '');
    return { message: 'Logged out successfully' };
  }
}
