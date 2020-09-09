/*
[관리자]
-- INDEX
00. 관리자 계정
01. 교사 계정 관리
01. 교사 계정 관리 - 강의가능 목록
     1. 강의 가능 목록 전체 조회
     2. 강의 가능 목록 선택 조회
     3. 강의 가능 목록 교사별 추가
01-2. 교사 계정 관리 - 교사 정보 등록
01-3. 교사 계정 관리 - 교사 정보 수정
     1.이름 수정
     2.비밀번호 수정
     3.전화번호 수정
     4.전체 수정
01-4. 교사 계정 관리 - 교사 정보 삭제
01-5. 교사 계정 관리 - 정보 상세보기
06. 인센티브 관리
06-1 인센티브 관리
     1.인센티브 주기
     2.인센티브 총점 배점 수정
     3.교사평가 설문지 추가
06-2 개설 과정별 설문 내용 조회

*/

/*
[교사]
-- INDEX
00. 교사 계정
01. 강의 스케줄 조회
    1. 과정, 과목 출력
    2. 수강생 목록 조회
11. 과정 평가
    1. 평가 총점 조회
    2. 교사 평가 조회 
*/

/*
[수강생]
-- INDEX
01. 수강생 과정 평가
*/

--------------------------------------------------------------------------------------------------------------------
-- A.000 관리자계정
--------------------------------------------------------------------------------------------------------------------
--로그인 시 id와 비밀번호 비교, 해당 계정 정보 가져오기
--관리자 id -> 관리자 번호 가져오기
create or replace procedure procALoginId(
    pid varchar2,
    pseq out number
)
is 
begin
    select seq into pseq from tbladmin where id = pid;-- 관리자 계정 테이블
end;

--관리자 비밀번호 -> id와 관리자 번호 가져오기
create or replace procedure procALoginPw(
    ppw varchar2,
    pseq out number,
    pid out varchar2
)
is 
begin
    select seq, id into pseq, pid from tbladmin where pwd = ppw;--관리자 계정 테이블
end;

--------------------------------------------------------------------------------------------------------------------
-- A.001_01 교사 계정 관리 - 강의 가능 목록
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 강의 가능 목록
--------------------------------------------------------------------------------------------------------------------
-- 교사 정보 출력(번호, 이름, 주민번호뒷자리, 전화번호)
create or replace procedure procTInfor(
    presult out sys_refcursor 
)
is
begin
    open presult for
        select seq, name, id ,pw, tel 
            from tblteacher --교사정보테이블
                where status <> '퇴사' order by seq; --퇴사자를 제외한 모든 교사의 정보 출력
end;

--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 강의 가능 목록 > 강의 가능 목록 전체 조회
--------------------------------------------------------------------------------------------------------------------
--교사 전체 강의 가능 과목 출력

--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 강의 가능 목록 > 강의 가능 목록 선택 조회
--------------------------------------------------------------------------------------------------------------------
--선택 교사의 강의 가능 과목 출력 (과목번호, 이름)
create or replace procedure procTInforSubject(
    ptseq number,--선택 교사
    presult out sys_refcursor --과목번호, 이름
)
is
begin
    open presult for
        select sseq, sname 
            from vwTInfor 
                where tseq = ptseq order by sseq; 
end;

-- 교사정보: 교사 이름, 주민번호 뒷자리, 전화번호, 강의 가능 과목
create or replace view vwTInfor
as
select 
    t.seq as tseq, t.name as tname, t.pw, t.tel, s.seq as sseq ,s.name as sname
from tblteacher t   -- 교사
    inner join tblpossible p    -- 교사 + 과목    
        on t.seq = p.teacherseq 
            inner join tblsubject s -- 과목
                on s.seq = p.subjectseq
                    order by t.seq;


--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 강의 가능 목록 > 강의 가능 목록 교사별 추가
--------------------------------------------------------------------------------------------------------------------
--전체 과목목록 출력 (과목번호, 과목이름)
create or replace procedure procTSubAll(
    presult out sys_refcursor --과목번호, 과목이름
)
is
begin
    open presult for
        select seq, name from tblsubject order by seq; --과목테이블
end;

--선택 교사의 강의 가능 과목 추가
create or replace procedure procTPossibleInsert(
    ptseq number,   --교사 번호 
    pcname varchar2 --과목 이름
)
is
begin
    insert into tblpossible (seq, teacherseq, subjectseq) --강의가능과목 테이블에 추가
        values (TBLPOSSIBLE_SEQ.nextval, ptseq, (select seq from tblsubject where name = pcname));
        
        commit;--성공시 commit
      
