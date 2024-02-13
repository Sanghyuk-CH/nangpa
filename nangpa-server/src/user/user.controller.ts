import { Body, Controller, Get, Put, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { UserService } from './user.service';
import { UpdateProfileDto } from 'src/dto/user.dto';
import { ApiOkResponse, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';

@ApiTags('user')
@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}
  // todo: swagger
  @ApiOperation({ summary: 'swagger get endpoint' })
  @ApiOkResponse({
    description: 'Success',
  })
  @ApiResponse({
    status: 403,
    description: 'Forbidden',
  })
  @UseGuards(AuthGuard('jwt'))
  @Get('profile')
  async getProfile(@Req() req) {
    return req.user;
  }

  @UseGuards(AuthGuard('jwt'))
  @Put('profile')
  async updateProfile(@Req() req, @Body() profile: UpdateProfileDto) {
    return await this.userService.update(req.user.id, profile);
  }
}
/*
@ApiQuery
@ApiParam
@ApiBody
https://docs.nestjs.com/openapi/operations#advanced-generic-apiresponse
*/
