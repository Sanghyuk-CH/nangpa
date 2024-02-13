import { css } from '@emotion/react';

export const baseCss = css`
  width: auto;
  .dialog-confirm-content {
    margin-bottom: 20px;
    .dialog-confirm-title {
      font-size: 24px;
      font-weight: bold;
      line-height: 1.33;
      color: #222233;
      margin-bottom: 8px;
    }
    .dialog-confirm-desc {
      font-size: 14px;
      line-height: 1.5;
      color: #53585f;
      white-space: pre-wrap;
    }
  }
  .dialog-confirm-button {
    display: flex;
    justify-content: flex-end;
    align-items: center;
  }
`;
