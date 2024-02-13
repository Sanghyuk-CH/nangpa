import React, { useState } from 'react';
import { useQuery } from 'react-query';
import { AdminApi } from '../../api/adminApi';
import BGLoadingSpinner from '../../components/BGLoadingSpinner/BGLoadingSpinner';
import { BanUser } from '../../models/Model';
import { formatDate, getDDay } from '../../utils/date';
import { baseCss } from './BanUserList.style';

export const BanUserList = () => {
  const [banUserList, setBanUserList] = useState<BanUser[]>([]);
  const { isLoading } = useQuery(
    ['getBanUserList'],
    () => {
      return AdminApi().getAllBanList();
    },
    {
      onSuccess: (data) => {
        setBanUserList(data);
      },
      onError: (err) => {
        console.log(err);
      },
    },
  );
  return (
    <div css={baseCss}>
      <BGLoadingSpinner isLoading={isLoading}>
        <div className="ban-user-list-wrapper">
          <div className="table-wrapper">
            <div className="table-header">
              <div className="th">생성일</div>
              <div className="th">수정일</div>
              <div className="th">남은기간</div>
              <div className="th">닉네임</div>
              <div className="th">핸드폰번호</div>
            </div>
            {banUserList.map((banUserData) => {
              return (
                <div className="ban-user-list">
                  <div className="ban-user-data">{formatDate(new Date(banUserData.created_at))}</div>
                  <div className="ban-user-data">{formatDate(new Date(banUserData.updated_at))}</div>
                  <div className="ban-user-data">{`${getDDay(new Date(banUserData.ban_peroid))}일`}</div>
                  <div className="ban-user-data">{banUserData.user.nickname}</div>
                  <div className="ban-user-data">{banUserData.user.phone_number}</div>
                </div>
              );
            })}
          </div>
        </div>
      </BGLoadingSpinner>
    </div>
  );
};
