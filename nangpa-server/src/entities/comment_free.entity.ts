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
import { PostFree } from './post_free.entity';

@Entity('comment_free')
export class CommentFree {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'int' })
  user_id: number;

  @Column({ type: 'mediumtext' })
  contents: string;

  @Column({ type: 'int' })
  post_id: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @Column({ type: 'int', nullable: true })
  comment_id: number;

  // Relationships
  @ManyToOne(() => User, (user) => user.comment_free, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn({ name: 'user_id', referencedColumnName: 'id' })
  user: User;

  @ManyToOne(() => PostFree, (posts) => posts.comments, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn({ name: 'post_id', referencedColumnName: 'id' })
  post_free: PostFree;

  @ManyToOne(() => CommentFree, (comment_free) => comment_free.comments)
  comment: CommentFree;

  @OneToMany(() => CommentFree, (comment_free) => comment_free.parent_comment)
  @JoinColumn({ name: 'comment_id', referencedColumnName: 'id' })
  comments: CommentFree[];

  @ManyToOne(() => CommentFree, (comment_free) => comment_free.comment, {
    onDelete: 'CASCADE',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn({ name: 'comment_id', referencedColumnName: 'id' })
  parent_comment: CommentFree;
}
