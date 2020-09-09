--final_project.sql
/*
-- INDEX
01. 교사 강의 스케줄 조회 (T_001) -- line 
02. 배점 및 시험정보 입력 (T_002) -- line 20
03. 배점 출력 (T_003) -- line 
04. 성적 입력 (T_004) -- line 
05. 성적 출력 (T_005) -- line 
06. 출결 전체 조회 (T_006) -- line 
07. 출결 월별 조회 (T_007) -- line 
08. 출결 일별 조회 (T_008) -- line 
09. 중도 탈락 조회 (T_009) -- line 

10. 사전평가 조회 (T_010) -- line 
11. 과정평가 조회 (T_011) -- line 
*/

--

--------------------------------------------------------------------------------------------------
-- #T_002
--교사 로그인 성공 > 배점 및 시험 정보 입력 
--------------------------------------------------------------------------------------------------
--1. 교사의 현재 진행중인 과정의 과목 목록 
--Teacher.java > T_001_in()
create or replace view vwTeacherIo2
as
select t.seq as 교사번호, t.name as 교사이름, oc.seq as 과정번호 , s.seq as 과목번호  , s.name as 과목이름  
        , to_char(os.startdate , 'yy/mm/dd') as 시작날짜 , to_char(os.enddate , 'yy/mm/dd') as 끝날짜
        , p.attendpoint as 출결배점 , p.writepoint as 필기배점 , p.practicepoint as 실기배점 
    from tblteacher t --교사
        inner join tblOpenClass oc  --개설과정
            on t.seq = oc.teacherSeq
                inner join tblOpenSubject os --개설과목
                    on oc.seq = os.openclassseq
                        inner join tblSubject s --과목 
                            on os.subjectSeq = s.seq
                                inner join tblPoint p --배점 
                                    on p.opensubjectseq = os.seq 
                                where oc.startdate < sysdate and oc.enddate > sysdate --진행중 강의 
                                    and t.seq = 1
                                    order by s.seq;
                                    
--2. 선택한 과목에 대해 배점 입력 
--Teacher.java > pointIn()
create or replace procedure procTeacherPointIn(
    pnum in number, --과목번호 
    pattend in number, --출결
    pwrite in number, --필기
    ppractice in number, --실기
    presult out number --반환값 
)
is

begin
    --출결 , 필기 , 실기 배점 등록 
    if
        pattend >= 20 and pattend + pwrite + ppractice = 100 then --출결 20점 이상 , 총합 100점 이면 
            update tblPoint 
              set attendPoint = pattend , writePoint = pwrite , practicepoint = ppractice  --값 업데이트 
                where openSubjectSeq = pnum;
                 presult := 1;

    end if;
    
exception 
    when others then
        rollback;
    
end procTeacherPointIn;


--3. 선택한 과목에 대해 시험정보(시험날짜 , 필기문제, 실기문제) 입력 
--Teacher.java > testIn()
create or replace procedure procTeacherTestAdd(

    pnum in number, --과목번호 
    pdate in date, --시험날짜
    pwrite in varchar2, --필기 문제
    ppractice in varchar2, --실기 문제
    presult out number
    
)
is
    vstartdate date; --과목 시작 날짜 
    venddate date; --과목의 끝 날짜 
    
begin
    select enddate into venddate from tblOpenSubject os inner join tblSubject s on os.subjectSeq = s.seq where s.seq = pnum;
    select startdate into vstartdate from tblOpenSubject os inner join tblSubject s on os.subjectSeq = s.seq where s.seq = pnum;
   
    if
        --tblOpenSubject(개설과목) 테이블에서 enddate 가져와서 pdate랑 비교 
        --과목의 끝 날짜가 시험날짜보다 크거나 같아야함.
        pdate > vstartdate and  pdate <= venddate then
    --시험 날짜 , 시험문제 추가 
    insert into tblTest( seq, write, practice, testDate, openSubjectSeq) values (tblTest_seq.nextVal, pwrite , ppractice , pdate , pnum);
    presult := 1;
    
    end if;
    
exception 
    when others then
        rollback;    

end procTeacherTestAdd;


