/*
문서명 : DML-STD-TextSQL.sql (수강생)
작성자 : 5조
작성일자 : 2020.06.17
프로젝트명 : 용용 ACADEMY
*/

/*
-- INDEX
01. 수강생 계정 -- line 16
02. 수강생 출결 조회 -- line 80
03. 수강생 성적 조회 -- line 177
04. 사전평가 설문지, 멘토/멘티 선정 -- line 247
*/

--------------------------------------------------------------------------------------------------------------------
-- S#01 수강생 계정
--------------------------------------------------------------------------------------------------------------------
-- 로그인 시 id와 비밀번호 확인
select id, pwd from tblStudent;

-- 수강생 개인정보를 select하기 위한 view
create or replace view vwInfo
as
select 
    std.id as id, std.name as 이름, std.tel as 핸드폰번호, std.regdate as 등록일,
    c.name as 과정명, oc.startDate || ' ' || '~' || ' ' || oc.endDate as 과정기간, r.name as 강의실명
from tblClass c
    inner join tblOpenClass oc
        on c.seq = oc.classseq
            inner join tblRoom r
                on r.seq = oc.roomseq
                    inner join tblClassReg reg
                        on oc.seq = reg.openClassSeq
                            inner join tblStudent std
                                on std.seq = reg.studentSeq
                                    order by 강의실명;

-- 로그인 기능을 수행하는 프로시저
create or replace procedure procStdLogin(
    pid varchar2,
    ppwd varchar2,
    presult out number,         -- 성공(1) or 실패(0)
    vname out varchar2,         -- 이름
    vphone out varchar2,        -- 핸드폰번호
    venroll out date,           -- 등록일
    vclassname out varchar2,    -- 과정명
    vdate out varchar2,         -- 과정기간
    vroom out varchar2          -- 강의실명
)
is
    vcnt number;
    vcnt2 number;
begin
    select count(*) into vcnt from tblstudent where id = pid;
    select count(*) into vcnt2 from tblstudent where pwd = ppwd;
    select 이름, 핸드폰번호, 등록일, 과정명, 과정기간, 강의실명 into vname, vphone, venroll, vclassname, 
            vdate, vroom from vwInfo where id = pid;
    
    if vcnt > 0 and vcnt2 > 0 then
        presult := 1;
        dbms_output.put_line('로그인 성공');
    else
        presult := 0;
        dbms_output.put_line('로그인 실패');
    end if;
end;

declare
    vresult number;
begin
    procstdlogin('hzuwo7132', '4239216', vresult);
    if vresult = 1 then
        dbms_output.put_line('');
    else
        dbms_output.put_line('로그인 실패');
    end if;
end;

--------------------------------------------------------------------------------------------------------------------
-- S#02 수강생 출결 조회
--------------------------------------------------------------------------------------------------------------------
-- 수강생(개인)의 전체 출결을 select 하기 위한 view
create or replace view vwStdAttend
as
select
    std.id as id, std.pwd as pwd, std.name as 이름, to_char(atd.indate, 'yy/mm/dd') || ' ' || '(' || to_char(atd.indate, 'hh24:mi') || ' '|| '~'
    || ' ' || to_char(atd.outdate, 'hh24:mi') || ')' as 일자, atd.state as 상태
        from tblStudent std -- 수강생
            inner join tblClassReg reg  -- 수강 신청
                on std.seq = reg.studentSeq
                    inner join tblAttend atd    -- 출결 관리
                        on atd.classRegSeq = reg.seq
                            order by 일자;
                            
-- 수강생(개인)의 전체 출결을 조회하는 프로시저
create or replace procedure procStdAttend (
    pid varchar2,
    ppwd varchar2,
    presult out sys_refcursor
)
is
begin
    open presult for 
        select * from vwStdAttend where id = pid and pwd = ppwd;
end;

declare
    vresult sys_refcursor;  -- 커서
    vrow vwStdAttend%rowtype;
begin
    procStdAttend('hzuwo7132', '4239216', vresult);
    
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        
        dbms_output.put_line(vrow.이름 || ', ' || vrow.일자 || ', '|| vrow.상태);
    end loop;
