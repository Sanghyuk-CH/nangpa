import React, { InputHTMLAttributes, ReactElement, useState, useEffect } from 'react';
/** @jsxRuntime classic */
/** @jsx jsx */
import { css, jsx, SerializedStyles } from '@emotion/react';
import _ from 'lodash';
import { InputWrapperCSS } from './Input.style';

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  className?: string;
  style?: object;
}

export interface BGInputProps {
  /** HTMLInputElement 속성 */
  inputProps: InputProps;
  /** error 상태 */
  error?: boolean;
  /** 커스텀 글자수 */
  customLength?: number;
  /** 커스텀 최대 글자수 */
  customLengthLimit?: number;
  /** 글자수 단위 ex: 자, byte */
  lengthUnit?: string;
  /** input text 입력창 기준 왼쪽에 배치되는 엘리먼트 */
  leftLabelComponent?: JSX.Element | string;
  /** input text 입력창 기준 오른쪽에 배치되는 엘리먼트 */
  rightLabelComponent?: JSX.Element | string;
  /** 글자수, 최대 글자수 노출 여부 */
  noShowLength?: boolean;
  /** 스타일 재정의를 위한 className */
  className?: string;
  /** 스타일 재정의를 위한 style 객체 */
  style?: object;
  /** 스타일 재정의를 위한 emotion css 객체 */
  css?: SerializedStyles;
}

export const BDSInput = React.forwardRef((props: BGInputProps, ref: React.Ref<HTMLInputElement>): ReactElement => {
  const {
    inputProps = {},
    className = '',
    css: wrapperCSS,
    style = {},
    error = false,
    customLength,
    customLengthLimit,
    lengthUnit,
    leftLabelComponent,
    rightLabelComponent,
  } = props;
  const {
    className: inputClassName = '',
    style: inputStyle = {},
    placeholder = '',
    disabled = false,
    type = 'text',
    defaultValue,
    value,
    name,
    id,
    autoComplete = 'on',
  } = inputProps;

  const [valueLength, setValueLength] = useState<number>(defaultValue?.toString()?.length || 0);

  useEffect(() => {
    setValueLength(value?.toString()?.length || 0);
  }, [value]);

  return (
    <div
      style={style}
      className={`${className} ${disabled ? 'isDisabled' : ''} ${error ? 'isError' : ''}`}
      css={[InputWrapperCSS, wrapperCSS]}
    >
      {leftLabelComponent && <React.Fragment>{leftLabelComponent}</React.Fragment>}
      <input
        {...inputProps}
        ref={ref}
        className={inputClassName}
        style={inputStyle}
        type={type}
        placeholder={placeholder}
        name={name}
        id={id}
        autoComplete={autoComplete}
        onChange={(event) => {
          if (inputProps.onChange) {
            inputProps.onChange(event);
          }
        }}
      />
      {rightLabelComponent && <React.Fragment>{rightLabelComponent}</React.Fragment>}
      {!props?.noShowLength && !_.isNil(inputProps.maxLength) && (
        <div
          className="max-length-wrapper"
          css={css`
            white-space: nowrap;
            font-size: 10px;
            font-weight: normal;
            font-stretch: normal;
            font-style: normal;
            letter-spacing: normal;
            color: #626871;
          `}
        >
          <React.Fragment>
            {valueLength}/{inputProps.maxLength}
          </React.Fragment>
          {lengthUnit && <React.Fragment>{lengthUnit}</React.Fragment>}
        </div>
      )}

      {!props?.noShowLength &&
        _.isNil(inputProps.maxLength) &&
        !_.isNil(customLength) &&
        !_.isNil(customLengthLimit) && (
          <div
            className="max-length-wrapper"
            css={css`
              white-space: nowrap;
              font-size: 10px;
              font-weight: normal;
              font-stretch: normal;
              font-style: normal;
              letter-spacing: normal;
              color: #626871;
            `}
          >
            <React.Fragment>
              {customLength}/{customLengthLimit}
            </React.Fragment>
            {lengthUnit && <React.Fragment>{lengthUnit}</React.Fragment>}
          </div>
        )}
    </div>
  );
});
