import { keyframes } from '@emotion/react';
import styled from '@emotion/styled';

const bounce = keyframes`
  from {
    opacity: 0.6;
    transform: translate3d(0, 0rem, 0);
  }
  25% {
    opacity: 1;
    transform: translate3d(0, 0.3rem, 0);
  }
  50% {
    opacity: 0.6;
    transform: translate3d(0, 0rem, 0);
  }
  75% {
    opacity: 0.3;
    transform: translate3d(0, -0.3rem, 0);
  }
  to {
    opacity: 0.6;
    transform: translate3d(0, 0rem, 0);
  }
`;

export const StyledLoadingSpinnerWrapper = styled.div<{ isInfiniteListSpinner: boolean, noChildView: boolean }>`
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  position: relative;
  border-radius: 10px;

  .unit-loading {
    position: absolute;
    box-sizing: border-box;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: ${(props) => (props.isInfiniteListSpinner ? 'flex-end' : 'center')};
    justify-content: center;
    z-index: 1;
    background: rgba(255, 255, 255, ${(props) => props.noChildView ? 1 : 0.9});
    border-radius: 10px;

    &.hide {
      display: none;
    }
    .spinner-wrap {
      display: flex;
      justify-content: center;
      margin-bottom: ${(props) => (props.isInfiniteListSpinner ? '100px' : 0)};
      .circle {
        width: 0.5rem;
        height: 0.5rem;
        margin: 2rem 0.3rem;
        background: #006fff;
        border-radius: 50%;
        animation: ${bounce} 0.9s infinite linear;

        &:nth-of-type(2) {
          animation-delay: 0.3s;
        }

        &:nth-of-type(3) {
          animation-delay: 0.6s;
        }
      }
    }
  }
`;
