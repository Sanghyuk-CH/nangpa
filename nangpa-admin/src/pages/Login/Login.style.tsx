import styled from '@emotion/styled';

export const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  width: 100%;
  height: 100%;
`;

export const Form = styled.form`
  display: flex;
  flex-direction: column;
  max-width: 400px;
  gap: 1rem;
  width: 100%;
  border: 2px solid #dce0e8;
  padding: 16px;
`;

export const InputWrapper = styled.div`
  display: flex;
  flex-direction: column;

  .password-wrapper {
    position: relative;
    width: 100%;

    button {
      position: absolute;
      top: 50%;
      right: 10px;
      transform: translateY(-50%);
    }
  }

  input {
    width: 100%;
    border: 1px solid #dce0e8;
    border-radius: 4px;
    padding: 0.5rem;
    transition: border-color 0.3s;

    &:hover {
      border-color: #0070f3;
    }

    &:focus {
      border-color: #0070f3;
      outline: none;
    }

    &.error {
      border-color: #e00;
    }
  }
`;

export const ErrorMessage = styled.p`
  color: #e00;
  font-size: 0.8rem;
  margin-top: 4px;
`;

export const Button = styled.button`
  background-color: #0070f3;
  border: none;
  border-radius: 4px;
  color: white;
  cursor: pointer;
  font-size: 1rem;
  padding: 0.5rem 1rem;
  text-align: center;
  text-decoration: none;
  width: 100%;

  &:hover {
    background-color: #0366d6;
  }

  &.isDisabled {
    background-color: #dce0e8;
    color: grey;
  }
`;
