import React, { ButtonHTMLAttributes, ReactElement, useState } from 'react';

/** @jsxRuntime classic */
/** @jsx jsx */
import { jsx } from '@emotion/react';
import { baseCss } from './BDSButton.style';

export interface BGButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** 버튼 appearance */
  appearance?:
    | 'destructive'
    | 'out-line-positive'
    | 'out-line-destructive'
    | 'secondary'
    | 'danger'
    | 'no-line-destructive'
    | 'large'
    | 'primary-alt'
    | string;
  /** 버튼 label */
  label?: string;
  /** 버튼 내 삽입 이미지 이름 */
  icon?: string;
  /** 버튼 내 삽입 이미지 위치 */
  iconAlign?: 'left' | 'right';
  /** 버튼 내 삽입 BGFontIcon 위치 */
  fontIconAlign?: 'left' | 'right';
  /** 버튼 비활성화 여부 */
  isDisabled?: boolean;
  /** 버튼 onClick */
  onClick?: (e?: any) => void;
  /** 스타일 재정의를 위한 style 객체 */
  style?: object;
  /** children Element */
  children?: ReactElement;
  hoverable?: boolean;
}

export const BDSButton = (props: BGButtonProps): ReactElement => {
  const {
    icon,
    iconAlign = 'left',
    label,
    style,
    onClick,
    isDisabled = false,
    appearance = 'primary',
    type,
    className,
    hoverable = true,
    children,
    ...rest
  } = props;
  const classNames = className ? ['bg-button'].concat(className.split(' ')) : ['bg-button'];

  const [isOver, setIsOver] = useState(false);

  if (hoverable && isOver) classNames.push('active');

  return (
    <button
      {...rest}
      css={[baseCss]}
      style={style || {}}
      type={type ? 'submit' : 'button'}
      onMouseEnter={() => setIsOver(true)}
      onMouseLeave={() => setIsOver(false)}
      onClick={(e: any) => {
        if (onClick) return onClick(e);
        return e;
      }}
      disabled={isDisabled}
      className={`${isDisabled ? 'isDisabled' : appearance} ${icon && 'icon'} ${classNames.join(' ')}`}
    >
      {iconAlign === 'left' && <React.Fragment>{icon ? <img src={`${icon}`} alt="icon" /> : null}</React.Fragment>}
      {label && <p>{label}</p>}
      {iconAlign === 'right' && <React.Fragment>{icon ? <img src={`${icon}`} alt="icon" /> : null}</React.Fragment>}
      {children}
    </button>
  );
};
