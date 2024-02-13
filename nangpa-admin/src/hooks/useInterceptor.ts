import { useEffect } from 'react';
import axios, { AxiosResponse } from 'axios';

import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { useDialog } from './useDialog';
import LocalStorage from '../services/LocalStorage';

export const useInterceptor = () => {
  const { showMessage } = useDialog();

  const i18next = useTranslation();
  const navigate = useNavigate();

  const logout = () => {
    LocalStorage.clear();
    showMessage(i18next.t('알림'), i18next.t('로그인이 만료되었습니다.'));
    navigate('/login');
  };
  const requestHandler = async (config: any) => {
    if (LocalStorage.token) {
      return {
        ...config,
        headers: {
          Authorization: `Bearer ${LocalStorage.token}`,
        },
      };
    }
    return { ...config };
  };

  const responseHandler = (response: AxiosResponse) => {
    // @ts-ignore
    const token = response.headers.get('Authorization');
    if (token) {
      // eslint-disable-next-line prefer-destructuring
      LocalStorage.token = token.split(' ')[1];
    }
    if (response.data) {
      return response.data;
    }
    return response;
  };

  const errorHandler = (error: any) => {
    let err = error;
    if (error.response) {
      err = error.response;
    }
    if (err.status >= 500 && err.status < 600) {
      // Ads error handler
      showMessage(i18next.t('알림'), i18next.t('잠시 후 다시 시도해주세요.'));
      throw err;
    }

    switch (err.status) {
      case 401:
        logout();
        throw err;
      default:
        throw err;
    }
  };

  const requestInterceptor = axios.interceptors.request.use(requestHandler);

  const responseInterceptor = axios.interceptors.response.use(
    (response: any) => responseHandler(response),
    (error) => errorHandler(error),
  );

  useEffect(() => {
    return () => {
      axios.interceptors.request.eject(requestInterceptor);
      axios.interceptors.response.eject(responseInterceptor);
    };
  }, [responseInterceptor, requestInterceptor]);
};
