-- 10 queries 

/* =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 12/8/23
-- Proposition:	Which department offers the most number of courses 
-- =============================================*/

GO

WITH DepartmentCourseCount AS (
    SELECT 
        DepartmentID, 
        COUNT(CourseId) AS NumberOfCoursesOffered
    FROM [Academic].[Course]
    GROUP BY DepartmentID
)
SELECT TOP 1
    DepartmentID, 
    NumberOfCoursesOffered
FROM DepartmentCourseCount
ORDER BY NumberOfCoursesOffered DESC;


/* =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 12/8/23
-- Proposition:	what instructors teach the course with the most number of sections?
-- =============================================*/

GO
 
WITH CourseMostSections (CourseName, CourseSectionCounts, DepartmentID)
AS
(
    SELECT TOP 1
        C.CourseName
        , COUNT(S.Section) AS CourseSectionCounts
        , DepartmentID
    FROM [Academic].[Course] AS C
        INNER JOIN [Academic].[Section] AS S
        ON C.CourseId = S. CourseId
    GROUP BY CourseName, DepartmentID
    ORDER BY CourseSectionCounts DESC
)
SELECT   C.CourseName
        , C.CourseSectionCounts
        , C.DepartmentId
        , D.InstructorId
        , (I.FirstName + ' ' + I.LastName) AS InstructorFullName
FROM CourseMostSections AS C
INNER JOIN [Personnel].[DepartmentInstructor] AS D
ON C.DepartmentID = D.DepartmentId
INNER JOIN [Personnel].[Instructor] AS I
ON D.InstructorId = I.InstructorID




--- add more above here