import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IngredientCategory } from 'src/entities/ingredient_category.entity';
import { Ingredient } from 'src/entities/ingredient.entity';
import { Repository } from 'typeorm';
import { HASH_TAG, INGREDEINT_LIST, ingredientCategories, MENU_LIST } from './seeder-info';
import { Menu } from 'src/entities/menu.entity';
import { Hashtag } from 'src/entities/hashtag.entity';

@Injectable()
export class SeederService {
  constructor(
    @InjectRepository(Hashtag)
    private readonly hashtagRepository: Repository<Hashtag>,
    @InjectRepository(Ingredient)
    private readonly ingredientRepository: Repository<Ingredient>,
    @InjectRepository(IngredientCategory)
    private readonly categoryRepository: Repository<IngredientCategory>,
    @InjectRepository(Menu)
    private readonly menuRepository: Repository<Menu>,
  ) {}

  async onInitHashTagRow(): Promise<void> {
    const promises = HASH_TAG.map(async (h) => {
      const hashTag = new Hashtag();
      hashTag.name = h;
      return this.hashtagRepository.save(hashTag);
    });
    await Promise.all(promises);
  }

  async onInitCategoryRow(): Promise<void> {
    const promises = ingredientCategories.map(async (c) => {
      const category = new IngredientCategory();
      category.name = c.name;
      category.expiry_date = c.expiry_date;
      return this.categoryRepository.save(category);
    });
    await Promise.all(promises);
  }

  async onInitIngredientRow(): Promise<void> {
    const promises = INGREDEINT_LIST.map(async (ingredientInfo) => {
      const category = await this.categoryRepository.findOne({ where: { name: ingredientInfo.category } });
      const ingredient = new Ingredient();
      ingredient.name = ingredientInfo.name;
      ingredient.icon_name = ingredientInfo.icon_name;
      ingredient.category = category;
      return this.ingredientRepository.save(ingredient);
    });
    await Promise.all(promises);
  }

  async onInitMenu(): Promise<void> {
    MENU_LIST.forEach(async (menuInfo) => {
      const menu = new Menu();
      menu.name = menuInfo.name;
      menu.way = menuInfo.way;
      menu.url = menuInfo.url;
      menu.ingredient_description_text = menuInfo.ingredient_description_text;
      menu.recipe = menuInfo.recipe;

      const ingredientRequired = await Promise.all(
        menuInfo.ingredient_required.map(async (ingredient) => ({
          ...(await this.ingredientRepository.findOne({ where: { name: ingredient } })),
        })),
      );
      menu.ingredient_required = ingredientRequired;

      const ingredientOptional = await Promise.all(
        menuInfo.ingredient_optional.map(async (ingredient) => ({
          ...(await this.ingredientRepository.findOne({ where: { name: ingredient } })),
        })),
      );
      menu.ingredient_optional = ingredientOptional;

      const hashtag = await Promise.all(
        menuInfo.hashtag.map(async (tag) => ({
          ...(await this.hashtagRepository.findOne({ where: { name: tag } })),
        })),
      );
      menu.hashtags = hashtag;
      await this.menuRepository.save(menu);
    });
  }

  async seed() {
    // 카테고리 추가
    const hashtagCount = await this.hashtagRepository.count();
    if (hashtagCount === 0) {
      this.onInitHashTagRow();
    }
    const categoryCount = await this.categoryRepository.count();
    if (categoryCount === 0) {
      this.onInitCategoryRow().then(async () => {
        const ingredientCount = await this.ingredientRepository.count();
        if (ingredientCount === 0) {
          await this.onInitIngredientRow().then(async () => {
            const menuCount = await this.menuRepository.count();
            if (menuCount === 0) {
              await this.onInitMenu();
            }
          });
        }
      });
    }
  }
}