--------------------------------------------------------------------------------------------------
-- #T_003
--교사 로그인 성공 > 배점 출력
--------------------------------------------------------------------------------------------------
--1. 교사가 현재 진행중인 과정에 해당하는 과목의 배점 정보 출력
--Teacher.java > T_001_out()
create or replace view vwTeacherIo2
as
select  oc.seq as 과정번호 , s.seq as 과목번호  , s.name as 과목이름 , p.attendpoint as 출결배점 , p.writepoint as 필기배점 , p.practicepoint as 실기배점 
    from tblteacher t --교사
        inner join tblOpenClass oc  --개설과정
            on t.seq = oc.teacherSeq
                inner join tblOpenSubject os --개설과목
                    on oc.seq = os.openclassseq
                        inner join tblSubject s --과목 
                            on os.subjectSeq = s.seq
                                inner join tblPoint p --배점 
                                    on p.opensubjectseq = os.seq 
                                where oc.startdate < sysdate and oc.enddate > sysdate --진행중 강의 
                                    and t.seq = 1
                                    order by s.seq;
                                    
                                    
                                    
--------------------------------------------------------------------------------------------------
-- #T_004
--교사 로그인 성공 > 성적 입력 
--------------------------------------------------------------------------------------------------                   
--1. 교사가 현재 진행중인 과정에 해당하는 과목의 배점 정보 출력
--Teacher.java > T_004
create or replace view vwTeacherIo2
as
select  oc.seq as 과정번호 , s.seq as 과목번호  , s.name as 과목이름 , p.attendpoint as 출결배점 , p.writepoint as 필기배점 , p.practicepoint as 실기배점 
    from tblteacher t --교사
        inner join tblOpenClass oc  --개설과정
            on t.seq = oc.teacherSeq
                inner join tblOpenSubject os --개설과목
                    on oc.seq = os.openclassseq
                        inner join tblSubject s --과목 
                            on os.subjectSeq = s.seq
                                inner join tblPoint p --배점 
                                    on p.opensubjectseq = os.seq 
                                where oc.startdate < sysdate and oc.enddate > sysdate --진행중 강의 
                                    and t.seq = 1
                                    order by s.seq;

--2. 선택한 과목에 해당하는 학생 정보 출력
create or replace procedure procStudentList(

    psubjectNum number, --과목번호 
    presult out sys_refcursor
)
is
begin
open presult for
select distinct s.seq as 학생번호 , s.name as 학생이름 , sc.attendScore as 출결 , sc.writeScore as 필기 , sc.practiceScore as 실기
    from tblOpenClass oc --개설과정
        inner join tblOpenSubject os --개설과목
            on oc.seq = os.openClassSeq 
                inner join tblClassReg cr --수강신청
                    on cr.openclassSeq = oc.seq 
                        inner join tblStudent s --학생
                            on s.seq = cr.studentseq
                                inner join tblScore sc  --점수
                                    on cr.seq = sc.classRegseq
                                        where os.seq = psubjectNum -- 과목번호 
                                            and os.enddate < sysdate
                                                    order by s.seq; 

exception 
    when others then
        rollback;
end;



--3. 입력받은 점수 입력
create or replace procedure procTeacherScoreIn(
    pnum in number, --과목번호 
    pattend in number, --출결점수
    pwrite in number, --필기점수
    ppractice in number, --실기점수
    pclassRegseq in number --수강신청 기본키

)
is

begin
    --출결 , 필기 , 실기 점수 등록 
                update tblScore set attendScore = pattend , writeScore = pwrite , practiceScore = ppractice 
                        where classRegseq = (select seq from tblClassReg where studentSeq= pclassRegseq ) ;
                
   exception 
    when others then
        rollback; 
end procTeacherScoreIn;






--------------------------------------------------------------------------------------------------
-- #T_005
--교사 로그인 성공 > 성적 출력
--------------------------------------------------------------------------------------------------       
--1. 교사가 현재 진행중인 과정정보 출력
--Teacher.java > T_007()
create or replace procedure procPreList(
    pnum number, --교사 번호 
    presult out sys_refcursor 
)
is
begin
open presult for 
select oc.seq as 과정번호, c.name as 과정명 , to_char(oc.startdate, 'yy/mm/dd') as 시작날짜, to_char(oc.enddate, 'yy/mm/dd') as 끝날짜 , r.name as 강의실 
    from tblTeacher t --교사 
        inner join tblOpenClass oc --개설 과정 
            on t.seq = oc.teacherSeq 
                inner join tblOpenSubject os --개설 과목 
                    on os.openClassSeq = oc.seq 
                inner join tblClass c --과정 
                    on c.seq = oc.classSeq 
                        inner join tblRoom r --강의실
                         on r.seq = oc.roomseq
                            where oc.startdate < sysdate and oc.enddate > sysdate and teacherSeq = pnum -- 교사가 현재 진행하고 있는 과정
                            order by oc.seq ;
