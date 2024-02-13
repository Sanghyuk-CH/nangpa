export const generateRandomPassword = () => {
  const lowerChars = 'abcdefghijklmnopqrstuvwxyz';
  const upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  const specialChars = '!@#$%^&*()-+?';

  function getRandomChar(charSet) {
    return charSet[Math.floor(Math.random() * charSet.length)];
  }

  const randomPassword = Array.from({ length: 8 }, () => {
    const randomIndex = Math.floor(Math.random() * 4);
    switch (randomIndex) {
      case 0:
        return getRandomChar(lowerChars);
      case 1:
        return getRandomChar(upperChars);
      case 2:
        return getRandomChar(numbers);
      case 3:
        return getRandomChar(specialChars);
    }
  });

  return randomPassword.join('');
};
