import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { MenusService } from './menus.service';
import { Menu } from 'src/entities/menu.entity';
import { MenuByIngredientDto } from 'src/dto/menu.dto';

@Controller('menus')
export class MenusController {
  constructor(private readonly menuService: MenusService) {}

  @Get('/find')
  async findAll() {
    return await this.menuService.findAll();
  }

  @Post('/by-ingredient')
  async findMenusByIngredients(@Body() dto: MenuByIngredientDto): Promise<Partial<Menu>[]> {
    return await this.menuService.findMenusByIngredients(dto.ingredients);
  }

  @Get('/find/:id')
  async findMenuDetailById(@Param('id') id: number): Promise<Menu> {
    return await this.menuService.findMenuDetailById(id);
  }
}