end;                            


--2. 과정 선택시 과정에 해당하는 과목정보 출력
create or replace procedure procSubjectOut(
    pnum1 number, --교사 번호
    presult out sys_refcursor 
)
is
begin
open presult for
select distinct s.seq as 과목번호 ,c.name as 과정명, to_char(oc.startdate,'yy/mm/dd') as 과정시작 , to_char(oc.enddate,'yy/mm/dd') as 과정끝 
        , r.name as 강의실 , s.name as 과목명 , to_char(os.startdate,'yy/mm/dd') as 과목시작 , to_char(os.enddate,'yy/mm/dd') as 과목끝 
        , b.name as 교재명 , p.attendpoint as 출결 , p.writepoint as 필기 , p.practicepoint as 실기 , t.seq as 교사번호 , os.openclassseq as 과정번호 , 
            case
                when sc.attendScore is not null and sc.writeScore is not null and sc.practiceScore is not null then 'O'
          end as 성적등록여부
    from tblBook b --교재
        inner join tblsubject s --과목
            on b.seq = s.bookseq
            inner join tblOpenSubject os --개설과목
                on s.seq = os.subjectseq
                    left outer join tblPoint p --배점
                        on os.seq = p.opensubjectseq
                            left outer join tblopenclass oc --개설과정
                                on os.openclassseq = oc.seq
                                    left outer join tblClass c --과정
                                        on oc.classseq = c.seq
                                            left outer join tblRoom r --강의실
                                                on oc.roomseq = r.seq
                                                    inner join tblTeacher t --교사
                                                       on t.seq = oc.teacherSeq
                                                        inner join tblScore sc  --점수
                                                            on p.seq = sc.pointSeq
                                                            where os.openClassSeq = pnum1 --과정 번호에 해당하는 과목들 
                                                    order by s.seq;
end;  



--3. 특정 과목 선택시 해당 과목을 수강하는 학생들의 점수 출력 
create or replace procedure procStudentInfo(

    pnum number, --입력한 과목번호 
    presult out sys_refcursor
    
)
is
begin
open presult for
select 
        st.seq as 학생번호, st.name as 이름 , st.tel as 전화번호 , os.seq as 과목번호,
            case 
            when si.completdate is not null and si.faildate is null  then '수료'
            when si.completdate is null and si.faildate is not null then '중도탈락'
        end as 수료및탈락 ,
        
        sco.attendScore *(select attendpoint from tblPoint where openSubjectSeq = 1 )* 0.01 as 출결점수,
        sco.writeScore *(select writepoint from tblPoint where openSubjectSeq = 1 )* 0.01 as 필기점수,
        sco.practiceScore *(select practicepoint from tblPoint where openSubjectSeq = 1 )* 0.01 as 실기점수       
        
                      from  tblPoint p --배점
                        inner join tblScore sco --점수 
                            on p.seq = sco.pointseq                                  
                                inner join tblClassReg cr --수강신청(*)
                                    on sco.classRegseq = cr.seq
                                        inner join tblStudent st --교육생 기본정보 
                                            on cr.studentSeq = st.seq
                                                inner join tblStudentInfo si --교육생 정보 
                                                    on cr.seq = si.classregseq
                                                        inner join tblOpenClass oc --개설과정
                                                            on oc.seq = cr.openclassSeq
                                                               inner join tblOpenSubject os --개설과목 
                                                                    on os.openClassSeq = oc.seq 
                                                                         where os.seq = pnum
                                                                              order by  p.opensubjectseq;
                                                         
  exception 
    when others then
        rollback;

end procStudentInfo;    






