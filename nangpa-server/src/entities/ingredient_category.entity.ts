import { Column, Entity, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { Ingredient } from './ingredient.entity';

@Entity('ingredient_category')
export class IngredientCategory {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string; // 카테고리명

  @Column()
  expiry_date: number;

  @OneToMany(() => Ingredient, (ingredient) => ingredient)
  ingredients: Ingredient[];
}
