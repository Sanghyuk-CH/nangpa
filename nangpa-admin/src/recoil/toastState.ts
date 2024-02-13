import { atom } from 'recoil';

export type ToastType = 'basic' | 'button';
export type ToastStatus = 'fail' | 'info' | 'warning' | 'success';
export type ToastPosition = 'top' | 'bottom';

export interface Toast {
  type: ToastType;
  status: ToastStatus;
  message: string;
  time: number;
  isShow: boolean;
  button?: JSX.Element;
  position: ToastPosition;
}

export const toastState = atom<Toast>({
  key: 'toastState',
  default: {
    type: 'basic',
    status: 'info',
    message: '',
    time: 4000,
    isShow: false,
    position: 'bottom',
  },
});
