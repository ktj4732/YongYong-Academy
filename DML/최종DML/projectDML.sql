/*
문서명 : DMLTextSQL.sql(관리자)
작성자 : 디비 5조
작성일자 : 2019.06.15.
프로젝트명 : 용용 ACADEMY
*/

/*
INDEX
01. 출결관리 및 조회
02. 교육생 관리
03. 시험관리및 성적조회

*/
----------------------------------------
--01. 출결 관리 및 조회
----------------------------------------
--메인 > 관리자 > 출결관리 및 출결 조회
----------------------------------------
--교육생별 출결현황 - 교육생 이름검색 출결현황 조회
create or replace procedure procStudentSpecificAttend(
    pname varchar2,
    presult out sys_refcursor
)
is
begin
    open presult
        for select distinct studentseq, studentname, classname, classstartdate, classenddate
            from vwClassAttendFirst
                where studentname = pname ; 
end;


-- 교육생 이름 검색시 정보를 가져오기위한 view
create or replace view vwClassAttendFirst
as
select
s.name as studentname,
s.seq as studentseq,
s.pwd as studentpwd,
oc.seq as openclassSeq,
c.name as className,
to_char(startdate,'YYYY-MM-DD') as classstartdate,
to_char(enddate,'YYYY-MM-DD') as classenddate
from tblStudent s
    inner join tblClassReg cr
        on s.seq = cr.studentSeq
            inner join tblAttend a
                on cr.seq = a.classRegSeq
                    inner join tblOpenClass oc
                        on cr.openclassSeq = oc.seq
                            inner join tblClass c
                                on c.seq = oc.classSeq;
                                

                            
--교육생별 출결현황 - 출결현황 기간별 조회
create or replace procedure procPeriodAttend(
    pnum number,
    pindate date,
    poutdate date,
    presult out sys_refcursor
)
is
begin
    open presult for
    select studentname,to_char(attendindate, 'YY-MM-DD') as attendday, to_char(attendindate, 'hh24:mi:ss') as attendindate , to_char(attendoutdate, 'hh24:mi:ss') as attendoutdate, state 
        from vwPeriodAttend
            where studentseq = pnum and attendindate >= pindate and attendindate <= poutdate order by attendday;

end;


-- 출결현황을 select 하기위한 view
create or replace view vwPeriodAttend
as
select 
    s.seq as studentseq,
    s.name as studentname, 
    indate as attendindate,
    outdate as attendoutdate,
    a.state
    from tblStudent s -- 학생 테이블
    inner join tblClassReg cr -- 수강신청 테이블
        on s.seq = cr.studentSeq
            inner join tblAttend a -- 출결관리 테이블
                on cr.seq = a.classRegSeq
                    inner join tblOpenClass oc --개설과정 테이블
                        on oc.seq = a.openClassSeq;

select * from vwPeriodAttend; -- *****





--과정별 교육생 출결현황 - 전체 개설과정 출력
create or replace view vwStudentClassAttend
as
select
    oc.seq,
    c.name as classname,
    to_char(oc.startdate, 'YYYY-MM-DD') as startdate,
    to_char(oc.enddate, 'YYYY-MM-DD') as enddate,
    t.name as teachername,
    r.name as roomname
from tblOpenClass oc
    inner join tblroom r
        on r.seq = oc.roomSeq
            inner join tblTeacher t
                on t.seq = oc.teacherSeq
                    inner join tblClass c
                        on c.seq = oc.classSeq;

select * from vwStudentClassAttend;




-- 과정별 교육생 출결현황 - 과정수강중인 교육생의 출결기간검색
create or replace procedure procSelectClassStudentAttend(
    pnum number,
    pindate date,
    poutdate date,
    presult out sys_refcursor
)
is
begin
    open presult for
    select studentname,to_char(attendindate, 'YY-MM-DD') as attendday, to_char(attendindate, 'hh24:mi:ss') as attendindate , to_char(attendoutdate, 'hh24:mi:ss') as attendoutdate, state 
        from vwSpecificClass
            where classseq = pnum and attendindate >= pindate and attendindate <= poutdate order by attendday;
