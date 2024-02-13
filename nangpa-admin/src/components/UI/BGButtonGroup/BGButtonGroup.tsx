import React from 'react';
/** @jsxRuntime classic */
/** @jsx jsx */
import { jsx, css } from '@emotion/react';
import styled from '@emotion/styled';

const StyledButtonGroup = styled.div(({ direction, gap, rightAlign }: ButtonGroupProps) => {
  // const marginProp = direction === 'row' ? 'marginLeft' : 'marginTop';

  return css({
    label: 'StyledButtonGroup',
    display: 'flex',
    flexDirection: direction,
    justifyContent: rightAlign ? 'flex-end' : 'flex-start',
    gap,
    // button: {
    //   '&:not(:first-of-type)': {
    //     [marginProp]: gap,
    //   },
    // },
  });
});

/**
 * - `children`은 `button` Element 만 가능합니다.
 */
export const BGButtonGroup = ({
  children,
  direction = 'row',
  rightAlign = false,
  gap = '12px',
  className,
  style = {},
}: ButtonGroupProps): JSX.Element => {
  return (
    <StyledButtonGroup className={className} direction={direction} rightAlign={rightAlign} gap={gap} style={style}>
      {children}
    </StyledButtonGroup>
  );
};

export interface ButtonGroupProps {
  children: React.ReactNode;
  /** 정렬 방향 */
  direction?: 'row' | 'column';
  /** 오른쪽 정렬 유무 */
  rightAlign?: boolean;
  /** 버튼간 간격 */
  gap?: string;
  /** 스타일 재정의를 위한 클래스 이름 */
  className?: string;
  /** 스타일 재정의를 위한 style 객체 */
  style?: object;
}

BGButtonGroup.defaultProps = {
  direction: 'row',
  rightAlign: false,
  gap: '12px',
};
