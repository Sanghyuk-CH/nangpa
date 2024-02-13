import React, { ReactElement, useEffect, useState } from 'react';
/** @jsxRuntime classic */
/** @jsx jsx */
import { jsx } from '@emotion/react';
import { baseCss } from './WrapperModal.style';
import { Backdrop } from '../BackDrop/BackDrop';

export interface WrapperModalProps {
  isOpen: string | number | boolean;
  close?: () => void;
  type?: string;
  backgroundColor?: string;
  handleClick?: () => void;
  children?: JSX.Element | JSX.Element[];
  position?: object; // TODO: style로 이름 바꾸기
  isDialogConfirm?: boolean;
  isFitContentWidth?: boolean;
  notFixedBody?: true;
}
export const WrapperModal = (props: WrapperModalProps): ReactElement => {
  const propsObj = props;

  const [visible, setVisible] = useState<boolean>(false);

  useEffect(() => {
    if (propsObj.isOpen) {
      document.body.style.overflowY = 'scroll';
      document.body.style.width = '100%';
      if (!propsObj.notFixedBody) {
        document.body.style.position = 'fixed';
      }

      setTimeout(() => {
        setVisible(true);
      }, 100);
    } else {
      setVisible(false);
      document.body.removeAttribute('style');
    }
    return () => {
      document.body.removeAttribute('style');
    };
  }, [propsObj.isOpen]);

  return (
    <React.Fragment>
      {propsObj.isOpen && (
        <div
          className={`modal-wrap ${propsObj.type || ''} ${visible && 'visible'} ${
            propsObj?.isDialogConfirm && 'confirm-wrapper'
          } ${propsObj.isFitContentWidth ? 'fit-content-width' : ''}`}
          css={[baseCss]}
        >
          <Backdrop
            handleClick={propsObj.close}
            style={{
              zIndex: 99,
              backgroundColor: propsObj.backgroundColor ? propsObj.backgroundColor : 'rgba(0, 0, 0, 0.6)',
            }}
          />
          <div className="modal-contents" style={props.position || {}}>
            {propsObj.children ? propsObj.children : <div />}
          </div>
        </div>
      )}
    </React.Fragment>
  );
};