end;

-- 수강생(개인)의 월별 출결을 select하기 위한 view
create or replace view vwStdAttendMonth
as
select
    std.id as id, std.pwd as pwd, std.name as 이름,
    to_char(atd.indate, 'mm/dd') || ' ' || '(' || to_char(atd.indate, 'hh24:mi') || ' '|| '~'
    || ' ' || to_char(atd.outdate, 'hh24:mi') || ')' as 일자, atd.state as 상태
        from tblStudent std -- 수강생
            inner join tblClassReg reg  -- 수강 신청
                on std.seq = reg.studentSeq
                    inner join tblAttend atd    -- 출결 관리
                        on atd.classRegSeq = reg.seq
                            order by 일자;

-- 수강생(개인)의 월별 출결을 조회하는 프로시저
create or replace procedure procStdAttendMonth (
    pid varchar2,
    ppwd varchar2,
    pmonth varchar2,
    presult out sys_refcursor
)
is
begin
    open presult
        for select * from vwStdAttendMonth where id = pid and pwd = ppwd and substr(일자, 2, 1) = pmonth;
end;

-- 수강생(개인)의 일별 출결을 select하는 view
create or replace view vwStdAttendDay
as
select
    std.id as id, std.pwd as pwd, std.name as 이름,
    to_char(atd.indate, 'mm/dd') || ' ' || '(' || to_char(atd.indate, 'hh24:mi') || ' '|| '~'
    || ' ' || to_char(atd.outdate, 'hh24:mi') || ')' as 일자, atd.state as 상태
        from tblStudent std
            inner join tblClassReg reg  -- 수강 신청
                on std.seq = reg.studentSeq
                    inner join tblAttend atd    -- 출결 관리
                        on atd.classRegSeq = reg.seq
                            order by 일자;

-- 수강생(개인)의 일별 출결을 조회하는 프로시저                            
create or replace procedure procStdAttendDay (
    pid varchar2,
    ppwd varchar2,
    pmonth varchar,
    pday varchar2,
    presult out sys_refcursor
)
is
begin
    open presult
        for select * from vwStdAttendDay where id = pid and pwd = ppwd and substr(일자, 2, 1) = pmonth and substr(일자, 4, 2) = pday;
end;

--------------------------------------------------------------------------------------------------------------------
-- S#03 성적 조회
--------------------------------------------------------------------------------------------------------------------
-- 교육생(개인)의 성적을 select하기 위한 view
create or replace view vwStdInfoScore
as
select
    std.pwd as pwd, sub.seq as 과목번호, sub.name as 과목명, opsub.startDate || ' ' || '~' || ' ' || opsub.enddate as 과목기간,
    b.name as 교재명, t.name 교사명, po.attendpoint as 출석배점, po.writepoint as 필기배점, po.practicepoint as 실기배점,
    t.testDate as 시험날짜, 
        case
            when s.attendscore = s.attendscore then s.attendscore
            when s.attendscore = null then null
        end as 출석점수,
        case
            when s.writescore = s.writescore then s.writescore
            when s.writescore = null then null
        end as 필기점수,
        case
            when s.practicescore = s.practicescore then s.practicescore
            when s.practicescore = null then null
        end as 실기점수
        from tblBook b
            inner join tblSubject sub
                on b.seq = sub.bookseq
                    inner join tblPossible p
                        on sub.seq = p.subjectseq
                            inner join tblTeacher t
                                on t.seq = p.teacherseq
                                    inner join tblOpenSubject opsub
                                        on sub.seq = opsub.subjectseq
                                            inner join tblPoint po
                                                on opsub.seq = po.openSubjectSeq
                                                    inner join tblScore s
                                                        on po.seq = s.pointSeq
                                                            inner join tblClassReg reg
                                                                on reg.seq = s.classRegSeq
                                                                    inner join tblStudent std
                                                                        on std.seq = reg.studentSeq
                                                                            inner join tblTest t
                                                                                on opsub.seq = t.openSubjectSeq;

