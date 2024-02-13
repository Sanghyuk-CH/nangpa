import React from 'react';
import { useRecoilValue } from 'recoil';
import { useTranslation } from 'react-i18next';
import { Dialog, dialogState } from '../../recoil/dialogState';
import { useDialog } from '../../hooks/useDialog';
import { WrapperModal } from '../UI/WrapperModal/WrapperModal';
import { DialogConfirm } from '../DialogConfirm/DialogConfirm';

// @ts-ignore
const GlobalDialog = () => {
  const i18next = useTranslation();
  const dialog: Dialog = useRecoilValue(dialogState);
  const { hideDialog } = useDialog();

  const confirmButtons = [
    {
      label: i18next.t('취소'),
      appearance: 'secondary',
      handleClick: () => {
        hideDialog();
      },
    },
    {
      label: i18next.t('확인'),
      handleClick: () => {
        if (dialog.confirmResolve) dialog.confirmResolve('confirm');
        hideDialog();
      },
    },
  ];
  const messageButtons = [
    {
      label: i18next.t('확인'),
      handleClick: () => {
        if (dialog.confirmResolve) dialog.confirmResolve('ok');
        hideDialog();
      },
    },
  ];

  const handleClickHide = () => {
    if (!dialog.option?.disableClose) {
      hideDialog();
    }
  };

  return (
    <React.Fragment>
      {dialog.type === 'confirm' && (
        <WrapperModal isOpen={`${dialog.isShow ? 'true' : ''}`} close={handleClickHide} isDialogConfirm>
          <DialogConfirm title={dialog.title} desc={dialog.message} buttons={confirmButtons} />
        </WrapperModal>
      )}
      {dialog.type === 'message' && (
        <WrapperModal isOpen={`${dialog.isShow ? 'true' : ''}`} close={handleClickHide} isDialogConfirm>
          <DialogConfirm title={dialog.title} desc={dialog.message} buttons={messageButtons} />
        </WrapperModal>
      )}
      {dialog.type === 'dialog' && (
        <WrapperModal isOpen={`${dialog.isShow ? 'true' : ''}`} close={handleClickHide} isDialogConfirm>
          <DialogConfirm title={dialog.title} desc={dialog.message} buttons={dialog.buttons} />
        </WrapperModal>
      )}
      {dialog.type === 'component' && (
        <WrapperModal
          isOpen={`${dialog.isShow ? 'true' : ''}`}
          close={handleClickHide}
          position={{ ...dialog.option?.modalContentStyle }}
        >
          {dialog.children}
        </WrapperModal>
      )}
    </React.Fragment>
  );
};

export const Global = () => {
  return (
    <React.Fragment>
      <GlobalDialog />
    </React.Fragment>
  );
};
