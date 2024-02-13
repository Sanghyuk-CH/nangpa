import { useResetRecoilState, useSetRecoilState } from 'recoil';
import { DialogButton, dialogState } from '../recoil/dialogState';

export const useDialog = () => {
  const setDialogState = useSetRecoilState(dialogState);
  const hideDialog = useResetRecoilState(dialogState);

  const showConfirm = (title: string, message: string): Promise<null> => {
    return new Promise((resolve, reject) => {
      setDialogState({
        title,
        message,
        type: 'confirm',
        isShow: true,
        confirmResolve: resolve,
        cancelReject: reject,
      });
    });
  };

  const showMessage = (title: string, message: string) => {
    return new Promise((resolve, reject) => {
      setDialogState({
        title,
        message,
        type: 'message',
        isShow: true,
        confirmResolve: resolve,
        confirmReject: reject,
      });
    });
  };

  const showDialog = (title: string, message: string, buttons: DialogButton[], option?: any) => {
    setDialogState({
      title,
      message,
      type: 'dialog',
      buttons,
      isShow: true,
      option,
    });
  };

  const openDialog = (children: JSX.Element | JSX.Element[], option?: any) => {
    setDialogState({
      title: '',
      message: '',
      type: 'component',
      children,
      isShow: true,
      option,
    });
  };

  const showExcelDownloadNotice = () => {
    setDialogState({
      title: '',
      message: '',
      type: 'excelWaring',
      buttons: [],
      isShow: true,
    });
  };

  return { showConfirm, showMessage, showDialog, openDialog, hideDialog, showExcelDownloadNotice };
};
