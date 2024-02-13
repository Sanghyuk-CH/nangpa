/* eslint-disable jsx-a11y/label-has-associated-control */
import React, { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useMutation } from 'react-query';
import { FiEye, FiEyeOff } from 'react-icons/fi';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Button, Container, ErrorMessage, Form, InputWrapper } from './Login.style';
import LocalStorage from '../../services/LocalStorage';
import { AdminApi } from '../../api/adminApi';
import { LoginData } from '../../models/Model';

export const Login = () => {
  const {
    register,
    handleSubmit,
    getValues,
    formState: { errors },
  } = useForm<LoginData>();
  const navigate = useNavigate();
  const i18next = useTranslation();

  const [passwordState, setPasswordState] = useState<'visible' | 'hidden'>('hidden');

  const mutation = useMutation(
    async (data: LoginData) => {
      const response = await AdminApi().login(data);
      return response;
    },
    {
      onSuccess: () => {
        navigate('/');
      },
      onError: () => {
        alert(i18next.t('로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.'));
      },
    },
  );

  const onSubmit = (data: LoginData) => {
    mutation.mutate(data);
  };

  const togglePasswordVisibility = () => {
    setPasswordState(passwordState === 'hidden' ? 'visible' : 'hidden');
  };

  useEffect(() => {
    if (LocalStorage.token) {
      navigate('/');
    }
  }, []);

  return (
    <Container>
      <h2>Login</h2>
      <Form onSubmit={handleSubmit(onSubmit)}>
        <InputWrapper>
          <label htmlFor="account">Account:</label>
          <input
            id="account"
            type="account"
            {...register('account', {
              required: '계정을 입력하세요',
            })}
          />
          {errors.account && <ErrorMessage>{errors.account.message}</ErrorMessage>}
        </InputWrapper>
        <InputWrapper>
          <label htmlFor="password">Password:</label>
          <div className="password-wrapper">
            <input
              className={errors.password ? 'error' : ''}
              id="password"
              type={passwordState === 'hidden' ? 'password' : 'text'}
              {...register('password', { required: '비밀번호를 입력해주세요.' })}
            />
            <button
              tabIndex={-100}
              type="button"
              onClick={togglePasswordVisibility}
              style={{ background: 'none', border: 'none', cursor: 'pointer' }}
            >
              {passwordState === 'hidden' ? <FiEyeOff /> : <FiEye />}
            </button>
          </div>
          {errors.password && <ErrorMessage>{errors.password.message}</ErrorMessage>}
        </InputWrapper>
        <Button
          type="button"
          onClick={() => {
            AdminApi().sendVerifyCode({ account: getValues('account'), password: getValues('password') });
          }}
        >
          코드 받기
        </Button>
        <InputWrapper>
          <label htmlFor="code">CODE:</label>
          <div className="password-wrapper">
            <input
              className={errors.code ? 'error' : ''}
              id="code"
              {...register('code', { required: '코드를 입력해주세요.' })}
            />
          </div>
          {errors.code && <ErrorMessage>{errors.code.message}</ErrorMessage>}
        </InputWrapper>
        <Button type="submit">Login</Button>
      </Form>
    </Container>
  );
};
