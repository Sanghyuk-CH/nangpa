import React, { useMemo, useState } from 'react';
import 'react-quill/dist/quill.snow.css';
import { useLocation, useNavigate } from 'react-router-dom';
import { useMutation } from 'react-query';
import { CreateBan, DeleteComments, ReportedCommentResponse, UpdateComment } from '../../models/Model';
import { Button } from '../Login/Login.style';
import { baseCss } from './ReportedCommentDetail.style';
import { AdminApi } from '../../api/adminApi';
import { WrapperModal } from '../../components/UI/WrapperModal/WrapperModal';

export const ReportedCommentDetail = () => {
  const location = useLocation();
  const navigator = useNavigate();
  const {
    // @ts-ignore
    state: { commentData },
  } = location;

  const commentInfo = useMemo(() => commentData as ReportedCommentResponse, [commentData]);

  const [isBanModalOpen, setIsBanModalOpen] = useState(false);
  const [banDays, setBanDays] = useState<number>(0); // 밴 기간 상태 변수

  const { mutate: banUserMutation, isLoading: isBanLoading } = useMutation(
    (data: CreateBan) => {
      return AdminApi().createBan({ ...data });
    },
    {
      onSuccess: () => {
        alert('밴 요청이 성공적으로 완료되었습니다.');
        navigator('/ban/user');
      },
      onError: (error) => {
        alert('밴 요청 중 오류가 발생했습니다:');
        console.error(error);
      },
    },
  );

  const { mutate: deleteCommentMutate } = useMutation(
    (data: DeleteComments) => {
      return AdminApi().deleteComment(data);
    },
    {
      onSuccess: () => {
        alert('삭제 요청이 성공적으로 완료되었습니다.');
        navigator(-1);
      },
      onError: (error) => {
        alert('삭제 요청 중 오류가 발생했습니다:');
        console.error(error);
      },
    },
  );
  const { mutate: updateCommentMutate } = useMutation(
    (data: UpdateComment) => {
      console.log(data);
      return AdminApi().modifyCompleteComment(data);
    },
    {
      onSuccess: () => {
        alert('수정 요청이 성공적으로 완료되었습니다.');
        navigator(-1);
      },
      onError: (error) => {
        alert('수정 요청 중 오류가 발생했습니다:');
        console.error(error);
      },
    },
  );

  const handleComplete = (data: UpdateComment) => {
    // 처리 완료 로직을 구현하세요.
    updateCommentMutate(data);
  };

  const handleRemove = () => {
    // 처리 완료 로직을 구현하세요.
    deleteCommentMutate({ commentsIds: [{ id: commentInfo.comment.id, category: 'free' }] });
  };

  const handleBan = () => {
    setIsBanModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsBanModalOpen(false);
  };

  const handleSubmitBan = () => {
    // 밴 요청 보내기
    banUserMutation({ userId: commentInfo.comment.user_id, days: banDays });
    setIsBanModalOpen(false);
  };

  return (
    <div className="ReportedCommentDetail" css={baseCss}>
      <div className="header">
        <h1>댓글 자세히 보기</h1>
        <div className="button-wrapper">
          <Button
            className={`${commentInfo.reportComment.isCompleted ? 'isCompleted' : ''}`}
            onClick={() => {
              handleComplete({ isCompleted: !commentInfo.reportComment.isCompleted, id: commentInfo.reportComment.id });
            }}
          >
            {commentInfo.reportComment.isCompleted ? '확인 취소' : '확인 완료'}
          </Button>
          <Button className="removeBtn" onClick={handleRemove}>
            삭제
          </Button>
          <Button className="banBtn" onClick={handleBan}>
            Ban
          </Button>
        </div>
      </div>

      <h2>댓글 신고 이유</h2>
      <div className="comment-area">{commentInfo.reportComment.reason}</div>
      <h2>댓글 자세히 보기</h2>
      <div className="comment-area">{commentInfo.comment.contents}</div>

      {/* 밴 모달 */}
      <WrapperModal isOpen={isBanModalOpen} position={{ width: '320px' }}>
        <div className="modal">
          <h2>사용자 밴</h2>
          <p>밴 기간을 입력하세요:</p>
          <input
            type="number"
            value={banDays}
            onChange={(e) => setBanDays(parseInt(e.target.value, 10))}
            placeholder="밴 기간"
          />
          <div className="btn-wrapper">
            <Button onClick={handleSubmitBan} disabled={isBanLoading}>
              {isBanLoading ? '밴 처리 중...' : '밴 요청'}
            </Button>
            <Button onClick={handleCloseModal}>닫기</Button>
          </div>
        </div>
      </WrapperModal>
    </div>
  );
};
