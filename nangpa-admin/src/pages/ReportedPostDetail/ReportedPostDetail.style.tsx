import { css } from '@emotion/react';

export const baseCss = css`
  width: 90%;
  padding: 20px;
  margin: 20px auto;

  border: 1px solid #dce0e8;
  border-radius: 20px;
  .header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    .button-wrapper {
      display: flex;
      gap: 20px;
    }
    button {
      width: 100px;
      height: 40px;

      &.isCompleted {
        background-color: black;
      }
      &.removeBtn {
        background-color: red;
      }
      &.banBtn {
        background-color: orange;
      }
    }
  }

  .modal {
    input {
      border: 1px solid #dce0e8;
    }
    .btn-wrapper {
      margin-top: 20px;
      width: 240px;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }
  }
`;
