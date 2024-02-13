import { css } from '@emotion/react';

export const baseCss = css`
  width: fit-content;
  height: 36px;
  padding: 8px 12px;
  border-radius: 8px;
  transition: 0.3s cubic-bezier(0.33, 1, 0.68, 1);
  box-shadow: 0 4px 16px -4px rgba(0, 104, 255, 0.4);
  background-color: #006fff;
  font-size: 14px;
  font-weight: bold;
  font-stretch: normal;
  font-style: normal;
  letter-spacing: normal;
  line-height: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  color: #ffffff;
  border: none;

  &:hover {
    background-color: #0059d9;
  }

  &:active {
    background-color: #004ec0;
  }

  p {
    white-space: nowrap;
    padding: 0;
    margin: 0;
  }

  img {
    width: 20px;
    height: 20px;
  }

  &.icon {
    padding: 8px;
  }

  &.isDisabled {
    background-color: #ebeef2;
    box-shadow: unset;
    font-weight: bold;
    color: #99a0a9;
    cursor: default !important;
  }

  &.destructive {
    color: #53585f;
    background-color: #ffffff;
    border: solid 1px #b1bbca;
    border-radius: 8px;
    box-shadow: unset;
    font-weight: normal;
    &.active {
      background-color: #f7f7fa;
      color: #e65c5c;
      text-decoration: unset;
    }
  }

  &.out-line {
    box-shadow: unset;
    border: 1px solid #d4d9e2;
    background-color: unset;
    color: #53585f;
    &.active {
      background-color: unset;
    }
    &:hover {
      border: solid 1px #d4d9e2;
      background-color: #edf1f6;
    }
  }

  &.out-line-positive {
    box-shadow: unset;
    padding: 8px 12px;
    border-radius: 8px;
    border: solid 1px #b1bbca;
    background-color: #fff;
    color: #53585f;
    &.active {
      background-color: #fff;
    }
  }
  &.out-line-destructive {
    box-shadow: 0 4px 16px -4px rgba(62, 82, 204, 0.4);
    border: solid 1px #e65c5c;
    background-color: unset;
    color: #53585f;
  }
  &.no-line-destructive {
    box-shadow: none;
    border-radius: 8px;
    background-color: #f9fafb;
    color: #53585f;
  }

  &.secondary {
    box-shadow: none;
    background-color: #ffffff;
    border: solid 1px #d4d9e2;
    border-radius: 8px;
    font-size: 14px;
    font-weight: bold;
    text-align: center;
    color: #53585f;

    &:hover {
      border: solid 1px #c7cfdc;
      background-color: #edf1f6;
    }

    &:active {
      background-color: #edf1f6;
    }

    &.isDisabled {
      border: solid 1px transparent;
      background-color: #ebeef2;
      box-shadow: unset;
      font-weight: bold;
      color: #99a0a9;
      cursor: default !important;
    }
  }

  &.danger {
    color: #fff;
    background-color: #e65c5c;
    border: solid 1px #e65c5c;
    border-radius: 8px;
    box-shadow: unset;

    &:active {
      background-color: #004ec0;
    }

    &:hover {
      border: solid 1px #da4b4b;
      background-color: #da4b4b;
    }
  }
  &.primary-alt {
    box-shadow: none;
    border: 1px solid rgba(1, 1, 1, 0.1);
    background: linear-gradient(0deg, rgba(51, 153, 255, 0.1), rgba(51, 153, 255, 0.1)), #ffffff;
    color: #3399ff;
    &.active,
    &:hover {
      background: linear-gradient(0deg, rgba(51, 153, 255, 0.18), rgba(51, 153, 255, 0.18)), #ffffff;
      border: 1px solid rgba(0, 0, 0, 0.1);
    }
  }
`;
