import React, { useMemo } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { HeaderCss } from './Header.style';

interface NavList {
  id: number;
  name: string;
  link: string;
  external?: boolean;
}

export const Header = () => {
  const location = useLocation();

  const pathname = useMemo(() => window.location.pathname, [window.location.pathname]);

  function isMatchFullUrl(matchTargetUrl: string[]): boolean {
    return matchTargetUrl.findIndex((url) => url === location.pathname) > -1;
  }

  const isFullLayout = () => {
    const matchTargetUrl = ['/login', '/signup'];
    return isMatchFullUrl(matchTargetUrl) || false;
  };

  const navList = useMemo((): NavList[] => {
    const defaultNavList = [
      {
        id: 1,
        name: '신고 게시글',
        link: '/reported/posts',
      },
      {
        id: 2,
        name: '신고 댓글',
        link: '/reported/comments',
      },
      {
        id: 3,
        name: '밴 유저',
        link: '/ban/user',
      },
    ];

    return defaultNavList;
  }, []);

  return !isFullLayout() ? (
    <header className="Header" css={HeaderCss}>
      <div className="header-wrapper">
        <Link to="/" className="logo-area">
          냉파
        </Link>
      </div>
      <nav className="navigate-wrapper">
        {navList.map((list) => {
          return list.external ? (
            <div
              className={`nav-btn ${pathname === list.link ? 'active' : ''}`}
              key={list.id}
              onClick={() => {
                window.open(list.link, '_blank');
              }}
            >
              <div className="nav-btn">{list.name}</div>
            </div>
          ) : (
            <Link to={list.link} className={`nav-btn ${pathname === list.link ? 'active' : ''}`} key={list.id}>
              <div className="nav-btn">{list.name}</div>
            </Link>
          );
        })}
      </nav>
    </header>
  ) : (
    <React.Fragment />
  );
};
