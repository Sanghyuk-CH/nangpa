# nangpa-server

변경점 sms 관련 기능 utils 로 옮기고 endpoint 는 auth 로 변경
어드민 post 신고 기능 추가
어드민 comment 신고 기능 추가
어드민 user ban 기능 추가

그에따라

로그인시 ban 상태인지 아닌지 로직 추가
post 받아올때 신고 되어있으면 안가져오는 로직 추가
comment 받아올때 신고 되어있으면 안가져오는 로직 추가
기타 파일명 등등 변경

패스워드 초기화 기능 추가
패스워드 변경 기능 추가

어드민에서 신고된 포스트 불러오기
어드민에서 신고된 댓글 불러오기
포스트 또는 댓글 한번에 여러개 삭제 기능 추가