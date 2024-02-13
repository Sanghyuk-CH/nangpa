import { Column, Entity, JoinTable, ManyToMany, PrimaryGeneratedColumn } from 'typeorm';
import { Hashtag } from './hashtag.entity';
import { Ingredient } from './ingredient.entity';

@Entity('menu')
export class Menu {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ nullable: true })
  way: string;

  @Column({ nullable: true })
  url: string;

  @Column({ type: 'text' })
  ingredient_description_text: string;

  @Column('json')
  recipe: object;

  @ManyToMany(() => Hashtag, (cls) => cls.menus)
  @JoinTable({
    name: 'menu_hashtag',
    joinColumn: { name: 'menu_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'hashtag_id', referencedColumnName: 'id' },
  })
  hashtags: Hashtag[];

  @ManyToMany(() => Ingredient, { nullable: true })
  @JoinTable({
    name: 'menu_ingredient_required',
    joinColumn: { name: 'menu_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'ingredient_id', referencedColumnName: 'id' },
  })
  ingredient_required: Ingredient[];

  @ManyToMany(() => Ingredient, { nullable: true })
  @JoinTable({
    name: 'menu_ingredient_optional',
    joinColumn: { name: 'menu_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'ingredient_id', referencedColumnName: 'id' },
  })
  ingredient_optional: Ingredient[];
}
