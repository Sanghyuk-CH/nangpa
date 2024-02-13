/* eslint-disable no-nested-ternary */
import React from 'react';
import { StyledLoadingSpinnerWrapper } from './BGLoadingSpinner.style';

export interface BGLoadingSpinnerProps {
  isLoading: boolean;
  isInfiniteListSpinner?: boolean;
  style?: Object;
  children: React.ReactChild;
  noChildView?: boolean;
}

export const BGLoadingSpinner = ({
  isLoading,
  isInfiniteListSpinner = false,
  style = {},
  children,
  noChildView = false,
}: BGLoadingSpinnerProps): JSX.Element => {
  return (
    <StyledLoadingSpinnerWrapper isInfiniteListSpinner={isInfiniteListSpinner} style={style} noChildView={noChildView}>
      {isLoading && (
        <div className="unit-loading" data-testid="isLoading">
          <div className="spinner-wrap">
            <div className="circle" />
            <div className="circle" />
            <div className="circle" />
          </div>
        </div>
      )}
      {children}
    </StyledLoadingSpinnerWrapper>
  );
};

export default BGLoadingSpinner;
