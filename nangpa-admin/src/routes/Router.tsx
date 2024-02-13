import React from 'react';
import { Navigate, Routes, Route } from 'react-router-dom';
import { Global } from '../components/Global/Global';
import { Header } from '../components/Header/Header';
import { useInterceptor } from '../hooks/useInterceptor';
import { BanUserList } from '../pages/BanUserList/BanUserList';
import { Home } from '../pages/Home/Home';
import { Login } from '../pages/Login/Login';
import { ReportedCommentDetail } from '../pages/ReportedCommentDetail/ReportedCommentDetail';
import { ReportedCommentList } from '../pages/ReportedCommentList/ReportedCommentList';
import { ReportedPostDetail } from '../pages/ReportedPostDetail/ReportedPostDetail';
// import { Login } from '../pages/Login/Login';
import { ReportedPostList } from '../pages/ReportedPostList/ReportedPostList';
import { ProtectedRoutes } from './ProtectedRoutes';
// import { Signup } from '../pages/Signup/Signup';

export const Router = () => {
  useInterceptor();
  return (
    <React.Fragment>
      <Header />
      <Routes>
        <Route path="/*" element={<Navigate to="/" />} />
        <Route path="/login" element={<Login />} />
        <Route
          path="/"
          element={
            <ProtectedRoutes>
              <Home />
            </ProtectedRoutes>
          }
        />
        <Route
          path="/reported/posts"
          element={
            <ProtectedRoutes>
              <ReportedPostList />
            </ProtectedRoutes>
          }
        />
        <Route
          path="/reported/posts/:id"
          element={
            <ProtectedRoutes>
              <ReportedPostDetail />
            </ProtectedRoutes>
          }
        />
        <Route
          path="/reported/comments"
          element={
            <ProtectedRoutes>
              <ReportedCommentList />
            </ProtectedRoutes>
          }
        />
        <Route
          path="/reported/comments/:id"
          element={
            <ProtectedRoutes>
              <ReportedCommentDetail />
            </ProtectedRoutes>
          }
        />
        <Route
          path="/ban/user"
          element={
            <ProtectedRoutes>
              <BanUserList />
            </ProtectedRoutes>
          }
        />
      </Routes>
      <Global />
    </React.Fragment>
  );
};
