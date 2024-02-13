import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { User } from './user.entity';
import { CommentFree } from './comment_free.entity';

@Entity('post_free')
export class PostFree {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 45 })
  user_name: string;

  @Column({ type: 'varchar', length: 45 })
  title: string;

  @Column({ type: 'json' })
  contents: Array<Record<string, any>>;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @Column({ type: 'int' })
  user_id: number;

  @Column({ type: 'int' })
  view_count: number;

  // Relationships
  @ManyToOne(() => User, (user) => user.post_free, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn({ name: 'user_id', referencedColumnName: 'id' })
  user: User;

  @OneToMany(() => CommentFree, (comment_free) => comment_free.comments, {
    onDelete: 'CASCADE',
    onUpdate: 'NO ACTION',
  })
  comments: CommentFree[];
}