-- 수강생(개인)의 성적을 조회하는 프로시저                                                                                                                                                                                                         
create or replace procedure procStdInfoScore (
    ppwd varchar2,
    presult out sys_refcursor
)
is
begin
open presult
    for select * from vwStdInfoScore where pwd = ppwd;
end;

declare
    vresult sys_refcursor;
    vrow vwStdInfoScore%rowtype;
begin
    procStdInfoScore('4239216', vresult);
    
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        
        dbms_output.put_line('과목번호 : ' || vrow.과목번호 || ', ' || '과목명 : ' || vrow.과목명 || ', ' || '과목기간 : ' || vrow.과목기간 || ', '
                             || '교재명 : ' || vrow.교재명 || ', ' || '교사명 : ' || vrow.교사명 || ', ' || '출석배점 : ' || vrow.출석배점 || ', ' 
                             || '필기배점 : ' || vrow.필기배점 || ', ' || '실기배점 : ' || vrow.실기배점 || ', ' || '출석점수 : ' || vrow.출석점수 || ', ' 
                             || '필기점수 : ' || vrow.필기점수 || ', ' || '실기점수 : ' || vrow.실기점수 || ', ' || '시험날짜 : ' || vrow.시험날짜);
    end loop;
end;

--------------------------------------------------------------------------------------------------------------------
-- S#04 사전 평가 설문지
--------------------------------------------------------------------------------------------------------------------
-- 수강생(개인)의 사전평가 유무를 확인하기 위한 view
create or replace view vwStdAcademicInfo --뷰생성
as
select 
        s.id as id
        ,s.pwd as pwd
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

-- 수강생의 사전평가 유무를 확인하는 프로시저
create or replace procedure procStdSurveyChk(
    pid varchar2,
    ppwd varchar2,
    presult out number         -- 성공(1) or 실패(0)
)
is
    vresult date;
begin
    select startdate into vresult from vwstdacademicinfo where id = pid and pwd = ppwd;
    
    if sysdate - vresult < 4 then
        presult := 1;
        dbms_output.put_line('사전 평가를 하지 않았습니다.');
    elsif sysdate - vresult > 4 then
        presult := 0;
        dbms_output.put_line('사전 평가를 이미 시행했습니다.');
    end if;
end;

-- 사전평가 문제내용을 select하는 view
create or replace view vwQuestion
as
select
    seq, outnum as 번호, question 문제내용
from tblPriorSurvey
where seq between 1 and 10;

select * from vwQuestion;

-- 사전평가 항목들을 select하는 view
create or replace view vwItem
as
select 
    seq,
    case
        when outnum = 1 then 1
        when outnum = 2 then 2
        when outnum = 3 then 3
        when outnum = 4 then 4
    end as 항목,
    content as "항목(내용)",
    priorSurveySeq
from tblPriorSurveyItem
    where seq between 1 and 40
        order by seq, 항목;

select * from vwItem;

-- 교육생정보를 select하는 view(2)
create or replace view vwStudentInfo
as
select
    std.id, std.pwd, info.seq
        from tblStudent std
            inner join tblClassReg reg
                on std.seq = reg.studentseq
                    inner join tblStudentInfo info
                        on info.classRegSeq = reg.seq;
                        
select seq from vwStudentInfo where id = 'aeooz8337';

-- tblStudentInfo 테이블의 seq 뽑아내는 프로시저
create or replace procedure procstdinfo (
    pid varchar2,
    vseq out number
)
is
begin
    select seq into vseq from vwStudentinfo where id = pid;
end;

-- 결과지 테이블 단일뷰로 변환
create or replace view vwPriorSurveyResult
as
select
    seq, result, answer, priorSurveySeq
from tblPriorSurveyResult
where seq between 3 and 12;

select * from vwPriorSurveyResult;

-- 정답 넣는 프로시저
create or replace procedure procSurveyAnswer (
    presult number,
    psurveyseq number,
    pstdinfoseq number
)
is
    vanswer number;
begin
    select answer into vanswer from vwPriorSurveyResult where priorSurveySeq = psurveyseq;
    insert into tblPriorSurveyResult values (TBLPRIORSURVEYRESULT_SEQ.nextval, presult, vanswer, psurveyseq, pstdinfoseq);
