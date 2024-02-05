-- This data is going to help to create a musical campaign on the most common names in song titles. 
--This second column was queried with Excel to remove number and symbols except ' and space

Select *
from NewSongTitle

-- I need to drop the invalid column track_name
Alter table NewSongTitle
drop column track_name

-- Rename the new column
EXEC sp_rename 'NewSongTitle.new_name', 'Track_Name', 'COLUMN'

-- Removing 17 empty single space 
With EmptyCTE as (
		select Track_Name
		from NewSongTitle
		where Track_Name like ''
		)
	delete
	from EmptyCTE

	-- Removing 10 more empty spaces 
With EmptyCTE as (
		select Track_Name
		from NewSongTitle
		where Track_Name like '     '
		)
	delete
	from EmptyCTE

---2972 rows left
--Let's check for duplicates
select Track_Name, COUNT(*) counts
from NewSongTitle
group by Track_Name
--where COUNT(*) > 1

with STCTE as (
				select Track_Name, COUNT(*) counts
				from NewSongTitle
				group by Track_Name
				)

select * from STCTE
where counts > 1

--- Deleting Duplicate rows
with TrackCTE as (
			Select Track_Name,
			ROW_NUMBER() over (partition by Track_Name order by (Track_Name)) RowNum
			from NewSongTitle
			)

delete from TrackCTE
where RowNum >1

Select *
from NewSongTitle
-- 2934 rows left

--Trim words
Select *, RTRIM(LTRIM(Track_Name))
from NewSongTitle
group by Track_Name


ALTER TABLE NewSongTitle
add Track_Nam nVARCHAR(255)

UPDATE NewSongTitle
SET Track_Nam = RTRIM(LTRIM(Track_Name))

ALTER TABLE NewSongTitle
DROP COLUMN Track_Name

EXEC sp_rename 'NewSongTitle.Track_Nam', 'Track_Name', 'COLUMN'

--Time to tokenize  each word
SELECT value Token
FROM NewSongTitle
CROSS APPLY STRING_SPLIT(Track_Name, ' '

--Still seeing irrelevant ASCII character. I need to remove that
--And then find words with highest count 

With TokenCTE as(
				SELECT value Token
				FROM NewSongTitle
				CROSS APPLY STRING_SPLIT(Track_Name, ' ')
)

select *, COUNT(*) TokenCount
from TokenCTE
where Token <> ''
group by Token
ORDER BY TokenCount DESC

--- I could also visualize the result without some common or unnecessry words

With TokenCTE as(
				SELECT value Token
				FROM NewSongTitle
				CROSS APPLY STRING_SPLIT(Track_Name, ' ')
)

select *, COUNT(*) TokenCount
from TokenCTE
where Token <> '' 
			AND Token NOT IN ('The', 'and', 'a', 'la', 'in', 'is', 'of', 'to', 'feat', 'On')
group by Token
ORDER BY TokenCount DESC