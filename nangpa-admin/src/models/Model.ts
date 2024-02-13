export interface Pagination {
  offset: number;
  limit: number;
}
export interface CreateBan {
  userId: number;
  days: number;
}

export interface ReportedPost {
  id: number;
  category: string;
  reason: string;
  post_id: number;
  isCompleted: boolean;
  report_user_id: number;
  created_at: Date;
  updated_at: Date;
}

export interface Post {
  id: number;
  title: string;
  contents: Record<string, any>[];
  created_at: Date;
  updated_at: Date;
  user_id: number;
  user_name: string;
  view_count: number;
}

export interface ReportedPostResponse {
  post: Post;
  reportPost: ReportedPost;
}

export interface DeletePost {
  category: string; // free
  id: number;
}

export interface DeletePosts {
  postIds: DeletePost[];
}

export interface UpdatePost {
  id: number;
  isCompleted: boolean;
}
export interface ReportedComment {
  id: number;
  category: string;
  reason: string;
  comment_id: number;
  isCompleted: boolean;
  report_user_id: number;
  created_at: Date;
  updated_at: Date;
}

export interface Comment {
  id: number;
  contents: string;
  created_at: Date;
  updated_at: Date;
  user_id: number;
  user_name: string;
  view_count: number;
}

export interface ReportedCommentResponse {
  reportComment: ReportedComment;
  comment: Comment;
}

export interface UpdateComment {
  id: number;
  isCompleted: boolean;
}

export interface DeleteComment {
  category: string; // free
  id: number;
}
export interface DeleteComments {
  commentsIds: DeleteComment[];
}

export interface User {
  id: number;
  nickname: string;
  phone_number: string;
  profile_img_url: string;
  created_at: Date;
  updated_at: Date;
  marketing: boolean;
}

export interface BanUser {
  id: number;
  user_id: number;
  ban_peroid: Date;
  created_at: Date;
  updated_at: Date;
  user: User;
}

export interface LoginData {
  account: string;
  password: string;
  code: string;
}

export interface SendVerifyData {
  account: string;
  password: string;
}
