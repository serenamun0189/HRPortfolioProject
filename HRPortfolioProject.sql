/*
Exploring HR data

Skills used:Joins, Temp Tables, Aggregate Functions, CASE Statements, Creating Views, Converting Data Types, Grouping and Ordering

*/
select * from dbo.HREmployeeAttrition

--Dropped extra duplicate column
alter table dbo.HREmployeeAttrition
drop column employeenumber2

--Finds attrition rates across departments
select 
department,cast(sum(case when Attrition = 'Yes' then 1 else 0 end)as float)*100/count(*) as attritionrate 
from dbo.HREmployeeAttrition
group by department

--Finds attrition rates across job roles
select 
jobrole, cast(sum(case when Attrition = 'Yes' then 1 else 0 end)as float)*100/count(*) as attritionrate 
from dbo.HREmployeeAttrition
group by JobRole
order by attritionrate desc

--Finds average job satisfaction across departments
select avg(cast(jobsatisfaction as float)) as avgjobsatisfaction, jobrole from dbo.HREmployeeAttrition
group by JobRole
order by avgjobsatisfaction desc

--Relating income range to job satisfaction
select avg(cast(jobsatisfaction as float)) as avgjobsatisfaction, 
case 
 when monthlyincome >= 18000 then '18000 to 20000'
 when monthlyincome >= 15000 then '15000 to 18000'
 when monthlyincome >= 10000 then '10000 to 15000'
 when monthlyincome >= 5000 then '5000 to 10000'
 else 'under 5000'
end as rangemonthlyincome
from dbo.HREmployeeAttrition
group by 
case 
  when monthlyincome >= 18000 then '18000 to 20000'
  when monthlyincome >= 15000 then '15000 to 18000'
  when monthlyincome >= 10000 then '10000 to 15000'
  when monthlyincome >= 5000 then '5000 to 10000'
 else 'under 5000'
end
order by avgjobsatisfaction desc


--Comparing distance from home to their job happiness
select avg(cast(jobsatisfaction as float)) as avgjobsatisfaction,
case 
when distancefromhome >=25 then '25 to 30'
when distancefromhome >=15 then '15 to 25'
when distancefromhome >=5 then '5 to 10'
else 'under 5'
end as rangedistancefromhome
from dbo.HREmployeeAttrition
group by 
case 
when distancefromhome >=25 then '25 to 30'
when distancefromhome >=15 then '15 to 25'
when distancefromhome >=5 then '5 to 10'
else 'under 5'
end
order by avgjobsatisfaction desc 


select * from dbo.Employeeinformation
select * from dbo.HREmployeeAttrition

select avg(YearsAtCompany) as avgyearsatcompany from dbo.Employeeinformation


--Combine 2 tables
select info.yearswithcurrmanager, info.relationshipsatisfaction, info.performancerating, attri.attrition
from dbo.employeeinformation info
join dbo.HREmployeeAttrition attri
on info.EmployeeNumber = attri.EmployeeNumber

--Find attrition rating with regard to average performance rating in each department
select attri.department, avg(cast(info.performancerating as float)) as avgperformancerating, cast(sum(case when attri.attrition='Yes' then 1 else 0 end) as float)*100/count(*) as attritionrating
from dbo.employeeinformation info
join dbo.HREmployeeAttrition attri
on info.EmployeeNumber = attri.EmployeeNumber
group by attri.department
order by attritionrating desc

--Create temp table to store department-level performance and attrition
drop table if exists #DepartmentPerformance
create table #DepartmentPerformance
(department nvarchar(50), 
performancerating tinyint,
attrition nvarchar(50)
)
Insert into #DepartmentPerformance
select attri.department, avg(cast(info.performancerating as float)) as avgperformancerating, cast(sum(case when attri.attrition='Yes' then 1 else 0 end) as float)*100/count(*) as attritionrating
from dbo.employeeinformation info
join dbo.HREmployeeAttrition attri
on info.EmployeeNumber = attri.EmployeeNumber
group by attri.department
select * from #DepartmentPerformance

--Create a reusable view for department-level performance and attrition
create view DepartmentAttrition as 
select 
attri.department, avg(cast(info.performancerating as float)) as avgperformancerating, cast(sum(case when attri.attrition='Yes' then 1 else 0 end) as float)*100/count(*) as attritionrating
from dbo.employeeinformation info
join dbo.HREmployeeAttrition attri
on info.EmployeeNumber = attri.EmployeeNumber
group by attri.department

select * from dbo.DepartmentAttrition






