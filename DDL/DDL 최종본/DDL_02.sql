/*
문서명 : DDL_02.sql (2/2)
작성자 : 5조
작성일자 : 2020.06.03.
프로그램명 : 소프트웨어교육센터 (Software Education Center)
프로그램 설명 : 소프트웨어 교육센터 시스템을 구현하기 위한 프로그램이다.
URL Link : https://github.com/xxHANIxx/SFT_EDC_CNT
*/

/*
-- INDEX
01. 교육생 기본 정보 (tblStudent) -- line 21
02. 교육생 정보 (tblStudentInfo) -- line 35
03. 수강신청 (tblClassReg) -- line 46
04. 과정 (tblClass) -- line 60
05. 교재 (tblBook) -- line 80
06. 과목 (tblSubject) -- line 91
07. 시험 (tblTest) -- line 104
08. 과정 + 과목 (tblLectureSubject) -- line 117
09. 강의실 (tblRoom) -- line 129
10. 개설과목 (tblOpenSubject) -- line 140
11. 출결관리 (tblAttend) -- line 153
12. 배점 (tblPoint) -- line 168
13. 성적 (tblScore) -- line 181
*/

select * from tblTeacher; -- seq가 10개
select * from tblRoom;    -- seq가 6개
select * from tblclass;   -- seq가 15개

select * from tblOpenClass;

-----------------------------------------------------------------------------------------
-- 01. 교육생 기본 정보
-----------------------------------------------------------------------------------------
create table tblStudent (
    seq number primary key,         -- 번호(PK)
    name varchar2(30) not null,     -- 이름 
    tel varchar2(30) not null,      -- 전화번호
    regdate date not null,          -- 등록일
    id varchar2(30) not null,       -- 아이디
    pwd varchar2(14) not null       -- 비밀번호(주민 뒷자리)
);

create sequence tblStudent_seq;

-----------------------------------------------------------------------------------------
-- 02. 교육생 정보
-----------------------------------------------------------------------------------------
create table tblStudentInfo (
    seq number primary key,         -- 번호(PK)
    completDate date null,           -- 수료날짜
    failDate date null,             -- 중도탈락 날짜
    employee varchar2(15) null,     -- 취업유무
    mento varchar2(15) null,     -- 멘토/멘티
    classRegSeq number not null references tblClassReg(seq) -- 수강신청 번호(FK)
);

create sequence tblStudentInfo_seq;

-----------------------------------------------------------------------------------------
-- 03. 수강신청
-----------------------------------------------------------------------------------------
create table tblClassReg (
    seq number primary key,                                              -- 번호(PK)
    studentSeq number not null references tblStudent(seq),               -- 교육생 번호(FK)
    openClassSeq number not null references tblOpenClass(seq)           -- 개설과정 번호(FK)
);

create sequence tblClassReg_seq;

-----------------------------------------------------------------------------------------
-- 04. 과정
-----------------------------------------------------------------------------------------
create table tblClass (
    seq number primary key,         -- 번호(PK)
    name varchar2(100) not null,    -- 과정명
    classPeriod number not null     -- 기간
);

create sequence tblClass_seq;

-----------------------------------------------------------------------------------------
-- 05. 교재
-----------------------------------------------------------------------------------------
create table tblBook (
    seq number primary key,             -- 번호(PK)
    name varchar2(100) not null,        -- 교재명
    publisher varchar2(100) not null    -- 출판사명
);

create sequence tblBook_seq;

-----------------------------------------------------------------------------------------
-- 06. 과목
-----------------------------------------------------------------------------------------
create table tblSubject (
    seq number primary key,                              -- 번호(PK)
    name varchar2(60) not null,                          -- 과목명
    type number not null,                                -- 종류
    subjectPeriod number not null,                          -- 기간
    bookseq number not null references tblBook(seq)     -- 교재 번호(FK)
);

create sequence tblSubject_seq;

-----------------------------------------------------------------------------------------
-- 07. 시험
-----------------------------------------------------------------------------------------
create table tblTest (
    seq number primary key,                                         -- 번호(PK)
    write varchar2(15) default 'X',                                 -- 필기 문제
    practice varchar2(15) default 'X',                               -- 실기 문제
    testDate date null,                                              -- 시험 날짜
    openSubjectSeq number not null references tblOpenSubject(seq)   -- 개설과목 번호(FK)
);

create sequence tblTest_seq;

-----------------------------------------------------------------------------------------
-- 08. 과정 + 과목
-----------------------------------------------------------------------------------------
create table tblLectureSubject (
    seq number primary key,                                      -- 번호(PK)
    ord number not null,                                         -- 순서
    subjectSeq number not null references tblSubject(seq),      -- 과목 번호(FK)
    classSeq number not null references tblClass(seq)           -- 과정 번호(FK)
);

create sequence tblLectureSubject_seq;

-----------------------------------------------------------------------------------------
-- 09. 강의실
-----------------------------------------------------------------------------------------
create table tblRoom (
    seq number primary key,         -- 번호(PK)
    name varchar2(20) not null,     -- 강의실명
    num number not null             -- 정원
); 

create sequence tblRoom_seq;

-----------------------------------------------------------------------------------------
-- 10. 개설과목
-----------------------------------------------------------------------------------------
create table tblOpenSubject (
    seq number primary key,                                     -- 번호(PK)
    startDate date not null,                                     -- 과목기간(시작)
    endDate date not null,                                       -- 과목기간(끝)
    openClassSeq number not null references tblOpenClass(seq),  -- 개설과정 번호(FK)
    subjectSeq number not null references tblSubject(seq)       -- 개설과목 번호(FK)
); 

create sequence tblOpenSubject_seq;

-----------------------------------------------------------------------------------------
-- 11. 출결 관리
-----------------------------------------------------------------------------------------
create table tblAttend (
    seq number primary key,                                     -- 번호(PK)
    inDate date null,                                            -- 출결
    outDate date null,                                           -- 퇴근
    inOutDate date null,                                         -- 출결 날짜
    state varchar2(30) null,                                -- 근태 상황
    classRegSeq number not null references tblClassReg(seq),    -- 교육생 번호(FK)
    openClassSeq number not null references tblOpenClass(seq)   -- 개설과정 번호(FK)
);

create sequence tblAttend_seq;

-----------------------------------------------------------------------------------------
-- 12. 배점
-----------------------------------------------------------------------------------------
create table tblPoint (
    seq number primary key,                                          -- 번호(PK)
    attendPoint number not null,                                     -- 출결 배점
    writePoint number not null,                                      -- 필기 배점
    practicePoint number not null,                                   -- 실기 배점
    openSubjectSeq number not null references tblOpenSubject(seq)   -- 개설과목 번호(FK)
);

create sequence tblPoint_seq;

-----------------------------------------------------------------------------------------
-- 13. 성적
-----------------------------------------------------------------------------------------
create table tblScore (
    seq number primary key,                                  -- 번호(PK)
    writeScore number default 0,                             -- 필기 점수
    practiceScore number default 0,                          -- 실기 점수
    classRegSeq number not null references tblStudent(seq),  -- 수강신청 번호
    pointSeq number not null references tblPoint(seq),       -- 배점 번호
    attendScore number default 0
);

create sequence tblScore_seq;