exception--예외처리, 오류 발생시 rollback
    when others then
        rollback;
end;

--------------------------------------------------------------------------------------------------------------------
-- A.001_02 교사 계정 관리 - 교사 정보 등록
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 교사 계정 관리 > 교사 정보 등록
--------------------------------------------------------------------------------------------------------------------
create or replace procedure procTInforInsert(
    pname varchar2, --이름
    ptel varchar2,  --전화번호
    pid varchar2,   --id
    ppw varchar2    --비밀번호
)
is
begin
    insert into tblteacher (seq, name, tel, id, pw, status) 
        values (TBLTEACHER_SEQ.nextval, pname, ptel, pid, ppw, '대기'); --최초 등록시 상태 default = '대기'
        
        commit;--성공시 commit
      
exception--예외처리, 오류 발생시 rollback
    when others then
        rollback;
end;

--------------------------------------------------------------------------------------------------------------------
-- A.001_03 교사 계정 관리 - 교사 정보 수정
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 교사 계정 관리 > 교사 정보 수정 > 이름수정
--------------------------------------------------------------------------------------------------------------------
create or replace procedure procTInforUpdateName(
    pseq varchar2, --교사번호를 받아온다.
    pname varchar2 --수정할 이름을 입력한다.
)
is
begin
    update tblteacher set name = pname where seq = pseq;
end;

--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 교사 계정 관리 > 교사 정보 수정 > 비밀번호수정
--------------------------------------------------------------------------------------------------------------------
create or replace procedure procTInforUpdatePw(
    pseq varchar2,--교사번호를 받아온다.
    ppw varchar2  --수정할 비밀번호를 입력한다.
)
is
begin
    update tblteacher set pw = ppw where seq = pseq;
end;

--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 교사 계정 관리 > 교사 정보 수정 > 전화번호수정
--------------------------------------------------------------------------------------------------------------------
create or replace procedure procTInforUpdateTel(
    pseq varchar2,--교사번호를 받아온다.
    ptel varchar2--수정할 전화번호를 입력한다.
)
is
begin
    update tblteacher set tel = ptel where seq = pseq;
end;

--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 교사 계정 관리 > 교사 정보 수정 > 전체수정
--------------------------------------------------------------------------------------------------------------------
create or replace procedure procTInforUpdate(
    pseq varchar2,--교사번호를 받아온다.
    pname varchar2,--수정할 이름을 입력한다.
    ppw varchar2,   --수정할 비밀번호를 입력한다.
    ptel varchar2   --수정할 전화번호를 입력한다.
)
is
begin
    update tblteacher set name = pname, pw = ppw, tel = ptel where seq = pseq;
end;

--------------------------------------------------------------------------------------------------------------------
-- A.001_04 교사 계정 관리 - 교사 정보 삭제
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 교사 계정 관리 > 교사 정보 삭제
--------------------------------------------------------------------------------------------------------------------
create or replace procedure procTInfordelete(
    pseq varchar2--삭제할 교사번호를 받아온다.
)
is
begin
    update tblteacher set status = '퇴사' where seq = pseq;--상태를 '퇴사'로 바꾼다.
end;

--------------------------------------------------------------------------------------------------------------------
-- A.001_05 교사 계정 관리 - 정보 상세보기
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 교사 계정 관리 > 교사 계정 관리 > 정보 상세보기
--------------------------------------------------------------------------------------------------------------------
--정보상세보기1. 과정번호, 과정이름, 과정기간, 강의실
create or replace procedure procTScadualInfoClass(
    ptseq number,
    presult out sys_refcursor
)
is
begin
    open presult for 
        select * from vwTScadualInfoClass where tseq = ptseq order by ocstartdate;
end;

create or replace view vwTScadualInfoClass
as
select 
    t.seq as tseq, c.seq as cseq, c.name as cname, to_char(oc.startdate, 'yyyy-mm-dd') as ocStartdate
        ,to_char(oc.enddate, 'yyyy-mm-dd') as ocEnddate ,r.name as rname
            from tblopenclass oc --개설과정
                    inner join tblclass c --과정
                        on c.seq = oc.classseq
                            inner join tblteacher t --교사
                                on t.seq = oc.teacherseq
                                   inner join tblroom r --강의실
                                        on r.seq = oc.roomseq