--------------------------------------------------------------------------------------------------
-- #T_006
--교사 로그인 성공 > 전체 출결 상황 출력
--------------------------------------------------------------------------------------------------       
--1. 교사가 현재 진행한 과정 목록 출력
--Teacher.java > T_009()
create or replace procedure procTeacherClass(

    pnum number , --교사 번호
    presult out sys_refcursor

)
is
begin
    open presult for
        select t.seq as 교사 , oc.seq as 과정번호, c.name as 과정명 
            from tblTeacher t  --교사
                inner join tblOpenClass oc  --개설과정
                    on t.seq = oc.teacherseq 
                        inner join tblClass c --과정
                            on oc.classseq = c.seq 
                                where t.seq = pnum;                                          
  exception 
    when others then
        rollback;
end;


--2. 과정 선택시 그 과정을 수강하는 학생들의 출결 상황 출력 
create or replace procedure procStudentAttend(

    pnum number, --과정 번호 
    presult out sys_refcursor

)
is
begin
open presult for
select distinct oc.seq as 과정번호, s.name as 이름 , 
   to_char( a.indate , 'hh24:mi:ss') as 출근시간 , 
    to_char( a.outdate , 'hh24:mi:ss') as 퇴근시간 , 
    case
        when to_char(a.indate , 'hh24  ') < 9 then '정상'
        when to_char(a.indate , 'hh24  ') >= 9 then '지각'
        when to_char(a.indate , 'hh24  ') < 9 and to_char(a.outdate , 'hh24  ') < 5 then '조퇴'
    end as 근태상황 , 
    to_char(a.indate, 'yy/mm/dd') as 날짜
        from tblTeacher t --교사 
            inner join tblopenclass oc --개설과정
                on t.seq = oc.teacherSeq
                    inner join tblClassReg cr --수강신청
                        on oc.seq = cr.openclassseq
                            inner join tblStudent s --교육생 기본정보
                                on cr.studentseq = s.seq 
                                    inner join tblAttend a --출석
                                        on cr.seq = a.classRegSeq
                                            where oc.seq = pnum
                                                order by to_char(a.indate, 'yy/mm/dd');

  exception 
    when others then
        rollback;

end; 




--------------------------------------------------------------------------------------------------
-- #T_007
--교사 로그인 성공 > 출결 월별 조회
--------------------------------------------------------------------------------------------------       
--1. 출결상황 월 별로 입력받아 출력
--Teacher.java > T_011()
create or replace procedure procMonth(
    pnum number, --월 입력 
    presult out sys_refcursor
)
is
begin
open presult for
    select *from vwStudentAttend where substr(날짜,4,2) = pnum ;
end;          



--------------------------------------------------------------------------------------------------
-- #T_008
--교사 로그인 성공 > 출결 일별 조회
--------------------------------------------------------------------------------------------------       
--1. 출결상황 일 별로 입력받아 출력
--Teacher.java > T_012()
create or replace procedure procDate(
    pnum number, --일 입력 
    presult out sys_refcursor
)
is
begin
open presult for
    select *from vwStudentAttend where substr(날짜,7,2) = pnum ;
end;     



--------------------------------------------------------------------------------------------------
-- #T_009
--교사 로그인 성공 > 중도 탈락 조회
--------------------------------------------------------------------------------------------------       
--1. 교사가 진행하고 있는 과정의 학생 목록을 중도탈락 여부를 구분하여 출력 
--Teacher.java > T_010()
create or replace procedure procFail(
    pnum number, --교사 번호 
    presult out sys_refcursor
)
is
begin
open presult for
select s.name as 이름,
        case
            when si.faildate is null then 'X'
            when si.faildate is not null then 'O'
        end as 중도탈락여부 ,
        to_char(si.faildate,'yy/mm/dd') as 중도탈락날짜 ,
        cr.openclassSeq as 과정번호 
        from tblStudentInfo si --학생정보
            inner join tblClassReg cr --수강신청
                on si.classregseq = cr.seq
                    inner join  tblStudent s --학생 
                        on cr.studentseq = s.seq
                            inner join tblOpenClass oc --개설과정
                                on oc.seq = cr.openclassSeq
                                    inner join tblTeacher t --교사
                                        on t.seq = oc.teacherSeq
                            where oc.teacherseq = pnum
                            order by s.name;
end;

