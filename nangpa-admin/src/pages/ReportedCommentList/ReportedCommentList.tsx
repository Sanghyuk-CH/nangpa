/* eslint-disable no-return-assign */
/* eslint-disable no-param-reassign */
import React, { useMemo, useState } from 'react';
import { useQuery } from 'react-query';
import { Link } from 'react-router-dom';
import { AdminApi } from '../../api/adminApi';
import BGLoadingSpinner from '../../components/BGLoadingSpinner/BGLoadingSpinner';
import { ReportedCommentResponse } from '../../models/Model';
import { formatDate } from '../../utils/date';
import { Button } from '../Login/Login.style';
import { ReportedCommentListCss } from './ReportedCommentList.style';

export const ReportedCommentList = () => {
  const [offset, setOffset] = useState<number>(1);
  const [reportedCommentList, setReportedCommentList] = useState<ReportedCommentResponse[]>([]);
  const limit = useMemo(() => 10, []);

  const { isLoading } = useQuery(
    ['getReportedCommentList', offset],
    () => {
      return AdminApi().getReportedCommentList({ offset, limit });
    },
    {
      onSuccess: (data) => {
        setReportedCommentList(data);
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
    <div css={ReportedCommentListCss}>
      <BGLoadingSpinner isLoading={isLoading}>
        <div className="reported-post-list-wrapper">
          <div className="table-wrapper">
            <div className="table-header">
              <div className="th">생성일</div>
              <div className="th">수정일</div>
              <div className="th">이유</div>
              <div className="th">확인상태</div>
            </div>
            {reportedCommentList.map((commentData) => {
              return commentData.comment ? (
                <Link
                  to={`/reported/comments/${commentData.reportComment.id}`}
                  state={{ commentData }}
                  key={commentData.reportComment.id}
                >
                  <div className="reported-post-list">
                    <div className="reported-post-data">
                      {formatDate(new Date(commentData.reportComment.created_at))}
                    </div>
                    <div className="reported-post-data">
                      {formatDate(new Date(commentData.reportComment.updated_at))}
                    </div>
                    <div className="reported-post-data">{commentData.reportComment.reason}</div>
                    <div className="reported-post-data">
                      {commentData.reportComment.isCompleted ? '확인 완료' : '확인 안된상태'}
                    </div>
                  </div>
                </Link>
              ) : (
                <div className="reported-post-list removed" key={commentData.reportComment.id}>
                  <div className="reported-post-data">{formatDate(new Date(commentData.reportComment.created_at))}</div>
                  <div className="reported-post-data">{formatDate(new Date(commentData.reportComment.updated_at))}</div>
                  <div className="reported-post-data">{commentData.reportComment.reason}</div>
                  <div className="reported-post-data">삭제된 댓글...</div>
                  <div className="reported-post-data">
                    {commentData.reportComment.isCompleted ? '확인 완료' : '확인 안된상태'}
                  </div>
                </div>
              );
            })}
          </div>
          <div className="button-wrapper">
            <Button onClick={handlePrev}>Previous</Button>
            <Button
              className={`${reportedCommentList.length === 0 ? 'isDisabled' : ''}`}
              onClick={handleNext}
              disabled={reportedCommentList.length === 0}
            >
              Next
            </Button>
          </div>
        </div>
      </BGLoadingSpinner>
    </div>
  );
};
