import React, { MouseEvent, ReactElement } from 'react';

/** @jsxRuntime classic */
/** @jsx jsx */
import { jsx, css } from '@emotion/react';

const baseCss = css`
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  width: 100%;
  height: 100%;
`;

export interface BackdropProps {
  handleClick?: (event: MouseEvent<HTMLDivElement>) => void;
  style?: Object;
}

export const Backdrop = ({ handleClick, style }: BackdropProps): ReactElement => {
  return <div className="bg-backdrop" onClick={handleClick} style={style} css={[baseCss]} />;
};
