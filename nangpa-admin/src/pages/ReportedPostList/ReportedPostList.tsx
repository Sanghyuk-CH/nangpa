import React, { useMemo, useState } from 'react';
import 'react-datepicker/dist/react-datepicker.css';
import { useQuery } from 'react-query';
import { Link } from 'react-router-dom';
import { AdminApi } from '../../api/adminApi';
import BGLoadingSpinner from '../../components/BGLoadingSpinner/BGLoadingSpinner';
import { ReportedPostResponse } from '../../models/Model';
import { formatDate } from '../../utils/date';
import { Button } from '../Login/Login.style';
import { baseCss } from './ReportedPostList.style';

export const ReportedPostList = () => {
  const [offset, setOffset] = useState<number>(1);
  const [reportedPostList, setReportedPostList] = useState<ReportedPostResponse[]>([]);
  const limit = useMemo(() => 10, []);

  const { isLoading } = useQuery(
    ['getReportedPostList', offset],
    () => {
      return AdminApi().getReportedPostList({ offset, limit });
    },
    {
      onSuccess: (data) => {
        setReportedPostList(data);
      },
      onError: (err) => {
        console.log(err);
      },
    },
  );

  const handleNext = () => {
    setOffset(offset + 1);
  };

  const handlePrev = () => {
    if (offset > 1) setOffset(offset - 1);
  };

  return (
    <div css={baseCss}>
      <BGLoadingSpinner isLoading={isLoading}>
        <div className="reported-post-list-wrapper">
          <div className="table-wrapper">
            <div className="table-header">
              <div className="th">생성일</div>
              <div className="th">수정일</div>
              <div className="th">이유</div>
              <div className="th">게시물제목</div>
              <div className="th">확인상태</div>
            </div>
            {reportedPostList.map((postData) => {
              return postData.post ? (
                <Link
                  to={`/reported/posts/${postData.reportPost.id}`}
                  state={{ postData }}
                  key={postData.reportPost.id}
                >
                  <div className="reported-post-list">
                    <div className="reported-post-data">{formatDate(new Date(postData.reportPost.created_at))}</div>
                    <div className="reported-post-data">{formatDate(new Date(postData.reportPost.updated_at))}</div>
                    <div className="reported-post-data">{postData.reportPost.reason}</div>
                    <div className="reported-post-data">{postData.post.title}</div>
                    <div className="reported-post-data">
                      {postData.reportPost.isCompleted ? '확인 완료' : '확인 안된상태'}
                    </div>
                  </div>
                </Link>
              ) : (
                <div className="reported-post-list removed" key={postData.reportPost.id}>
                  <div className="reported-post-data">{formatDate(new Date(postData.reportPost.created_at))}</div>
                  <div className="reported-post-data">{formatDate(new Date(postData.reportPost.updated_at))}</div>
                  <div className="reported-post-data">{postData.reportPost.reason}</div>
                  <div className="reported-post-data">삭제된 포스트...</div>
                  <div className="reported-post-data">
                    {postData.reportPost.isCompleted ? '확인 완료' : '확인 안된상태'}
                  </div>
                </div>
              );
            })}
          </div>
          <div className="button-wrapper">
            <Button onClick={handlePrev}>Previous</Button>
            <Button
              className={`${reportedPostList.length === 0 ? 'isDisabled' : ''}`}
              onClick={handleNext}
              disabled={reportedPostList.length === 0}
            >
              Next
            </Button>
          </div>
        </div>
      </BGLoadingSpinner>
    </div>
  );
};
