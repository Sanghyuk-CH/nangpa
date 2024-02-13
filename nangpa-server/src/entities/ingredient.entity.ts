import { Column, Entity, ManyToOne, PrimaryGeneratedColumn, JoinColumn, ManyToMany } from 'typeorm';
import { IngredientCategory } from './ingredient_category.entity';
import { Menu } from './menu.entity';

@Entity('ingredient')
export class Ingredient {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column()
  icon_name: string;

  @ManyToOne(() => IngredientCategory, (category) => category.id)
  @JoinColumn({ name: 'category_id' })
  category: IngredientCategory;

  @ManyToMany(() => Menu)
  menus: Menu[];
}
