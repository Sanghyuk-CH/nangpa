import { css } from '@emotion/react';

export const HeaderCss = css`
  width: 100%;
  padding: 20px 20px 0;
  border-bottom: 1px solid #dce0e8;
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: sticky;
  top: 0;
  z-index: 1000;
  background: #fff;

  .header-wrapper {
    .logo-area {
      font-weight: bold;
      font-size: 32px;
      color: #2f2f2f;
      text-decoration: none;
      cursor: pointer;
    }
  }

  .navigate-wrapper {
    display: flex;
    gap: 20px;
    .nav-btn {
      text-decoration: none;
      color: #2f2f2f;
      padding: 6px;

      &.active {
        border-bottom: 1px solid #2f2f2f;
        font-weight: bold;
      }
    }
  }
`;
