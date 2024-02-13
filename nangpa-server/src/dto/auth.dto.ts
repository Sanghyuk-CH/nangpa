import { IsPhoneNumber, IsNotEmpty, MinLength, IsBoolean } from 'class-validator';

export class LoginDto {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone_number: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;
}

export class SignUpDto {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone_number: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @IsNotEmpty()
  name: string;

  @IsBoolean()
  marketing: boolean;
}

export class ResetUserPasswordDto {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone_number: string;
}

export class ChangeUserPasswordDto {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone_number: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @IsNotEmpty()
  @MinLength(6)
  new_password: string;
}
