import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IngredientCategory } from 'src/entities/ingredient_category.entity';
import { Ingredient } from 'src/entities/ingredient.entity';
import { IngredientsService } from './ingredients.service';
import { IngredientsController } from './ingredients.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Ingredient, IngredientCategory])],
  providers: [IngredientsService],
  controllers: [IngredientsController],
})
export class IngredientsModule {}
