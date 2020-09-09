/*
문서명 : DML.Admin-TextSQL.sql (관리자)
작성자 : 디비 5조
작성일자 : 2020.06.18
프로젝트명 : YongYongAcademy
프로그램명 : 소프트웨어교육센터 (Software Education Center)
프로그램 설명 : 소프트웨어 교육센터 시스템을 구현하기 위한 프로그램이다.
문서설명 : 본 문서는 DDL 폴더에 있는 문서들과 DML에 있는 더미데이터 문서들과 연관성이 높은 문서이다.
         추후 JDBC 작업 시 사용될 DML 쿼리문을 담았다.
*/

--------------------------------------------------------------------------------------
--01. 기초 정보 관리
--------------------------------------------------------------------------------------
--기초정보를 출력하기위한 view table
create or replace view vwAdminInfo 
as
select 
s.seq as 번호, 
c.name as 과정명, 
s.name as 과목명, 
b.name as 교재명, 
b.publisher as 출판사명, 
r.name as 강의실명, 
r.num as 정원
from tblOpenClass oc    --개설과정 테이블
    inner join tblOpenSubject os  --개설과목 테이블
        on os.openClassSeq = oc.seq
            inner join tblSubject s  --과목 테이블
                on s.seq = os.subjectSeq
                    inner join tblBook b --교재 테이블
                        on b.seq = s.bookseq
                            inner join tblClass c --과정테이블
                                on c.seq = oc.classSeq
                                    inner join tblRoom r --강의실테이블
                                        on r.seq = oc.roomSeq
                                            order by s.seq;
                                            
--------------------------------------------------------------------------------------
--02. 개설 과정 관리
--------------------------------------------------------------------------------------                                            
-- 특정 개설 과정 선택시의 각각의 개설과정에 속해있는 교육생의 정보를 출력하기 위한 view table
create or replace view vwChoiceStudent
as
select distinct
stu.seq as 교육생번호,
s.seq as 과목번호,
stu.name as 교육생이름,
stu.pwd as 주민번호뒷자리,
stu.tel as 전화번호,
to_char(stu.regdate,'yy/mm/dd') as 등록일,
(case
when si.completdate is not null then '수료' 
when si.faildate is not null then '중도탈락'
end) as 수료및중도탈락 , to_char(si.completdate,'yy/mm/dd') as 수료날짜
from tblOpenClass oc
    inner join tblOpenSubject os --개설과목테이블
        on os.openclassSeq = oc.seq
            inner join tblSubject s --과목테이블
                on s.seq = os.subjectSeq
                    inner join tblBook b --교재테이블
                        on b.seq = s.bookSeq
                            inner join tblClass c --과정테이블
                                on c.seq = oc.classSeq
                                    inner join tblClassReg cr --수강신청테이블
                                        on cr.openclassseq = oc.seq
                                            inner join tblStudent stu --학생테이블
                                                on stu.seq = cr.studentSeq
                                                    inner join tblStudentInfo si --학생정보테이블
                                                        on si.classregseq = cr.seq
                                                            inner join tblTeacher t --교사테이블
                                                                on t.seq = oc.teacherSeq
                                                                order by  과목번호;            
                                                                                                                      
                                                             

                                                                
--특정 개설 과정 선택시의 각각의 개설과정을 모은 view table을 출력하기 위한 procedure                                        
create or replace procedure proSubName(
   presult out sys_refcursor
)
is
begin
    open presult for
        select * from vwSubjectName;
end;


--개설 과정 정보 출력을 위한 view
create or replace view vwSubjectName
as
select distinct c.seq as 번호, c.name as 개설과정명  
from tblOpenClass oc
    inner join tblClass c --과정테이블
        on c.seq = oc.classSeq
            inner join tblRoom r --강의실테이블
               on r.seq = oc.roomSeq
                    inner join tblClassReg cr --수강신청테이블
                       on cr.openclassseq = oc.seq
                        inner join tblOpenSubject os --개설과목테이블
                            on os.openclassSeq = oc.seq
                                inner join tblSubject s --과목테이블
                                    on s.seq = os.subjectSeq
                                        order by 번호;


