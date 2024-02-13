import { useResetRecoilState, useSetRecoilState } from 'recoil';
import { toastState } from '../recoil/toastState';

export const useToast = () => {
  const setToastState = useSetRecoilState(toastState);
  const hideToast = useResetRecoilState(toastState);

  const showToast = (
    type: 'basic' | 'button' = 'basic',
    status: 'fail' | 'info' | 'warning' | 'success',
    message = '',
    time = 4000,
    button?: JSX.Element,
    position: 'top' | 'bottom' = 'bottom',
  ) => {
    return setToastState({ type, status, message, time, button, position, isShow: true });
  };
  return { showToast, hideToast };
};
