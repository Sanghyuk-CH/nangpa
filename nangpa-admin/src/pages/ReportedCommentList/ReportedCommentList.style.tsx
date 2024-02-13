import { css } from '@emotion/react';

export const ReportedCommentListCss = css`
  width: 100%;
  padding-top: 30px;
  .table-wrapper {
    width: 90%;
    margin: 0 auto;
    white-space: pre;
    color: black;

    border: 1px solid #dce0e8;

    .table-header {
      display: flex;
      padding: 20px;
      border-bottom: 1px solid #dce0e8;
      border-right: 1px solid #dce0e8;

      .th {
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;

        &:nth-of-type(1) {
          width: 25%;
        }
        &:nth-of-type(2) {
          width: 25%;
        }
        &:nth-of-type(3) {
          width: 25%;
        }
        &:nth-of-type(4) {
          width: 25%;
        }
      }
    }

    a {
      text-decoration: none;
    }
    .reported-post-list {
      display: flex;
      padding: 20px;
      border-bottom: 1px solid #dce0e8;
      color: black;

      .reported-post-data {
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        overflow: hidden;
        text-overflow: ellipsis;
        &:nth-of-type(1) {
          width: 25%;
        }
        &:nth-of-type(2) {
          width: 25%;
        }
        &:nth-of-type(3) {
          width: 25%;
        }
        &:nth-of-type(4) {
          width: 25%;
        }
      }
      &.removed {
        background-color: #dce0e8;
        color: grey;

        .reported-post-data {
          &:nth-of-type(1) {
            width: 20%;
          }
          &:nth-of-type(2) {
            width: 20%;
          }
          &:nth-of-type(3) {
            width: 20%;
          }
          &:nth-of-type(4) {
            width: 20%;
          }
          &:nth-of-type(5) {
            width: 20%;
          }
        }
      }
    }
  }

  .button-wrapper {
    margin-top: 40px;
    display: flex;
    gap: 40px;
    align-items: center;
    justify-content: center;
    button {
      min-width: 100px;
      max-width: 10%;
    }
  }
`;
