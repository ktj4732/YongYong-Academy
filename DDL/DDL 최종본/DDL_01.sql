/*
문서명 : DDL_01.sql(1/2)
작성자 : 디비 5조
작성일자 : 2020.06.03.
프로그램명 : 소프트웨어교육센터 (Software Education Center)
프로그램 설명 : 소프트웨어 교육센터 시스템을 구현하기 위한 프로그램이다.
*/


/*
-- INDEX
01. 관리자 테이블 (tblAdmin) -- line 11
02. 교사 테이블 (tblTeacher) -- line 21
03. 급여 테이블 (tblSalary) -- line 41
04. 개설과정 테이블 (tblOpenClass) -- line 51
05. 교과 + 과목 테이블 (tblPossible) -- line 67
06. 평가 설문지 (tblAssSurvey) -- line 83
07. 평가 설문지 항목 (tblAssSurveyItem) -- line 96
08. 평가 설문지 결과 (tblAssSurbeyResult) -- line 110
09. 사전평가 설문지 (tblpriorSurvey) -- line 122
10. 사전평가 설문지 항목 (tblPriorSurveyItem) -- line 135
11. 사전평가 설문지 결과 (tblPriorSurveyResult) -- line 152
12. 인센티브 배점 테이블 (tblincentivePoint) -- line 165
*/

-- 01. 관리자 테이블
create table tblAdmin(
    seq number primary key,     -- 번호(PK)
    id varchar2(30) not null,   -- 아이디
    pwd varchar2(20) not null   -- 비밀번호
);

create sequence tblAdmin_seq;

-- 02. 교사 테이블
create table tblTeacher(
    seq number primary key,     -- 번호(PK)
    name varchar2(30) not null, -- 이름
    tel varchar2(30) not null,  -- 전화번호
    id varchar2(30) not null,   -- 아이디
    pwd varchar2(14) not null,    -- 비밀번호
    status varchar(215) -- 강의상태
);
create sequence tblTeacher_seq;


-- 03. 급여 테이블
create table tblSalary(
    seq number primary key,     -- 번호(PK)
    salary number not null,     -- 월급
    incentive number default 0, -- 인센티브
    teacherSeq number not null references tblTeacher(seq)   --교사번호(FK)
);
create sequence tblSalary_seq;


-- 04. 개설과정 테이블
create table tblOpenClass(
    seq number primary key,     -- 번호(PK)
    startDate date not null,    -- 과정 기간(시작)
    endDate date not null,      -- 과정 기간(끝)
    teacherSeq number not null references tblTeacher(seq),  -- 교사정보번호(FK)
    roomSeq number not null references tblRoom(seq),        -- 강의실번호(FK)
    classSeq number not null references tblClass(seq)       -- 과정번호(FK)
);

create sequence tblOpenClass_seq;


-- 05. 교과 + 과목 테이블
create table tblPossible(
    seq number primary key, -- 번호(PK)
    teacherSeq number not null references tblTeacher(seq),  --교사번호(FK)
    subjectSeq number not null references tblSubject(seq)   --과목번호(FK)
);

create sequence tblPossible_seq;


-- 06. 평가 설문지
create table tblAssSurvey(
    seq number primary key, -- 번호(PK)
    question varchar2(300) not null,    -- 질문
    outNum number not null, -- 출력번호
    openClassSeq number not null references tblOpenClass(seq)   -- 개설과정번호(FK)
);

create sequence tblAssSurvey_seq;



-- 07. 평가 설문지 항목
create table tblAssSurveyItem(
    seq number primary key, -- 번호(FK)
    content varchar2(40) not null,  -- 내용
    outNum number not null, -- 출력번호
    assSurveySeq number not null references tblAssSurvey(seq)   -- 평가번호(FK)
);



create sequence tblAssSurveyItem_seq;



-- 08. 평가 설문지 결과
create table tblAssSurbeyResult(
    seq number primary key, -- 번호(PK)
    result number not null, -- 결과(출력번호)
    assSurveySeq number not null references tblAssSurvey(seq)   -- 평가번호(FK)
);


create sequence tblAssSurveyResult_seq;



-- 09. 사전평가 설문지
create table tblpriorSurvey(
    seq number primary key, -- 번호(PK)
    question varchar2(300) not null,    -- 질문
    outNum number not null, -- 출력번호
    openClassSeq number not null references tblOpenClass(seq)   --개설과정번호(FK)
);



create sequence tblpriorSurvey_seq;


-- 10. 사전평가 설문지 항목
create table tblPriorSurveyItem(
    seq number primary key, -- 번호(PK)
    content varchar2(20) not null,  -- 내용
    outNum number not null, -- 출력번호
    priorSurveySeq number not null references tblPriorSurvey(seq)   -- 사전평가번호(FK)
);



create sequence tblPriorSurveyItem_seq;



-- 11. 사전평가 설문지 결과
create table tblPriorSurveyResult(
    seq number primary key, -- 번호(PK)
    result number not null, -- 결과(출력번호)
    answer number not null, -- 답
    priorSurveySeq number not null references tblPriorSurvey(seq),   -- 사전평가번호(FK)
    studentInfoSeq number not null references tblStudentInfo(seq)   --교육생 정보번호
);



create sequence tblPriorSurveyResult_seq;


-- 12. 인센티브 배점 테이블
create table tblincentivePoint(
    seq number primary key, -- 번호(PK)
    score number not null,  -- 점수 배점
    employeeRatio number not null   -- 취업률 배점
);

create sequence tblincentivePoint_seq;