end;

create or replace view vwSpecificClass  -- 뷰생성
as
select
oc.seq as classseq,
c.name as classname,
s.name studentname, 
a.indate as attendindate, 
a.outdate as attendoutdate, 
a.state 
from tblstudent s   -- 학생테이블
    inner join tblClassReg cr   --수강신청테이블
        on s.seq = cr.studentSeq
            inner join tblOpenClass oc  --개설과정테이블
                on cr.openclassSeq = oc.seq
                    inner join tblClass c   --과정테이블
                        on c.seq = oc.classSeq
                            inner join tblAttend a  --출결테이블
                                on cr.seq = a.classRegSeq;

select * from vwSpecificClass;




--------------------------------------------------------
--02.교육생 관리
--------------------------------------------------------
--메인 > 관리자 > 수강생관리
--------------------------------------------------------
--################################################
--교육생 관리 - 교육생 전체출력(교육생이름, 주민등록번호 뒷자리, 전화번호, 등록일, 수강신청(횟수) 출력)
create or replace view vwStudentDetailInfo
as
select 
distinct a.*, count(*)as count
from (select name, pwd , tel, to_char(regDate, 'YYYY-MM-DD') as regDate
            from tblStudent s   -- 교육생 기본정보 테이블
             inner join tblClassReg cr   -- 수강신청 테이블
                on s.seq = cr.studentSeq)a group by name, pwd, tel, regDate;
            
            
select * from vwstudentDetailinfo; --***


--####################################################
--교육생 관리 - 교육생이름으로 검색 기능
create or replace procedure procStudentSearchSelect( -- 학생검색 프록시저
    pname varchar2,
    presult out sys_refcursor
)
is
begin
    open presult for 
    select seq,name, id, pwd, tel, to_char(regDate,'YYYY-MM-DD') as regDate, pwd from tblstudent where name = pname;

end;



select * from tblStudent;



-- #############################################################################
-- 교육생관리 - 교육생 상세정보
create or replace procedure procStudentAcademicInfo(
    pnum number,
    presult out sys_refcursor
)
is
begin
    open presult
        for select studentname, classname, to_char(startdate, 'YYYY-MM-DD') as startdate, to_char(enddate, 'YYYY-MM-DD') as enddate
                    , roomname, to_char(faildate,'YYYY-MM-DD') as faildate, to_char(completdate, 'YYYY-MM-DD') as completdate
            from vwAcademicInfo where studentseq = pnum;
    
end;


-- 교육생 상세정보를 select 하기위한 view
create or replace view vwAcademicInfo
as
select 
        s.seq as studentseq
        ,s.name as studentname
        ,c.name as classname
        ,oc.startDate
        , oc.endDate
        , r.name as roomname
        , si.failDate
        , si.completDate from tblStudent s --학생 테이블
    inner join tblClassReg cr   --수강신청 테이블
        on cr.studentSeq = s.seq
            inner join tblStudentInfo si    --교육생정보 테이블
                on si.classRegSeq = cr.seq
                    inner join tblOpenClass oc  -- 개설과정 테이블
                        on oc.seq = cr.openclassSeq
                            inner join tblRoom r    -- 강의실 테이블
                                on r.seq = oc.roomSeq
                                    inner join tblClass c   -- 과정 테이블
                                        on c.seq = oc.classSeq;
                                        
select * from vwAcademicInfo;

select * from tblstudent;

            
-- ##################################################   
-- 교육생 추가하기 - 교육생 정보 입력시 이름, 주민번호 뒷자리, 전화번호 기본등록, 등록일은 자동입력
create or replace procedure procStudentInsert(
    vname varchar2,
    vssn varchar2,
    vtel varchar2,
    vid varchar2
)
is
begin
    insert into tblstudent(seq, name, tel, regdate, id, pwd) values
    (TBLSTUDNET_SEQ.nextval, vname, vtel, sysdate, vid, vssn);
    
end;


select * from tblstudent;





