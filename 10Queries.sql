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


/* =============================================
-- Author:		Sigalita Yakubova
-- Create date: 12/10/23
-- Proposition: Show all the courses being taught in a specific department
-- =============================================*/
DECLARE  @DeptID INT = 1;

SELECT D.DepartmentID, D.DepartmentName, C.CourseName, C.CourseAbbreviation, C.CourseNumber, C.CourseId
FROM [Academic].Department AS D 
INNER JOIN [Academic].Course AS C ON C.DepartmentID = D.DepartmentID
WHERE D.DepartmentID = @DeptID


/* =============================================
-- Author:		Sigalita Yakubova
-- Create date: 12/10/23
-- Proposition: Show all teachers in the Accounting Department whose first name starts with A
-- =============================================*/

SELECT D.DepartmentID, D.DepartmentName, I.FirstName, I.LastName
FROM [Personnel].DepartmentInstructor AS DI
INNER JOIN [Personnel].Instructor AS I ON I.InstructorID = DI.InstructorID 
INNER JOIN [Academic].Department AS D ON D.DepartmentID = DI.DepartmentID
WHERE D.DepartmentName = 'ACCT' AND I.FirstName LIKE 'A%'


/* =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 12/10/23
-- Proposition: Show all the sections that have exceeded the maximum limit of enrollment.
--              Display the course, course name, section code, no. of students currently enrolled,
--              maximum enrollment limit, and how many students are over the maximum limit.
-- =============================================*/

SELECT CONCAT(C.CourseAbbreviation, ' ', C.CourseNumber) AS [Course],
        C.CourseName,
        S.Code AS [SectionCode],
        E.CurrentEnrollment,
        E.MaxEnrollmentLimit,
        E.CurrentEnrollment - E.MaxEnrollmentLimit AS [StudentsOverLimit]
FROM Academic.Course AS C
    INNER JOIN Academic.Section AS S
        ON C.CourseId = S.CourseID
    INNER JOIN Enrollment.EnrollmentDetail AS E
        ON S.SectionID = E.SectionID
WHERE E.OverEnrolled = 'Yes'



/* =============================================
-- Author:		Aryeh Richman
-- Create date: 12/9/23
-- Proposition:	Which Instructors teach courses with over 150 students enrolled?
-- =============================================*/

SELECT DISTINCT CONCAT(I.FirstName, ' ', I.LastName) AS Professor
FROM Enrollment.EnrollmentDetail AS E
    INNER JOIN Academic.Section AS S
        ON S.SectionID = E.SectionID
        INNER JOIN Academic.Course AS C
            ON C.CourseId = S.CourseID
        INNER JOIN Personnel.DepartmentInstructor AS DI
            ON DI.DepartmentID = C.DepartmentID
        INNER JOIN Personnel.Instructor AS I
            ON DI.InstructorID = I.InstructorID
WHERE E.CurrentEnrollment > 150


/* =============================================
-- Author:		Aryeh Richman
-- Create date: 12/9/23
-- Proposition:	Which classes have over enrollment and by how many students?
-- =============================================*/

SELECT DISTINCT CONCAT(C.CourseAbbreviation, C.CourseNumber) AS Course, 
                C.CourseName, 
                S.SectionID, 
                E.CurrentEnrollment, 
                E.MaxEnrollmentLimit, 
                (E.CurrentEnrollment - E.MaxEnrollmentLimit) AS Overflow
FROM Academic.Course AS C
    INNER JOIN Academic.Section AS S
        ON C.CourseId = S.CourseID
    INNER JOIN Enrollment.EnrollmentDetail AS E
        ON S.SectionID = E.SectionID
WHERE E.CurrentEnrollment > E.MaxEnrollmentLimit



/* =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 12/10/23
-- Proposition: Show all the sections that have exceeded the maximum limit of enrollment.
--              Display the course, course name, section code, no. of students currently enrolled,
--              maximum enrollment limit, and how many students are over the maximum limit.
-- =============================================*/

SELECT CONCAT(C.CourseAbbreviation, ' ', C.CourseNumber) AS [Course],
        C.CourseName,
        S.Code AS [SectionCode],
        E.CurrentEnrollment,
        E.MaxEnrollmentLimit,
        E.CurrentEnrollment - E.MaxEnrollmentLimit AS [StudentsOverLimit]
FROM Academic.Course AS C
    INNER JOIN Academic.Section AS S
        ON C.CourseId = S.CourseID
    INNER JOIN Enrollment.EnrollmentDetail AS E
        ON S.SectionID = E.SectionID
WHERE E.OverEnrolled = 'Yes'

--- add more above here
