import { css } from '@emotion/react';

export const HomeCss = css`
  body {
    margin: 0;
    background-color: #fbf3ea;
  }
  padding: 0 0 30px 0;
  div,
  section,
  header,
  footer,
  p,
  h1,
  h2 {
    box-sizing: border-box;
  }
  a {
    color: royalblue;
  }
  img {
    max-width: 100%;
    height: auto;
  }

  header {
    padding: 1rem 2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 16px;
    background-color: #fbf3ea;
    color: #ff66c4;
  }

  .scroll-content {
    background-color: #2f2f2f;
  }

  .global-width {
    max-width: 620px;
    margin: 0 auto;
    padding: 0 1rem;
  }
  .scroll-graphic {
    position: sticky;
    top: 0;
    height: 100vh;
  }
  .graphic-item {
    display: flex;
    align-items: center;
    justify-content: center;
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    opacity: 0;
    transition: 0.5s;
  }

  .visible {
    opacity: 1;
  }

  .scene-img {
    max-height: 100vh;
    aspect-ratio: 4 / 3;
    pointer-events: none;
  }

  .scroll-text {
    position: relative;
    padding-bottom: 1px;
  }

  .step {
    margin-bottom: 60vh;
    padding: 1.5rem 1.5rem;
    border-radius: 10px;
    box-shadow: rgba(0, 0, 0, 0.3) 1px 1px 5px;
    display: flex;
    flex-direction: column;
    gap: 1rem;
    background-color: rgba(251, 243, 234, 0.95);
  }
  .step h3 {
    display: flex;
    margin: 0;
    gap: 1rem;
    color: #ff66c4;
  }

  .step .description {
    gap: 1rem;
    display: flex;
    color: #2f2f2f;
    font-weight: bold;
    font-size: 1rem;
  }

  .step .final {
    display: flex;
    flex-direction: column;
  }

  .step .description ul {
    margin: 0;
    padding: 0;
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .step p {
    margin: 0;
  }

  .step .final .link-wrapper {
    width: 100%;
    display: flex;
    flex-direction: row;
    justify-content: center;
    gap: 2rem;
  }

  .step .final .link-wrapper li {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 20px;
  }

  .step .final .link-wrapper li img {
    width: 64px;
    height: 64px;
  }

  .step .final .link-wrapper li .link-btn {
    padding: 0.5rem 1rem;
    display: inline-block;
    background-color: #333;
    color: #fff;
    text-decoration: none;
    font-size: 1rem;
    border-radius: 5px;
    transition: background-color 0.3s ease;
  }

  .step .final .link-wrapper li .link-btn:hover {
    background-color: #555;
  }

  .global-footer {
    padding: 1rem;
    display: flex;
    font-weight: 700;
    align-items: center;
    justify-content: center;
    color: #ff66c4;
  }

  .scroll-indicator {
    position: fixed;
    bottom: 20px;
    left: 50%;
    transform: translate(-50%, 0);
    text-align: center;
    color: #fff;
    font-size: 1rem;
    animation: bounce 2s infinite;
    z-index: 200;
    display: none;
  }

  .scroll-indicator.visible {
    display: block;
  }

  .scroll-indicator .arrow {
    display: block;
    font-size: 2rem;
    margin-bottom: 5px;
  }

  @keyframes bounce {
    0%,
    20%,
    50%,
    80%,
    100% {
      transform: translate(-50%, 0);
    }
    40% {
      transform: translate(-50%, -30px);
    }
    60% {
      transform: translate(-50%, -15px);
    }
  }

  .typing-text {
    font-size: 2rem;
    font-weight: bold;
    color: #fff;
    text-align: center;
    white-space: pre;
    overflow: hidden;
    border-right: 2px solid;
    animation: typing-cursor 0.5s infinite;
  }

  @keyframes typing-cursor {
    0%,
    100% {
      border-color: transparent;
    }
    50% {
      border-color: #fff;
    }
  }
`;