end;

-- 사전평가 설문지 결과를 select하기 위한 view
create or replace view vwSurveyResult
as
select
    sur.seq as 번호, sur.question as 질문, item.outnum as 항목, item.content as "내용(항목)",
    res.answer as 정답, std.name as 학생이름, 
    case
        when item.outnum = res.answer and res.answer = res.result then res.result
        when item.outnum <> res.answer then null
    end as "학생이 고른 답", 10 as 배점
from tblPriorSurvey sur
    inner join tblPriorSurveyItem item
        on sur.seq = item.priorSurveySeq
            inner join tblPriorSurveyResult res
                on sur.seq = res.priorSurveySeq
                    inner join tblStudentInfo info
                        on info.seq = res.studentInfoSeq
                            inner join tblClassReg reg
                                on reg.seq = info.classRegSeq
                                    inner join tblStudent std
                                        on std.seq = reg.studentSeq
                                            where item.outnum = res.answer and res.answer = res.result
                                                order by 학생이름 asc, 번호,
                                                    case
                                                        when 항목 = 1 then 1
                                                        when 항목 = 2 then 2
                                                        when 항목 = 3 then 3
                                                        when 항목 = 4 then 4
                                                    end;

-- 수강생(개인)의 점수를 확인하는 프로시저
create or replace procedure procPriorScore (
    pstudentname varchar2,
    vname out varchar2,
    vscore out number
)
is
    
begin
select std.name as name, count(*) * 10 into vname, vscore
    from tblPriorSurveyResult res
        inner join tblStudentInfo info
            on info.seq = res.studentInfoSeq
                inner join tblClassReg reg
                    on reg.seq = info.classRegSeq
                        inner join tblStudent std
                           on std.seq = reg.studentSeq
                                where std.name = pstudentname and res.studentinfoseq = info.seq and res.result = res.answer
                                    group by std.name;
    dbms_output.put_line('점수 : ' || vscore);
end;

begin
    procPriorScore('tssec2724');
end;

-- 사전평가 설문지 결과를 토대로 각각의 교육생마다 멘토 or 멘티가 결정된다.
-- 평균보다 높은 수강생 조회 -> having절 조건만 바꾸면 낮은 수강생
select
    b.seq, (count(*) * 10)
from tblPriorSurveyResult a
    inner join tblStudentInfo b
        on a.studentInfoSeq = b.seq
             where a.result = a.answer
                group by b.seq
                    having (count(*) * 10) > (select (count(*) * 10)/100 as 평균 from tblPriorSurveyResult where result = answer);
                    
-- 멘토를 정하는 프로시저
create or replace procedure procMento
as
    vseq tblStudentInfo.seq%type;
    cursor vcursor is select seq from tblStudentInfo;
begin
    open vcursor;
        loop
            fetch vcursor into vseq;
            
            exit when vcursor%notfound;
            
            update tblStudentInfo set mento = '멘토' where seq = 
            (select b.seq
                from tblPriorSurveyResult a
                    inner join tblStudentInfo b
                        on a.studentInfoSeq = b.seq
                            where a.result = a.answer
                                group by b.seq
                                    having (count(*) * 10) > (select (count(*) * 10) from tblPriorSurveyResult where result = answer));
        end loop;
    close vcursor;
end;

-- 멘티를 정하는 프로시저
create or replace procedure procMentee
as
    vseq tblStudentInfo.seq%type;
    cursor vcursor is select seq from tblStudentInfo;
begin
    open vcursor;
        loop
            fetch vcursor into vseq;
            
            exit when vcursor%notfound;
            
            update tblStudentInfo set mento = '멘티' where seq = 
            (select b.seq
                from tblPriorSurveyResult a
                    inner join tblStudentInfo b
                        on a.studentInfoSeq = b.seq
                            where a.result = a.answer
                                group by b.seq
                                    having (count(*) * 10) > (select (count(*) * 10) from tblPriorSurveyResult where result = answer));
        end loop;
    close vcursor;
end;