import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('super_user')
export class SuperUser {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 45 })
  account: string;

  @Column({ type: 'varchar', length: 200 })
  password: string;

  @Column({ type: 'varchar', length: 45 })
  email: string;
}
