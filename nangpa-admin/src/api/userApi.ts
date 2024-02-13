import axios from 'axios';

const serverUrl = `${import.meta.env.VITE_SERVER_URL}`;

interface LoginFormData {
  email: string;
  password: string;
}
export const UserApi = () => ({
  login(data: LoginFormData): Promise<any> {
    return axios.post(`${serverUrl}/auth/login`, data);
  },
});
