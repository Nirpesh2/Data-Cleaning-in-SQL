-- Exploratory Data Analysis

Select * from layoffs_staging2;

Select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select * from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;


Select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_staging2;

Select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

Select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

Select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;


select 
substring(`date`,1,7) as `MONTH`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `MONTH`
order by 1 asc
;


WITH Rolling_Total AS
(
	select 
	substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as total_off
	from layoffs_staging2
	where substring(`date`,1,7) is not null
	group by `MONTH`
	order by 1 asc
)
Select `MONTH`, total_off, SUM(total_off) OVER(order by `MONTH`) as rolling_total
from Rolling_Total;


Select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
order by 3 desc;




WITH Company_Year (Company, Years, Total_laid_Off) AS
(
	Select company, YEAR(`date`), sum(total_laid_off)
	from layoffs_staging2
	group by company, YEAR(`date`)
), Company_Year_Rank as
(
Select *, 
dense_rank() over(partition by years order by total_laid_off desc) as  Ranking
from Company_Year
where years is not null
-- order by ranking asc
)
select * 
from Company_Year_Rank
where Ranking <=5
;