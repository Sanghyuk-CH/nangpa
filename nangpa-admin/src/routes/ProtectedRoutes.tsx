import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import LocalStorage from '../services/LocalStorage';

interface PrivateRouteProps {
  children: JSX.Element;
}
export const ProtectedRoutes = (props: PrivateRouteProps) => {
  const navigate = useNavigate();
  const isAdminLoggedIn = LocalStorage.token !== null; // 어드민이 로그인되었다고 가정합니다.

  const adminGuardPolicy = () => {
    if (!isAdminLoggedIn) {
      // no admin
      navigate('/login');
    }
  };

  useEffect(() => {
    adminGuardPolicy();
  }, []);

  return props.children;
};
