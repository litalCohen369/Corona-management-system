
--לקחת את החודש והשנה מהתאריך הנוכחי
--מביא את כל החולים הפעילים בתאריך מסויים
select count(m.ID)
from members_tbl as m
where MONTH(m.DateReceivingAPositiveResult) = 06 and YEAR(m.DateReceivingAPositiveResult) = 2021 and
	MONTH(m.recoveryFromCorona) = 06 and YEAR(m.recoveryFromCorona) = 2021 and
	DAY(m.DateReceivingAPositiveResult) <= 17 and DAY(m.recoveryFromCorona) >= 17

--set @countDay = DATEDIFF(dd, GETDATE(), GETDATE())
--סופר לכל יום כמה חולים פעילים יש בכמה טבלאות
declare @countDay int
set @countDay = 1
while (@countDay < 31)
begin
select @countDay as numDay, count(m.ID) as users
from members_tbl as m
where MONTH(m.DateReceivingAPositiveResult) <= MONTH(GETDATE()) and YEAR(m.DateReceivingAPositiveResult) = YEAR(GETDATE())
	and m.DateReceivingAPositiveResult != '1000-01-01' and (MONTH(m.recoveryFromCorona) = MONTH(GETDATE()) and
	YEAR(m.recoveryFromCorona) = YEAR(GETDATE()) or (m.recoveryFromCorona) = '1000-01-01') and
	DAY(m.DateReceivingAPositiveResult) <= @countDay and DAY(m.recoveryFromCorona) >= @countDay
set @countDay= @countDay + 1
end

select dd
from tempDays_tbl
where dd between 1 and MONTH(GETDATE())


-- אמור לשלוף את כל הימים מהטבלת ימים מתחילת החודש ועד היום
-- ולכל יום לספור כמה חולים יש
select d.dd as numDay, count(m.ID) as users
from members_tbl as m right join (select dd
									from tempDays_tbl
									where dd between 1 and MONTH(GETDATE())) as d
on d.dd = DAY(m.DateReceivingAPositiveResult)
where MONTH(m.DateReceivingAPositiveResult) <= MONTH(GETDATE()) and YEAR(m.DateReceivingAPositiveResult) = YEAR(GETDATE())
	and m.DateReceivingAPositiveResult != '1000-01-01' and (MONTH(m.recoveryFromCorona) = MONTH(GETDATE()) and
	YEAR(m.recoveryFromCorona) = YEAR(GETDATE()) or (m.recoveryFromCorona) = '1000-01-01') and
	DAY(m.DateReceivingAPositiveResult) <= d.dd and DAY(m.recoveryFromCorona) >= d.dd
group by d.dd


-- שולף לכל יום בחודש הנוכחי כמה חולים פעילים היו
select d.dd as numDay, 
sum(case when (MONTH(m.DateReceivingAPositiveResult) <= MONTH(GETDATE()) and YEAR(m.DateReceivingAPositiveResult) = YEAR(GETDATE())
	and m.DateReceivingAPositiveResult != '1000-01-01' and (MONTH(m.recoveryFromCorona) = MONTH(GETDATE()) and
	YEAR(m.recoveryFromCorona) = YEAR(GETDATE()) or (m.recoveryFromCorona) = '1000-01-01') and
	DAY(m.DateReceivingAPositiveResult) <= d.dd and DAY(m.recoveryFromCorona) >= d.dd) then 1 else 0 end) as numUsers
from members_tbl as m right join (select dd
									from tempDays_tbl
									where dd between 1 and DAY(GETDATE())) as d
on d.dd = DAY(m.DateReceivingAPositiveResult)
group by d.dd