--                                           where t.seq = 1    --교사 선택
order by oc.seq; 


--정보상세보기2. 과목번호, 과목명, 과목기간, 교재명, 진행여부
create or replace procedure procTCTInfo(
    ptseq number,
    presult out sys_refcursor
)
is
begin
    open presult for
        select * from vwTCTInfoSub where tseq = ptseq;
end;

create or replace view vwTCTInfoSub
as
select 
    t.seq as tseq, s.seq as sseq, s.name as sname, to_char(os.startdate, 'yyyy-mm-dd') as osStartdate, to_char(os.enddate, 'yyyy-mm-dd') as osEnddate, c.name as cname
    ,oc.startdate as ocstartdate, oc.enddate as ocEnddate, b.name as bname, r.name as rname,
    case
        when TO_char(os.startdate, 'yyyymmdd') > TO_char(sysdate,'yyyymmdd') then '강의예정'
        when TO_char(os.startdate, 'yyyymmdd') < TO_char(sysdate,'yyyymmdd') and
              TO_char(os.enddate, 'yyyymmdd') > TO_char(sysdate,'yyyymmdd')  then '강의중'
        else '강의종료'
    end as subjecProgress
from tblsubject s -- 과목
    inner join tblopensubject os --개설과목
        on s.seq = os.subjectseq    
            right outer join tblopenclass oc --개설과정
                on oc.seq = os.openclassseq
                    inner join tblclass c --과정
                        on c.seq = oc.classseq
                            inner join tblteacher t --교사
                                on t.seq = oc.teacherseq
                                   inner join tblroom r --강의실
                                        on r.seq = oc.roomseq
                                            inner join tblbook b  --교재
                                                on b.seq = s.bookseq
--                                                    where t.seq = 1    --교사 선택
order by oc.seq, osStartdate;                                

--------------------------------------------------------------------------------------------------------------------
-- A.006 인센티브 관리
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 인센티브 관리
--------------------------------------------------------------------------------------------------------------------
-- 교사 급여 출력. 번호, 이름, 급여, 인센티브
select * from vwTSalary;

create or replace view vwTSalary
as
select t.seq, t.name, sa.salary, sa.incentive from tblsalary sa
    inner join tblteacher t  
        on sa.teacherseq = t.seq
            where t.status <> '퇴사'
                order by t.seq;

-- 교사 번호 입력 받아 총점, 설문점수, 취업률 출력
create or replace procedure procIncentiveView(
    pteacherseq number, -- 교사 선택
    presult out number,  -- sumAss + employee
    vsumAss out number, --설문지결과
    vemployee out number   --취업률
)
is
    vcore number; --평가점수
    vemp number;    --취업률
begin
    select 
        round(sum(assr.result)/300 ,2) into vsumAss
    from tblasssurvey ass -- 평가 설문지
        inner join tblasssurbeyresult assr  -- 평가 설문지 결과
            on ass.seq = assr.asssurveyseq
                right outer join tblopenclass oc    -- 개설 과정
                    on oc.seq = ass.openclassseq
                        where oc.teacherseq = pteacherseq;    -- 교사 선택
    select 
        round(sum(case
            when si.employee = 'O' then 1
        end) / count(*),2) into vemployee
    from tblstudentinfo  si -- 교육생 정보
        inner join tblclassreg cr   -- 수강신청
            on si.classregseq = cr.seq  
                inner join tblopenclass oc  --개설과정
                    on oc.seq = cr.openclassseq
                        where oc.teacherseq = pteacherseq;    -- 교사 선택
    
    select score into vcore from tblincentivepoint;
    select employeeratio into vemp from tblincentivepoint;
    
    presult := vsumAss * vcore + vemployee * vemp;     
end;

--------------------------------------------------------------------------------------------------------------------
-- A.006_01 인센티브 관리 - 인센티브 주기
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 인센티브 관리 > 인센티브 관리 > 인센티브 주기
--------------------------------------------------------------------------------------------------------------------
-- 인센티브 계산 프로시저
create or replace procedure procIncentivePoint(
    pteacherseq number, -- 교사 선택
    presult out number  -- sumAss + employee
)
is
    vsumAss number; --설문지결과
    vemployee number;   --취업률
    vcore number;
    vemp number;
