import { Module } from '@nestjs/common';
import { MenusController } from './menus.controller';
import { MenusService } from './menus.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Ingredient } from 'src/entities/ingredient.entity';
import { Menu } from 'src/entities/menu.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Ingredient, Menu])],
  controllers: [MenusController],
  providers: [MenusService],
})
export class MenusModule {}