---- ######################################################
--교육생 관리 - 교육생에대한 수료및 중도 탈락 처리
create or replace procedure procCompletionOrfail( 
    pnum number,
    pfalidate varchar2,
    pcompletdate varchar2
)
is
begin
       
    update vwCompletionOrfail set failDate = pfalidate,
                                    completDate = pcompletdate 
                                        where studentseq = pnum;

end;



-- 교육생관리 - 교육생에대한 수료및 중도 탈락 처리
create or replace view vwCompletionOrfail
as
select  s.seq as studentseq
        ,s.name as studentname
        ,s.pwd as studentssn
        ,s.tel as studenttel
        ,s.id as studentid
        , si.failDate
        , si.completDate
        from tblStudent s --학생 테이블
            inner join tblClassReg cr   --수강신청 테이블
                on cr.studentSeq = s.seq
                    inner join tblStudentInfo si    --교육생정보 테이블
                        on si.classRegSeq = cr.seq
                            inner join tblOpenClass oc  -- 개설과정 테이블
                                on oc.seq = cr.openclassSeq
                                    inner join tblRoom r    -- 강의실 테이블
                                        on r.seq = oc.roomSeq
                                            inner join tblClass c   -- 과정 테이블
                                                on c.seq = oc.classSeq;


select * from vwCompletionOrfail;



--교육생관리 - 선택 교육생 정보를 수정하는 프로시저
create or replace procedure procStudnetInfoChange(
    pseq number,
    pname varchar2,
    pid varchar2,
    ppwd varchar2,
    ptel varchar2
)
is
begin
    update tblstudent set name = pname,
                                    id = pid,
                                    pwd = ppwd,
                                    tel = ptel
                                    where seq = pseq;
    
end;




--교육생관리 - 선택 교육생을 삭제하기전에 자식테이블에 자신이속해있는 것을 양도해주는 trigger
create or replace trigger trgDeleteStudent
    before
    delete on tblstudent
    for each row
declare
begin
    update tblClassReg set
        studentseq = 671
            where studentseq = :old.seq;
end;




--교육생관리 - 선택 교육생을 삭제하는 프로시저
create or replace procedure procStudnetInfoSelectDelete(
    pseq number
)
is
begin
    delete from tblstudent where seq = pseq;
    
end;






------------------------------------------------------------------------
-- 시험 관리 및 성적 조회
-------------------------------------------------------------------------
--메인 > 관리자 > 시험관리 및 성적조회
-------------------------------------------------------------------------
-- 과정별 교육생 성적 조회를 하기위한 view
create or replace view vwclassScore
as
select
    oc.seq,
    c.name as classname,
    to_char(oc.startdate, 'YYYY-MM-DD') as startdate,
    to_char(oc.enddate, 'YYYY-MM-DD') as enddate,
    t.name as teachername,
    r.name as roomname
from tblOpenClass oc
    inner join tblroom r
        on r.seq = oc.roomSeq
            inner join tblTeacher t
                on t.seq = oc.teacherSeq
                    inner join tblClass c
                        on c.seq = oc.classSeq;


select * from vwclassScore;




--성적조회 - 특정 개설 과정을 선택하는 경우 등록된 개설과목 정보 출력, 개설 과목 별 성적 등록 여부, 시험 문제파일 등록 여부
create or replace procedure procSelectSpecificClass(    --프록시저생성
    pnum number, -- 과정번호 입력받기
    presult out SYS_REFCURSOR
)
is
begin
--    open presult
--         for select  from vwSelectSpecificClass;
    open presult for
    select distinct
    studentname,
    writescore, 
    practicescore from vwSelectSpecificClass where openSubjectSeq = pnum;
end;




--성적조회 - 과정별 성적 조회시 전체과정을 출력해주는 view
create or replace view vwSelectSpecificClass
as
select
os.seq as openSubjectSeq,
oc.seq as openClassSeq,
c.name as classname,
sj.name as subjectname, 
to_char(os.startDate, 'YYYY-MM-DD') as startDate,
to_char(os.endDate, 'YYYY-MM-DD') as endDate,
sc.writeScore,
sc.practiceScore,
    case
        when writeScore is null and practiceScore is null then 'X'
        when writeScore is not null and practiceScore is not null then 'O'
    end as scoreReg,