--    vresult number := vsumAss + vemployee;
begin
    select score into vcore from tblincentivepoint;
    select employeeratio into vemp from tblincentivepoint;
    
    select 
        round(sum(assr.result)/300 ,1) * vcore into vsumAss
    from tblasssurvey ass -- 평가 설문지
        inner join tblasssurbeyresult assr  -- 평가 설문지 결과
            on ass.seq = assr.asssurveyseq
                right outer join tblopenclass oc    -- 개설 과정
                    on oc.seq = ass.openclassseq
                        where oc.teacherseq = pteacherseq;    -- 교사 선택
    select 
        round(sum(case
            when si.employee = 'O' then 1
        end) / count(*),1) * vemp into vemployee
    from tblstudentinfo  si -- 교육생 정보
        inner join tblclassreg cr   -- 수강신청
            on si.classregseq = cr.seq  
                inner join tblopenclass oc  --개설과정
                    on oc.seq = cr.openclassseq
                        where oc.teacherseq = pteacherseq;    -- 교사 선택
    dbms_output.put_line(vemployee + vsumass);
    
    presult := vsumAss + vemployee;     
end;

-- 인센티브 update 프로시저 -> 교사 번호 입력
create or replace procedure procIncentiveUpdate(
    pteacherseq number
)
is
--    vteacherseq number := 7;
    vresult number;
begin
    procincentivepoint(pteacherseq,vresult);
    if vresult > 0 and vresult <= 0.2 then
        update tblsalary set incentive = 50000 where teacherseq = pteacherseq;
    elsif vresult > 0.2 and vresult <= 0.4 then
        update tblsalary set incentive = 100000 where teacherseq = pteacherseq;
    elsif vresult > 0.4 and vresult <= 0.6 then
        update tblsalary set incentive = 150000 where teacherseq = pteacherseq;
    elsif vresult > 0.6 and vresult <= 0.8 then
        update tblsalary set incentive = 200000 where teacherseq = pteacherseq;
    elsif vresult > 0.8 then
        update tblsalary set incentive = 250000 where teacherseq = pteacherseq;
    elsif vresult is null then
        update tblsalary set incentive = 0 where teacherseq = pteacherseq;    
    end if;
end;

begin
    procIncentiveUpdate(1);
end;

--------------------------------------------------------------------------------------------------------------------
-- A.006_02 인센티브 관리 - 인센티브 총점 배정 수정
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 인센티브 관리 > 인센티브 총점 배정 수정
--------------------------------------------------------------------------------------------------------------------
--인센티브 배점 출력
select * from tblincentivepoint;

--설문점수와 취업률 배점 수정
create or replace procedure procIncentivepointUpdate(
    pscore number,--설문점수 베점
    pemployeeratio number--취업률 배점
)
is
begin
    update tblincentivepoint set score = pscore;--인센티브 배점 테이블
    update tblincentivepoint set employeeratio = pemployeeratio;
end;

--------------------------------------------------------------------------------------------------------------------
-- A.006_03 인센티브 관리 - 교사평가 설문지 추가
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 인센티브 관리 > 교사평가 설문지 추가
--------------------------------------------------------------------------------------------------------------------
--개설과정 번호, 이름 출력
select DISTINCT ocseq, name from vwAssurveyClass order by ocseq;

--개설과정 번호, 질문번호 입력 -> 질문 추가
create or replace procedure procAssPlus(
    pocseq number, --과정번호
    pAroutnum number, --과목질문 순서 
    pquestion varchar2 -- 질문
)
is
begin
    insert into tblasssurvey (seq, question, outnum, openclassseq)
        values (TBLASSSURVEY_SEQ.nextval, pquestion, pAroutnum, pocseq);  
end;

--항목번호 입력 -> 결과 추가
create or replace procedure procAiPlus(
    pAIoutnum number, --배점
    pcontent varchar2   --항목 내용
)
is
begin
    insert into tblasssurveyitem (seq,content,outnum,asssurveyseq)
        values (TBLASSSURVEYITEM_SEQ.nextval, pcontent,pAIoutnum,
        (select max(seq) from tblasssurvey));
end;

--------------------------------------------------------------------------------------------------------------------
-- A.006_04 인센티브 관리 - 개설 과정별 설문 내용 조회
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 관리자 > 인센티브 관리 > 개설 과정별 설문 내용 조회
--------------------------------------------------------------------------------------------------------------------
--개설과정 번호, 이름 출력
select DISTINCT ocseq, name from vwAssurveyClass order by ocseq;

