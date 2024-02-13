import React, { ReactElement } from 'react';
/** @jsxRuntime classic */
/** @jsx jsx */
import { jsx, css } from '@emotion/react';
import { baseCss } from './DialogConfirm.style';
import { BGButtonGroup } from '../UI/BGButtonGroup/BGButtonGroup';
import { BDSButton } from '../UI/BDSButton/BDSButton';

export type Button = {
  label: string;
  handleClick?: () => void;
  appearance?: string;
  disabled?: boolean;
};

export interface DialogConfirmProps {
  style?: object;
  title: string;
  desc: string | JSX.Element;
  buttons?: Array<Button>;
}
export const DialogConfirm = (props: DialogConfirmProps): ReactElement => {
  const themeCss = css`
    background-color: #ffff;
  `;
  return (
    <div className="dialog-confirm-container" css={[baseCss, themeCss]} style={props.style || {}}>
      <div className="dialog-confirm-content">
        <div className="dialog-confirm-title">{props.title}</div>
        <div className="dialog-confirm-desc">{props.desc}</div>
      </div>
      <BGButtonGroup rightAlign>
        {props.buttons &&
          props.buttons.map((button) => (
            <BDSButton
              key={button.label}
              label={button.label}
              onClick={button.handleClick}
              appearance={button.appearance || ''}
            />
          ))}
      </BGButtonGroup>
    </div>
  );
};
