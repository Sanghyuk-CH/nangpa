import { Category } from 'src/dto/post.dto';
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('report_comment')
export class ReportComment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'int' })
  report_user_id: number;

  @Column({ type: 'varchar' })
  category: Category;

  @Column({ type: 'int' })
  comment_id: number;

  @Column({ type: 'varchar' })
  reason: string;

  @Column({ type: 'boolean', default: false })
  isCompleted: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