create or replace view vwAssurveyClass
as
select oc.seq as ocseq, c.name, a.seq as aseq, a.outnum as outnum , a.question, i.content , i.outnum as ioutNum
    from tblAssSurvey a    -- 평가 설문지 내용    
        inner join tblasssurveyitem i                           -- 함목
            on a.seq = i.asssurveyseq           
                inner join tblopenclass oc                       -- 개설 과정
                    on oc.seq = a.openclassseq
                        inner join tblclass c                   -- 과정
                            on c.seq = oc.classseq;

--개설과정 번호 입력 -> 개설과정 이름, 해당 질문들 출력
create or replace procedure procAssClassNQ(
    pnum number,    --개설과정 번호
    presult out sys_refcursor -- 이름, 해당 질문
)
is
begin
    open presult for
        select DISTINCT name, aseq ,question from vwAssurveyClass where ocseq = pnum order by aseq;
end;


--개설과정 번호, 질문내용, 설문번호 입력 -> 항목점수, 항목내용 출력
create or replace procedure procAssClassCon(
    pnum number,                    --개설과정 번호
    pname vwAssurveyClass.name%type,--개설과정 이름
    paseq number,                   --설문번호
    presult out sys_refcursor 
)
is
begin
    open presult for
        select * from vwAssurveyClass where ocseq =pnum
            and name = pname and aseq = paseq ;
end;

--------------------------------------------------------------------------------------------------------------------
-- T.000 교사계정
--------------------------------------------------------------------------------------------------------------------
--로그인 시 id와 비밀번호 비교, 해당 계정 정보 가져오기
--교사 id 입력 -> 교사 번호 가져오기
create or replace procedure procTtdLoginId(
    pid varchar2,
    pseq out number
)
is 
begin
    select seq into pseq from tblteacher where id = pid;--
end;

--교사 비밀번호 -> 교사번호, id, 이름 가져오기
create or replace procedure procTtdLoginPw(
    ppw varchar2,
    pseq out number,
    pid out varchar2,
    pname out varchar2
)
is 
begin
    select seq, id, name into pseq, pid, pname from tblteacher where pw = ppw;
end;

--------------------------------------------------------------------------------------------------------------------
-- T.001 강의 스케줄 조회
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 교사 > 강의 스케줄 조회
--------------------------------------------------------------------------------------------------------------------
--로그인 한 교사 강의 스케줄 출력
create or replace procedure procTScadual(
    ptseq number,--교사번호
    presult out sys_refcursor
)
is
begin
    open presult for
        select * from vwTScadual where seq = ptseq; 
end;

--자신의 강의 스케줄 확인(강의 예정, 강의 중, 강의 종료로 구분)
create or replace view vwTScadual
as
select 
   t.seq , s.name ,
    case
        when TO_char(startdate, 'yyyymmdd') > TO_char(sysdate,'yyyymmdd') then '강의예정'
        when TO_char(startdate, 'yyyymmdd') < TO_char(sysdate,'yyyymmdd') and
              TO_char(enddate, 'yyyymmdd') > TO_char(sysdate,'yyyymmdd')  then '강의중'
        else '강의종료'
    end as subjecProgress
from tblteacher t --교사
    inner join tblpossible p --교사_+ 과목
        on t.seq = p.teacherseq
            inner join tblsubject s -- 과목
                on s.seq = p.subjectseq
                    inner join tblopensubject os    --개설과목
                        on os.subjectseq = s.seq
                            order by os.startdate;
--                            where t.seq = 1;        --교사 선택 

--------------------------------------------------------------------------------------------------------------------
-- T.001_01 강의 스케줄 조회 - 강의 스케줄 정보 조회
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 교사 > 강의 스케줄 조회 > 강의 스케줄 정보 조회
--------------------------------------------------------------------------------------------------------------------
--로그인 한 교사 강의 스케줄 정보 출력
--과정정보 (과정번호 과정이름, 과정기간, 강의실)
create or replace procedure procTScadualInfoClass(
    ptseq number,
    presult out sys_refcursor 
)
is
begin
    open presult for 
        select * from vwTScadualInfoClass where tseq = ptseq order by ocstartdate;
end;

