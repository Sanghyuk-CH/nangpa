import { css } from '@emotion/react';

export const baseCss = css`
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  position: fixed;
  z-index: 1002;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  transition: 0.5s cubic-bezier(0.33, 1, 0.68, 1);
  opacity: 0;

  &.confirm-wrapper {
    .modal-contents {
      max-width: 640px;
      box-sizing: border-box;
    }
  }

  &.fit-content-width {
    .modal-contents {
      width: fit-content;
      box-sizing: border-box;
    }
  }

  &.visible {
    opacity: 1;
  }

  &:not(.visible) {
    opacity: 0;
  }

  &.header {
    .modal-contents {
      left: 0;
      position: absolute;
      z-index: 100;
      top: 108px;
      padding: 0;
      border-radius: 0 0 8px 8px;
      border: none;
      box-shadow: 0 8px 36px 0 rgba(79, 86, 97, 0.1);
    }
  }
  .modal-contents {
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.1);
    border: solid 1px #ededf2;
    background-color: #ffffff;
    overflow: auto;
    width: 640px;
    max-height: 710px;
    z-index: 100;
    box-sizing: border-box;
  }

  &.twofactor {
    .modal-contents {
      width: 360px;
    }
  }

  @media (max-width: 780px) {
    &.confirm-wrapper {
      .modal-contents {
        max-width: 100%;
        box-sizing: border-box;
      }
    }

    .modal-contents {
      width: 320px;
    }
  }
`;
