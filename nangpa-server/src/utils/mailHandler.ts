export const sendMailConfig = (email: string, code: string) => ({
  to: email,
  from: 'noreply@nangpa.com',
  subject: 'Verify Code',
  text: `admin super user verify code: ${code}`,
  html: `<b>admin super user verify code: ${code}</b>`,
});
