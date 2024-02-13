import axios from 'axios';
import {
  BanUser,
  CreateBan,
  DeleteComments,
  DeletePosts,
  LoginData,
  Pagination,
  ReportedCommentResponse,
  ReportedPostResponse,
  SendVerifyData,
  UpdateComment,
  UpdatePost,
} from '../models/Model';

const serverUrl = `${import.meta.env.VITE_SERVER_URL}/admin`;

export const AdminApi = () => ({
  getReportedPostList(data: Pagination): Promise<ReportedPostResponse[]> {
    return axios.post(`${serverUrl}/get-reported-posts`, { page: data.offset, row: data.limit });
  },
  deletePost(data: DeletePosts): Promise<void> {
    return axios.delete(`${serverUrl}/delete-reported-posts`, {
      data,
    });
  },

  modifyCompletePost(data: UpdatePost): Promise<void> {
    return axios.put(`${serverUrl}/update-reported-posts`, {
      ...data,
    });
  },

  getReportedCommentList(data: Pagination): Promise<ReportedCommentResponse[]> {
    return axios.post(`${serverUrl}/get-reported-comments`, { page: data.offset, row: data.limit });
  },

  deleteComment(data: DeleteComments): Promise<void> {
    return axios.delete(`${serverUrl}/delete-reported-comments`, {
      data,
    });
  },

  modifyCompleteComment(data: UpdateComment): Promise<void> {
    return axios.put(`${serverUrl}/update-reported-comments`, {
      ...data,
    });
  },

  createBan(data: CreateBan): Promise<void> {
    return axios.post(`${serverUrl}/ban-user`, { ...data });
  },

  getAllBanList(): Promise<BanUser[]> {
    return axios.get(`${serverUrl}/ban-user`);
  },

  login(data: LoginData) {
    return axios.post(`${serverUrl}/login`, { ...data });
  },

  sendVerifyCode(data: SendVerifyData): Promise<void> {
    return axios.post(`${serverUrl}/send-admin-verify-code`, { ...data });
  },
});