t.write,
t.practice,
b.name as bookname,
s.name as studentname
from tblStudent s
    inner join tblClassReg cr
        on s.seq = cr.studentSeq
            inner join tblScore sc
                on sc.classRegseq = cr.seq
                    inner join tblOpenClass oc
                         on oc.seq = cr.openclassSeq
                            inner join tblclass c
                                on c.seq = oc.classSeq
                                    inner join tblLectureSubject ls
                                        on ls.classSeq = c.seq
                                            inner join tblSubject sj
                                                on sj.seq = ls.subjectSeq
                                                    inner join tblOpenSubject os
                                                        on os.subjectSeq = sj.seq
                                                            inner join tblTest t
                                                                on t.openSubjectSeq = os.seq
                                                                    inner join tblbook b
                                                                        on b.seq = sj.bookSeq;
                                                                        

--성적조회 - 교육생이름 검색시 수강중인 과정에대한 정보를 출력하기위한 view
create or replace view vwStudentIndividualInfo  -- 교육생개인별정보출력
as
select 
s.seq as studentseq,
s.name as studentname,
s.pwd as pwd,
c.name as classname,
to_char(oc.startDate, 'YYYY-MM-DD') as startDate,
to_char(oc.endDate ,'YYYY-MM-DD') as endDate,
r.name as roomname,
sj.name as sujectname,
sj.subjectPeriod ,
t.name as teachername,
sc.writeScore,
sc.practiceScore,
to_char(os.startDate, 'YYYY-MM-DD') as sujectstartDate,
to_char(os.endDate, 'YYYY-MM-DD') as sujectendDate,
sc.classRegseq
from tblstudent s   --교육생테이블 
    inner join tblClassReg cr   --수강신청테이블
        on s.seq = cr.studentSeq
            inner join tblOpenClass oc  --개설과정테이블
                on oc.seq = cr.openclassSeq
                    inner join tblClass c   --과정테이블
                        on c.seq = oc.classSeq
                            inner join tblLectureSubject ls --과정+과목 테이블
                                on ls.classSeq = c.seq
                                    inner join tblSubject sj    -- 과목테이블
                                        on sj.seq = ls.subjectSeq
                                            inner join tblOpenSubject os    --개설과목테이블
                                                on os.subjectSeq = sj.seq
                                                    inner join tblTeacher t --교사테이블
                                                        on t.seq = oc.teacherSeq
                                                            inner join tblScore sc  --점수테이블
                                                                on cr.seq = sc.classRegseq
                                                                    inner join tblroom r
                                                                        on r.seq = oc.roomSeq;
            
      
--성적조회 - 해당 개설 과목을 수강한 모든 교육생들의 성적정보(교육생 이름, 주민번호뒷자리,필기, 실기) 출력을 위한 view
create or replace view vwStudentSujectScore
as
select s.seq as studentseq, s.name as studentname , sc.attendscore as attendscore , sc.writeScore as writeScore , sc.practiceScore as practiceScore
        ,sj.name as sujectname, p.seq as pointseq, to_char(os.startDate, 'YYYY-MM-DD') as sujectstartDate,
        to_char(os.endDate, 'YYYY-MM-DD') as sujectendDate, t.name as teachername
        from tblStudent s 
            inner join tblClassReg cr
                on s.seq = cr.studentSeq 
                    inner join tblOpenClass oc
                        on cr.openclassSeq = oc.seq  
                            inner join tblOpenSubject os
                                on oc.seq = os.openClassSeq 
                                    inner join tblPoint p
                                        on os.seq = p.openSubjectSeq 
                                            inner join tblScore sc
                                                on p.seq = sc.pointSeq 
                                                    inner join tblSubject sj
                                                        on sj.seq = os. subjectSeq
                                                            inner join tblTeacher t
                                                                on oc.teacherSeq = t.seq;




 