create or replace view vwTScadualInfoClass
as
select 
    t.seq as tseq, c.seq as cseq, c.name as cname, to_char(oc.startdate, 'yyyy-mm-dd') as ocStartdate, to_char(oc.enddate, 'yyyy-mm-dd') as ocEnddate ,r.name as rname
        from tblopenclass oc --개설과정
                inner join tblclass c --과정
                    on c.seq = oc.classseq
                        inner join tblteacher t --교사
                            on t.seq = oc.teacherseq
                                inner join tblroom r --강의실
                                    on r.seq = oc.roomseq
--                                         where t.seq = 1    --교사 선택
order by oc.seq;   

--인원수 출력
select count(*) as cnt from vwTScadualInfo where tseq = 1; --1 = 교사번호 입력

create or replace view vwTScadualInfo
as
select 
    oc.seq as ocseq ,t.seq as tseq, s.seq as sseq, c.name as cname, to_char(oc.startdate, 'yyyy-mm-dd') as ocStartdate, to_char(oc.enddate, 'yyyy-mm-dd') as ocEnddate
    ,r.name as rname, s.name as sname, to_char(os.startdate, 'yyyy-mm-dd') as osStartdate, to_char(os.enddate, 'yyyy-mm-dd') as osEnddate, b.name as bname
from tblsubject s -- 과목
    inner join tblopensubject os --개설과목
        on s.seq = os.subjectseq    
            inner join tblopenclass oc --개설과정
                on oc.seq = os.openclassseq
                    inner join tblclass c --과정
                        on c.seq = oc.classseq
                            inner join tblteacher t --교사
                                on t.seq = oc.teacherseq
                                   inner join tblroom r --강의실
                                        on r.seq = oc.roomseq
                                            inner join tblbook b  --교재
                                                on b.seq = s.bookseq
--                                                    where t.seq = 1    --교사 선택
order by oc.seq, os.startdate;   


--과목정보 (과목번호, 과목이름, 과정기간, 강의실)
create or replace procedure procTScadualInfoClass(
    ptseq number,
    presult out sys_refcursor
)
is
begin
    open presult for 
        select * from vwTScadualInfoClass where tseq = ptseq order by ocstartdate;
end;

--------------------------------------------------------------------------------------------------------------------
-- T.001_01_01 강의 스케줄 조회 - 강의 스케줄 정보 조회 - 수강생 목록 조회
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 교사 > 강의 스케줄 조회 > 강의 스케줄 정보 조회 > 수강생 목록 조회
--------------------------------------------------------------------------------------------------------------------
--교육생 정보 출력 (이름, 전화번호, 등록일, 수료여부)
create or replace procedure procTSubStInfo(
    psseq number,
    presult out sys_refcursor 
)
is
begin
    open presult for
        select * from vwTSubStInfo where seq = psseq;
end;
-- 특정 과목을 과목번호로 선택 시 해당 과정에 등록된 교육생 정보(교육생 이름, 전화번호, 등록일, 수료 또는 중도탈락) 확인
create or replace view vwTSubStInfo
as
select
    t.seq, st.name, st.tel, to_char(st.regdate, 'yyyy-mm-dd') as regdate,
    case
        when si.completdate is not null then '수료'
        when si.faildate is not null then '중도탈락'
    end as complet
        from tblopenclass oc    --개설과정
                inner join tblclass c   --과정
                    on c.seq = oc.classseq
                        inner join tblteacher t --교사
                            on t.seq = oc.teacherseq
                                inner join tblclassreg cl --수강신청
                                    on cl.openclassseq = oc.seq
                                        inner join tblstudent st    --교육생
                                            on st.seq = cl.studentseq   
                                                inner join tblstudentinfo si  --교육생 정보
                                                    on si.classregseq = cl.seq
--                                                      where s.seq = 2 -- 특정과목 선택
order by oc.seq;

--------------------------------------------------------------------------------------------------------------------
-- T.011 교사 평가 조회
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 교사 > 교사 평가 조회
--------------------------------------------------------------------------------------------------------------------
--과정 평가 총점 출력
create or replace procedure procIncentiveView(
    pteacherseq number, -- 교사 선택
    presult out number,  -- sumAss + employee
    vsumAss out number, --설문지결과
    vemployee out number   --취업률
)
is
    vcore number;
    vemp number;
