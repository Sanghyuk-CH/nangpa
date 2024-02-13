import axios from 'axios';

export const sendSms = async ({ phone, message }: { phone: string; message: string }) => {
  const formData = new URLSearchParams();
  formData.append('key', process.env.SMS_API_KEY);
  formData.append('user_id', process.env.SMS_SEND_ACCOUNT);
  formData.append('sender', process.env.SMS_SEND_PHONE_NUMBER);
  formData.append('receiver', phone);
  formData.append('msg', message);
  return await axios.post('https://apis.aligo.in/send/', formData);
};
