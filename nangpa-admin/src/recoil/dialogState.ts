import { atom } from 'recoil';

export type DialogButton = {
  label: string;
  handleClick?: () => void;
  appearance?: string;
};

export interface Dialog {
  title: string;
  message: string;
  type: string;
  buttons?: DialogButton[];
  isShow: boolean;
  confirmResolve?: (value?: any) => void;
  confirmReject?: (reason?: any) => void;
  cancelReject?: (reason?: any) => void;
  children?: JSX.Element | JSX.Element[];
  option?: {
    disableClose: boolean;
    modalContentStyle?: React.CSSProperties;
  };
}

export const dialogState = atom<Dialog>({
  key: 'dialogState',
  default: {
    title: '',
    message: '',
    type: 'message',
    buttons: [],
    isShow: false,
  },
});
