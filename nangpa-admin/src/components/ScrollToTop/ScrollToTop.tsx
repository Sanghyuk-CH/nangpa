import React, { useEffect } from 'react';
/** @jsxRuntime classic */
/** @jsx jsx */
import { useLocation } from 'react-router-dom';
// @ts-ignore
declare let window;

export const ScrollToTop: React.FC = () => {
  const { pathname } = useLocation();

  useEffect(() => {
    // 기본 추적 이벤트 bg:view 추가
    if (window.bigin && window.bigin.track) {
      window.bigin.track('view');
    }
    window.scrollTo(0, 0);
  }, [pathname]);

  return null;
};
