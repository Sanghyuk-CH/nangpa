import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Ingredient } from 'src/entities/ingredient.entity';
import { Menu } from 'src/entities/menu.entity';
import { Repository } from 'typeorm';

@Injectable()
export class MenusService {
  constructor(
    @InjectRepository(Ingredient)
    private ingredientRepository: Repository<Ingredient>,
    @InjectRepository(Menu)
    private menuRepository: Repository<Menu>,
  ) {}

  async findAll(): Promise<Menu[]> {
    return this.menuRepository.find({ relations: ['ingredient_required', 'ingredient_optional', 'hashtags'] });
  }

  async findMenusByIngredients(ingredients: string[]): Promise<Partial<Menu>[]> {
    // ingredients 가 빈 배열로 왔을 시 throw exception
    if (ingredients.length < 1) {
      throw new BadRequestException('ingredients cannot be empty.');
    }
    // 주어진 재료 이름에 해당하는 Ingredient 엔티티들을 검색
    const ingredientEntities = await this.ingredientRepository
      .createQueryBuilder('ingredient')
      .where('ingredient.name IN (:...ingredients)', { ingredients })
      .getMany();

    // 검색된 Ingredient 엔티티들과 관련된 Menu 엔티티들을 검색
    const menus = await this.menuRepository
      .createQueryBuilder('menu')
      .select(['menu.id', 'menu.name', 'menu.url'])
      .leftJoin('menu.ingredient_required', 'ingredient_required')
      .leftJoin('menu.ingredient_optional', 'ingredient_optional')
      .where('ingredient_required.id IN (:...ingredientIds) OR ingredient_optional.id IN (:...ingredientIds)', {
        ingredientIds: ingredientEntities.map((ingredient) => ingredient.id),
      })
      .getMany();

    return menus;
  }

  async findMenuDetailById(id: number): Promise<Menu> {
    return this.menuRepository
      .createQueryBuilder('menu')
      .leftJoinAndSelect('menu.ingredient_required', 'ingredient_required')
      .leftJoinAndSelect('menu.ingredient_optional', 'ingredient_optional')
      .leftJoinAndSelect('menu.hashtags', 'hashtag')
      .where('menu.id = :id', { id })
      .getOne();
  }
}
