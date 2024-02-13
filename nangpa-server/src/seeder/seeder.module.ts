import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IngredientCategory } from 'src/entities/ingredient_category.entity';
import { Ingredient } from 'src/entities/ingredient.entity';
import { Menu } from 'src/entities/menu.entity';
import { SeederService } from './seeder.service';
import { Hashtag } from 'src/entities/hashtag.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Ingredient, IngredientCategory, Menu, Hashtag])],
  providers: [SeederService],
})
export class SeederModule {}