begin
    select 
        round(sum(assr.result)/300 ,2) into vsumAss
    from tblasssurvey ass -- 평가 설문지
        inner join tblasssurbeyresult assr  -- 평가 설문지 결과
            on ass.seq = assr.asssurveyseq
                right outer join tblopenclass oc    -- 개설 과정
                    on oc.seq = ass.openclassseq
                        where oc.teacherseq = pteacherseq;    -- 교사 선택
    select 
        round(sum(case
            when si.employee = 'O' then 1
        end) / count(*),2) into vemployee
    from tblstudentinfo  si -- 교육생 정보
        inner join tblclassreg cr   -- 수강신청
            on si.classregseq = cr.seq  
                inner join tblopenclass oc  --개설과정
                    on oc.seq = cr.openclassseq
                        where oc.teacherseq = pteacherseq;    -- 교사 선택
    
    select score into vcore from tblincentivepoint;
    select employeeratio into vemp from tblincentivepoint;
    
    presult := vsumAss * vcore + vemployee * vemp;     
end;

--------------------------------------------------------------------------------------------------------------------
-- T.011 교사 평가 조회 > 과정 평가 조회
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 교사 > 교사 평가 조회 > 과정 평가 조회
--------------------------------------------------------------------------------------------------------------------
--교사번호 입력 -> 개설 과정번호 가져오기
select seq from tblOpenClass where teacherSeq = 1; --1 입력받기

--관리자와 동일한 프로시저
/*
-- 개설 과벙 번호입력 -> 과정, 질문내용 출력
create or replace procedure procAssClassNQ(
    pnum number,
    presult out sys_refcursor 
)
is
begin
    open presult for
        select DISTINCT name, aseq ,question from vwAssurveyClass where ocseq = pnum order by aseq;
end;

--개설과정 번호, 질문내용 입력 -> 항목점수, 항목내용 출력
create or replace procedure procAssClassCon(
    pnum number,
    pname vwAssurveyClass.name%type,
    paseq number,
    presult out sys_refcursor --반환값으로 커서를 사용할 때 사용하는 자료형
)
is
begin
    open presult for
        select * from vwAssurveyClass where ocseq =pnum
            and name = pname and aseq = paseq ;
end;
*/

--개설과정번호, 해당과정 설문번호 입력 -> 항목당 선택한 교육생 인원수 출력
create or replace procedure procAssTView(
    pocseq number,
    poutnum number,
    presutlCount out sys_refcursor
)
is 
begin
    open presutlCount for
    select result ,count(*) as count from tblasssurbeyresult ar
    where asssurveyseq 
        = (select seq from tblasssurvey where openclassseq = pocseq and outnum = poutnum)--설문번호 
        group by result;
end;


--------------------------------------------------------------------------------------------------------------------
-- S.005 과정 평가
--------------------------------------------------------------------------------------------------------------------
-- ======= 메인 > 학생 > 과정 평가
--------------------------------------------------------------------------------------------------------------------
-- 학생 아이디, 비번 입력 -> 수강 과정 번호 불러오기
create or replace PROCEDURE proStOcseq (
    pid varchar2,
    ppw varchar2,
    pocseq out number
)
is
begin
    select ocseq into pocseq from vwStOcseq where id = pid and pwd = ppw;
end;

create or replace View vwStOcseq
as
select st.id, st.pwd, cr.openclassseq as ocseq from tblstudent st
    inner join tblclassreg cr
        on st.seq = cr.studentseq;

--개설과정 번호 입력 -> 과정이름, 질문 출력
--관리자와 동일한 프로시저
/*
create or replace procedure procAssClassNQ(
    pnum number,
    presult out sys_refcursor 
)
is
begin
    open presult for
        select DISTINCT name, aseq ,question from vwAssurveyClass where ocseq = pnum order by aseq;
end;

--개설과정 번호, 질문내용 입력 -> 항목점수, 항목내용 출력
create or replace procedure procAssClassCon(
    pnum number,
    pname vwAssurveyClass.name%type,
    paseq number,
    presult out sys_refcursor --반환값으로 커서를 사용할 때 사용하는 자료형
)
is
begin
    open presult for
        select * from vwAssurveyClass where ocseq =pnum
            and name = pname and aseq = paseq ;
end;
*/

--개설 과정 번호, 질문 번호 입력 -> 선택한 항목의 결과 입력
create or replace procedure procSurveyResultInsert(
    pocseq number,
    poutnum number,
    presut number
)
is 
begin
    insert into tblAssSurbeyResult (seq, result, assSurveySeq) 
        values (tblPriorSurveyResult_seq.nextVal, presut, 
            (select seq from tblasssurvey where openclassseq = pocseq and outnum = poutnum));
    
exception --예외처리
    when others then
        rollback;
        
end;
