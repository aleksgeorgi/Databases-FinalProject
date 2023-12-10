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
-- Author:		Edwin Wray
-- Create date: 12/10/23
-- Proposition:	What courses are offered by a specific department? 
                Include the courses names and credit hours.
-- =============================================*/

DECLARE @DepartmentID INT;
-- Set the value of the specific department
SET @DepartmentID = 1;

SELECT @DepartmentID AS DepartmentID, D.DepartmentName
    , C.CourseId, C.CourseName, C.CreditHours
FROM Academic.Department AS D
    INNER JOIN Academic.Course AS C
        ON D.DepartmentID = C.DepartmentID
WHERE D.DepartmentID = @DepartmentID


/* =============================================
-- Author:		Edwin Wray
-- Create date: 12/10/23
-- Proposition:	Which instructors are teaching in classes in multiple departments?
-- =============================================*/

SELECT DI.InstructorID, I.FirstName, I.LastName
FROM Personnel.DepartmentInstructor AS DI
    INNER JOIN Personnel.Instructor AS I 
        ON DI.InstructorID = I.InstructorID
GROUP BY DI.InstructorID,  I.FirstName, I.LastName
HAVING COUNT(DISTINCT DI.DepartmentID) > 1
ORDER BY DI.InstructorID;


/* =============================================
-- Author:		Edwin Wray
-- Create date: 12/10/23
-- Proposition:	How many instructors are in each department?
-- =============================================*/

SELECT D.DepartmentID, D.DepartmentName, COUNT(DI.InstructorID) AS NumberOfInstructors
FROM Academic.Department AS D
    LEFT JOIN Personnel.DepartmentInstructor AS DI 
        ON D.DepartmentID = DI.DepartmentID
GROUP BY D.DepartmentID, D.DepartmentName
ORDER BY D.DepartmentID;


/* =============================================
-- Author:		Edwin Wray
-- Create date: 12/10/23
-- Proposition:	How many classes are being taught this semester?
                Group by course and aggregating total enrollment, 
                total class limit and the percentage of Enrollment.
-- =============================================*/

SELECT DISTINCT
    C.CourseID, C.CourseName
    , SUM(DISTINCT CS.ClassID) AS TotalClasses
    , E.CurrentEnrollment AS CurrentEnrollment
    , E.MaxEnrollmentLimit AS MaxEnrollmentLimit
FROM
    ClassManagement.Class AS CS
        JOIN Academic.Course AS C 
            ON CS.CourseID = C.CourseID
        LEFT JOIN Academic.Section AS S 
            ON C.CourseID = S.CourseId
        LEFT JOIN Enrollment.EnrollmentDetail AS E 
            ON S.SectionID = E.SectionID
GROUP BY
    C.CourseID, C.CourseName, E.CurrentEnrollment, E.MaxEnrollmentLimit
ORDER BY
    C.CourseID;

--- add more above here
