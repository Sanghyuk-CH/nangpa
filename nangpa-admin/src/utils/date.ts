export const formatDate = (date: Date): string => {
  const intl = new Intl.DateTimeFormat('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });

  const parts = intl.formatToParts(date);
  const year = parts.find((part) => part.type === 'year')?.value;
  const month = parts.find((part) => part.type === 'month')?.value;
  const day = parts.find((part) => part.type === 'day')?.value;

  return `${year}-${month}-${day}`;
};
export const getDDay = (endDate: Date): number => {
  const now = new Date();
  const diffInMilliseconds = endDate.getTime() - now.getTime();

  // 밀리초를 일 수로 변환하려면 나누기 (1000 * 60 * 60 * 24)
  const diffInDays = Math.ceil(diffInMilliseconds / (1000 * 60 * 60 * 24));
  return diffInDays;
};