--vwChoiceClass를 select 하기 위한 procedure                                                             
create or replace procedure ProvwChoiceClass(
    presult out sys_refcursor
)
is
begin
    open presult for
        select * from vwChoiceClass; 
end;                                                               
      
                        
--특정 개설 과정 선택시 -> 수료날짜 입력 가능
create or replace procedure procDate(
    pnum number , --교육생 번호 
    pClass number , --과정번호 
    pdate varchar2 --수료날짜
)
is
begin
    update tblStudentInfo set completDate = pdate 
        where classRegSeq = (select seq from tblClassReg where studentseq = pnum and openclassseq = pclass);
end;

-- 과정정보를 출력하기위한 procedure
create or replace procedure proClass(
   presult out sys_refcursor
)
is
begin
    open presult for
        select * from tblClass;
end;
--------------------------------------------------------------------------------------
--03. 개설 과목 관리
--------------------------------------------------------------------------------------    
create or replace view vwChoiceClass
as
select distinct
s.seq as 과목번호,
s.name as 과목명,
to_char(os.startdate, 'yy/mm/dd')as 시작일, to_char(os.enddate, 'yy/mm/dd') as 종료일,
b.name as 교재명,
t.name as 교사명
from tblOpenClass oc 
    inner join tblOpenSubject os --개설과목테이블
        on os.openclassSeq = oc.seq
            inner join tblSubject s --과목테이블
                on s.seq = os.subjectSeq
                    inner join tblBook b --교재테이블
                        on b.seq = s.bookSeq
                                    inner join tblClassReg cr --수강신청테이블
                                        on cr.openclassseq = oc.seq
                                            inner join tblStudent stu --학생테이블
                                                on stu.seq = cr.studentSeq
                                                            inner join tblTeacher t --교사테이블
                                                                on t.seq = oc.teacherSeq;

--개설 과목 정보 출력을 위한 view table
create or replace view vwOpenSubInfo
as
select 
c.seq as 번호,
c.name as 과정명, 
to_char(oc.startdate, 'yy/mm/dd') || '~' || to_char(oc.enddate, 'yy/mm/dd') as 과정기간,
r.name as 강의실명,
s.name as 과목명,
to_char(os.startdate, 'yy/mm/dd') || '~' || to_char(os.enddate, 'yy/mm/dd') as 과목기간,
b.name as 교재명,
t.name as 교사명
from tblOpenSubject os
    inner join tblSubject s --과정테이블
        on s.seq = os.subjectSeq
            inner join tblbook b --교재테이블
                on b.seq = s.bookSeq
                    inner join tblOpenClass oc --개설과목테이블
                        on oc.seq = os.openClassSeq
                            inner join tblTeacher t --교사테이블
                                on t.seq = oc.teacherSeq
                                    inner join tblclass c --과목테이블
                                        on c.seq = oc.classSeq
                                            inner join tblRoom r --강의실테이블
                                                on r.seq = oc.roomSeq
                                                 order by 과정기간;

-- 개설 과목 정보 출력을 위한 procedure
create or replace procedure ProvwOSInfo(
    presult out sys_refcursor
)
is
begin
    open presult for vwOpenSubInfo; 
      
end;


-- tblBook table의 정보를 select 하기 위한 procedure
create  or replace procedure ProBook(
     presult out sys_refcursor
)
is
begin
    open presult for
        select * from tblBook;
end;


-- tblSubject table의 정보를 select 하기 위한 procedure
create  or replace procedure ProSubject(
     presult out sys_refcursor
)
is
begin
    open presult for
        select * from tblSubject;
end;

--tblRoom table의 정보를 select 하기 위한 procedure
create  or replace procedure ProRoom(
     presult out sys_refcursor
)
is
begin
    open presult for
        select * from tblRoom;
end;



