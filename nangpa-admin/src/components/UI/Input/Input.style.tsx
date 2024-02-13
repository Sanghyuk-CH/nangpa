import { css, SerializedStyles, Theme } from '@emotion/react';

export const InputWrapperCSS = () => {
  return css`
    *:focus {
      outline: none;
    }

    input {
      border: none;
    }

    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    transition: 0.3s cubic-bezier(0.33, 1, 0.68, 1);
    width: 100%;
    height: 36px;
    padding: 0 8px;
    border: solid 1px #dce0e8;
    border-radius: 8px;
    box-sizing: border-box;
    background-color: #f9fafb;

    font-size: 14px;
    color: #3d4046;

    .max-length-wrapper {
      display: none;
    }

    &:hover {
      cursor: pointer;
      border: solid 1px #b8beca;
      color: #3d4046;
    }

    &:focus-within {
      cursor: text;
      border: solid 1px #3399ff;
      color: #3d4046;

      .max-length-wrapper {
        display: flex;
      }
    }

    &.isDisabled {
      pointer-events: none;
      border: solid 1px #dce0e8;
      background-color: #ebeef2;
      color: #99a0a9;

      input {
        background-color: #ebeef2;
        color: #99a0a9;
      }
    }

    &.isError {
      border: solid 1px #e65c5c !important;
    }

    input {
      width: 100%;
      height: 100%;
      background-color: #f9fafb;
      color: #3d4046;
      box-sizing: border-box;
      border-radius: 8px;

      &::placeholder {
        color: #9ea5af;
      }

      &:hover {
        cursor: pointer;
        color: #3d4046;
      }

      &:focus {
        cursor: text;
        color: #3d4046;
      }

      &:-webkit-autofill,
      &:-webkit-autofill:hover,
      &:-webkit-autofill:focus,
      &:-webkit-autofill:active {
        transition: background-color 5000s ease-in-out 0s;
        -webkit-transition: background-color 9999s ease-out;
        -webkit-box-shadow: 0 0 0px 1000px #f9fafb inset !important;
        -webkit-text-fill-color: #3d4046 !important;
      }
    }
  `;
};
