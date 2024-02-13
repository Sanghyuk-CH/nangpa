import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IngredientCategory } from 'src/entities/ingredient_category.entity';
import { Ingredient } from 'src/entities/ingredient.entity';
import { Repository } from 'typeorm';

interface CategorisedList {
  [categoryName: string]: Ingredient[];
}
export interface IngredientResponse {
  categorisedList: CategorisedList;
  ingredientList: Ingredient[];
}
@Injectable()
export class IngredientsService {
  constructor(
    @InjectRepository(Ingredient)
    private ingredientRepository: Repository<Ingredient>,
    @InjectRepository(IngredientCategory)
    private categoryRepository: Repository<IngredientCategory>,
  ) {}

  async findAll(): Promise<IngredientResponse> {
    // 재료 리턴. (카테고리화 된 리스트, 검색 위한 리스트)
    const categorisedList = {};
    const list = await this.ingredientRepository.find({
      relations: ['category'],
    });
    list.forEach((r) => {
      if (!Array.isArray(categorisedList[r.category.name])) {
        categorisedList[r.category.name] = [{ ...r }];
      } else {
        categorisedList[r.category.name].push(r);
      }
    });
    return { categorisedList: categorisedList, ingredientList: list };
  }
}
