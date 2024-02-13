import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Unique,
  OneToOne,
} from 'typeorm';
import { PostFree } from './post_free.entity';
import { CommentFree } from './comment_free.entity';
import { BanUser } from './admin/ban_user.entity';

@Entity('user')
@Unique('UQ_phone_number', ['phone_number'])
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 45 })
  nickname: string;

  @Column({ type: 'varchar', length: 200 })
  password: string;

  @Column({ type: 'varchar', length: 45 })
  phone_number: string;

  @Column({ type: 'varchar', nullable: true })
  profile_img_url: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @Column({ type: 'boolean' })
  marketing: boolean;

  // Relationships
  @OneToMany(() => PostFree, (post_free) => post_free.user)
  post_free: PostFree[];

  @OneToMany(() => CommentFree, (comment_free) => comment_free.user)
  comment_free: CommentFree[];

  @OneToOne(() => BanUser, (banUser) => banUser.user, { nullable: true })
  banUser: BanUser | null;
}
