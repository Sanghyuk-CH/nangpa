import { css } from '@emotion/react';

export const baseCss = css`
  width: 100%;

  .ban-user-list-wrapper {
    width: 90%;
    margin: 20px auto;

    .table-wrapper {
      border: 1px solid #dce0e8;

      .table-header {
        width: 100%;
        display: flex;
        padding: 20px;

        border-bottom: 1px solid #dce0e8;
        .th {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
        }
      }
      .ban-user-list {
        width: 100%;
        display: flex;
        border-bottom: 1px solid #dce0e8;
        padding: 20px;

        .ban-user-data {
          flex: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          font-weight: bold;
        }
      }
    }
  }
`;
