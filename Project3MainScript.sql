--------------------------------------- CREATE THE DATABASE ------------------------------------------
-- Step 1 Instructions: run only lines 4 and 5 using the master databse 

--USE master
CREATE DATABASE [ClassSchedule_9:15_Group1];
GO

--USE master
--DROP DATABASE [ClassSchedule_9:15_Group1]
--GO

--------------------------------------- CREATE SCHEMAS ------------------------------------------
-- Step 2 Instructions: Run all remaining code under the [ClassSchedule_9:15_Group1] database

USE [ClassSchedule_9:15_Group1];
GO

DROP SCHEMA IF EXISTS [Academic]; 
GO
CREATE SCHEMA [Academic];
GO

DROP SCHEMA IF EXISTS [Personnel]; 
GO
CREATE SCHEMA [Personnel];
GO

DROP SCHEMA IF EXISTS [ClassManagement]; 
GO
CREATE SCHEMA [ClassManagement];
GO

DROP SCHEMA IF EXISTS [Facilities];
GO
CREATE SCHEMA [Facilities];
GO

DROP SCHEMA IF EXISTS [Enrollment]; 
GO
CREATE SCHEMA [Enrollment];
GO

DROP SCHEMA IF EXISTS [DbSecurity]; 
GO
CREATE SCHEMA [DbSecurity];
GO

DROP SCHEMA IF EXISTS [Process]; 
GO
CREATE SCHEMA [Process];
GO

DROP SCHEMA IF EXISTS [PkSequence]; 
GO
CREATE SCHEMA [PkSequence];
GO

DROP SCHEMA IF EXISTS [Project3];
GO
CREATE SCHEMA [Project3];
GO

DROP SCHEMA IF EXISTS [G9_1];
GO
CREATE SCHEMA [G9_1];
GO

DROP SCHEMA IF EXISTS [Uploadfile]
GO
CREATE SCHEMA [Uploadfile]
GO

DROP SCHEMA IF EXISTS [Udt]
GO
CREATE SCHEMA [Udt]
GO


------------------------------------- Create User Defined Datatypes ---------------------------------------

--Aleks
CREATE TYPE [Udt].[DateAdded] FROM [datetime2] NOT NULL
GO
CREATE TYPE [Udt].[DateOfLastUpdate] FROM [datetime2] NOT NULL
GO
CREATE TYPE [Udt].[SurrogateKeyInt] FROM [int] NOT NULL
GO
CREATE TYPE [Udt].[ClassTime] FROM nchar(19) NOT NULL
GO
CREATE TYPE [Udt].[IndividualProject] FROM nvarchar (60) NOT NULL
GO
CREATE TYPE [Udt].[LastName] FROM  nvarchar(35) NOT NULL
GO
CREATE TYPE [Udt].[FirstName] FROM nvarchar(20) NOT NULL
GO
CREATE TYPE [Udt].[GroupName] FROM nvarchar(20) NOT NULL
GO
CREATE TYPE [Udt].[CreditHours] FROM [FLOAT] NOT NULL
GO


-- Ahnaf
CREATE TYPE [Udt].[DayOfWeek] FROM CHAR(2) NULL
GO

-- Sigi
CREATE TYPE [Udt].SemesterName FROM NVARCHAR(20)
GO

-- Edwin
CREATE TYPE [Udt].[BuildingNameAbbrv] FROM NVARCHAR(3) NOT NULL;
GO
CREATE TYPE [Udt].[BuildingName] FROM NVARCHAR(50) NOT NULL;
GO





------------------------------------------ Import the UploadFile Data ---------------------------------------

-- Create the table 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Uploadfile].[CurrentSemesterCourseOfferings]
(
    [Semester] [varchar](50) NULL,
    [Sec] [varchar](50) NULL,
    [Code] [varchar](50) NULL,
    [Course (hr, crd)] [varchar](50) NULL,
    [Description] [varchar](50) NULL,
    [Day] [varchar](50) NULL,
    [Time] [varchar](50) NULL,
    [Instructor] [varchar](50) NULL,
    [Location] [varchar](50) NULL,
    [Enrolled] [varchar](50) NULL,
    [Limit] [varchar](50) NULL,
    [Mode of Instruction] [varchar](50) NULL
) ON [PRIMARY]
GO
ALTER TABLE [Uploadfile].[CurrentSemesterCourseOfferings] ADD  CONSTRAINT [DF_CurrentSemesterCourseOfferings_Semester]  DEFAULT ('Current Semester') FOR [Semester]
GO

INSERT INTO [ClassSchedule_9:15_Group1].[Uploadfile].[CurrentSemesterCourseOfferings]
    (
    [Semester],
    [Sec],
    [Code],
    [Course (hr, crd)],
    [Description],
    [Day],
    [Time],
    [Instructor],
    [Location],
    [Enrolled],
    [Limit],
    [Mode of Instruction]
    )
SELECT *
FROM [QueensClassSchedule].[UploadFile].[CurrentSemesterCourseOfferings]
GO




------------------------------------------- CREATE TABLES ----------------------------------------------


-- UserAuthorization Table -- 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP TABLE IF EXISTS [DbSecurity].[UserAuthorization]
GO
CREATE TABLE [DbSecurity].[UserAuthorization]
(
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL IDENTITY(1,1), -- primary key
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    --
    [ClassTime] [Udt].[ClassTime] NULL,
    [IndividualProject] [Udt].[IndividualProject] NULL,
    [GroupMemberLastName] [Udt].[LastName] NOT NULL,
    [GroupMemberFirstName] [Udt].[FirstName] NOT NULL,
    [GroupName] [nvarchar](20) NOT NULL
    PRIMARY KEY CLUSTERED 
(
	[UserAuthorizationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/*

Table: Process.[WorkflowSteps]

Description:
This table is used for auditing and tracking the execution of various workflow steps within the system. 
It records key information about each workflow step, including a description, the number of rows affected, 
the start and end times of the step, and the user who executed the step.

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP TABLE IF EXISTS [Process].[WorkflowSteps]
GO
CREATE TABLE [Process].[WorkflowSteps]
(
    [WorkFlowStepKey] [Udt].[SurrogateKeyInt] NOT NULL IDENTITY(1,1), -- primary key
    [WorkFlowStepDescription] [nvarchar](100) NOT NULL,
    [WorkFlowStepTableRowCount] [int] NULL,
    [StartingDateTime] [datetime2](7) NULL,
    [EndingDateTime] [datetime2](7) NULL,
    [QueryTime (ms)] [bigint] NULL,
    [Class Time] [char](5) NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[WorkFlowStepKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*

Table: [Personnel].[Instructor]

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 12/4/23
-- Description:	Load the names & IDs into the user Instructor table
-- =============================================

*/
DROP TABLE IF EXISTS [Personnel].[Instructor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personnel].[Instructor]
(
    InstructorID [int] NOT NULL IDENTITY(1, 1), -- primary key
    FirstName [char](25) NULL, 
    LastName [char](25) NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[InstructorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/*
Table: [Academic].[Course]

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 12/5/23
-- Description:	Load the Course Codes, Names, Credit/Course nums into the Course table
-- =============================================*/

DROP TABLE IF EXISTS [Academic].[Course]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Course] 
(
    CourseId INT NOT NULL IDENTITY(1, 1), -- primary key
    CourseAbbreviation CHAR(5) NOT NULL, -- needs check constraint 
    CourseNumber CHAR(5) NOT NULL, 
    CourseCredit FLOAT NOT NULL, -- (Needs Check Constraint to be positive)
    CreditHours [Udt].[CreditHours] NOT NULL, -- CreditHours (Needs Check Constraint) -> should be positive, possibly a UDT
    CourseName CHAR(35) NOT NULL, -- CourseDescription
    DepartmentID [int] NOT NULL, -- FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/*

Table: [Enrollment].[Semester]

-- =============================================
-- Author:		Sigalita Yakubova
-- Create date: 12/4/23
-- Description:	Showcase what semester belongs to each ID 
-- =============================================

*/
DROP TABLE IF EXISTS [Enrollment].[Semester]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrollment].[Semester]
(
    SemesterID [int] NOT NULL IDENTITY(1, 1), -- primary key
    SemesterName [Udt].SemesterName NULL, 
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[SemesterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/*
--Table: [ClassManagement].[ModeOfInstruction]


-- =============================================
-- Author:		Nicholas Kong
-- Create date: 12/4/23
-- Description:	Load the names & IDs into the user ModeOfInstruction table
-- =============================================
*/
DROP TABLE IF EXISTS [ClassManagement].[ModeOfInstruction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE  [ClassManagement].[ModeOfInstruction] (
    
    ModeID INT IDENTITY (1,1) NOT NULL,
	ModeName NVARCHAR(12) NOT NULL,
	 -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[ModeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


-- Nicholas
DROP TABLE IF EXISTS [Facilities].[RoomLocation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Facilities].[RoomLocation] (
    RoomID INT IDENTITY(1,1) NOT NULL,
	RoomNumber VARCHAR(12) NULL,
    BuildingCode INT,  -- Assuming BuildingCode is INT; adjust the data type as needed
    -- FOREIGN KEY (BuildingCode) REFERENCES BuildingLocation(BuildingCode),
	 -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[RoomID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Nicholas
DROP TABLE IF EXISTS  [ClassManagement].[Schedule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE  [ClassManagement].[Schedule] (
    ScheduleID INT IDENTITY(1,1) NOT NULL,
	RoomID INT NULL, 
	SectionID INT NULL,
	ClassID INT NULL,
	SemesterID INT NULL,
    StartTimeRange [Udt].[ClassTime] NOT NULL CHECK (StartTimeRange >= '00:00:00.0000000' AND StartTimeRange <= '24:00:00.0000000'),
	EndTimeRange [Udt].[ClassTime] NOT NULL CHECK (EndTimeRange >= '00:00:00.0000000' AND EndTimeRange <= '24:00:00.0000000'),
	 -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[ScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Ahnaf
/*

Table: [ClassManagement].[Days]

-- =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 12/4/23
-- Description:	Table to store all days of the week to be later used for classdays bridge table
-- =============================================

*/
DROP TABLE IF EXISTS [ClassManagement].[Days]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClassManagement].[Days]
(
    [DayID] [int] NOT NULL IDENTITY(1, 1), -- primary key
    [DayAbbreviation] [Udt].[DayOfWeek] NOT NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[DayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*

Table: [Academic].[Department]

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 12/5/23
-- Description:	Create a Department table with id and name
-- =============================================

*/
DROP TABLE IF EXISTS [Academic].[Department]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Department]
(
    DepartmentID [int] NOT NULL IDENTITY(1, 1), -- primary key
    DepartmentName [char](5) NOT NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*

Table: [Personnel].[DepartmentInstructor]

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 12/6/23
-- Description:	Create a bridge table between departments and instructors
-- =============================================

*/
DROP TABLE IF EXISTS [Personnel].[DepartmentInstructor]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personnel].[DepartmentInstructor]
(
    DepartmentInstructorID [int] NOT NULL IDENTITY(1, 1), -- primary key
    DepartmentID [int] NOT NULL,
    InstructorID [int] NOT NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[DepartmentInstructorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*

Table: [ClassManagement].[ClassDays]

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 12/6/23
-- Description:	Create a bridge table between class and days
-- =============================================

*/

DROP TABLE IF EXISTS [ClassManagement].[ClassDays]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClassManagement].[ClassDays]
(
    ClassDaysID [int] NOT NULL IDENTITY(1, 1), -- primary key
    ClassID [int] NOT NULL,
    DayID [int] NOT NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[ClassDaysID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*

Table: [Facilities].[BuildingLocations]

-- =============================================
-- Author:		Edwin Wray
-- Create date: 12/5/23
-- Description:	Create BuildingLocations table with building id and names
-- =============================================

*/
DROP TABLE IF EXISTS [Facilities].[BuildingLocations]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Facilities].[BuildingLocations]
(
    BuildingID [int] NOT NULL IDENTITY(1, 1), -- primary key
    BuildingNameAbbrv [Udt].[BuildingNameAbbrv] NOT NULL,
    BuildingName [Udt].[BuildingName] NOT NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[BuildingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/*

Table: [ClassManagement].[Class]

-- =============================================
-- Author:		Edwin Wray
-- Create date: 12/7/23
-- Description:	Create Class table
-- =============================================

*/
DROP TABLE IF EXISTS [ClassManagement].[Class]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClassManagement].[Class]
(
    ClassID [int] NOT NULL IDENTITY(1, 1), -- primary key
    CourseID [int] NOT NULL,
    SectionID [int] NOT NULL,
    InstructorID [int] NOT NULL,
    RoomID [int] NOT NULL,
    ModeID [int] NOT NULL,
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[ClassID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO



/*
Table: [Academic].[Section]

-- =============================================
-- Author:		Sigalita Yakubova
-- Create date: 12/7/2023
-- Description:	Load the Section Codes into the Section table
-- =============================================*/

DROP TABLE IF EXISTS [Academic].[Section]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Academic].[Section] 
(
    SectionID INT NOT NULL IDENTITY(1, 1), -- primary key
    Section varchar(20) NOT NULL, 
    Code varchar(20) NOT NULL,
    CourseID [int] NOT NULL, -- FOREIGN KEY (CourseID) 
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[SectionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/*

Table: [Enrollment].[EnrollmentDetail]

-- =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 12/8/23
-- Description:	Create table to store enrollment details for each section
-- =============================================

*/
DROP TABLE IF EXISTS [Enrollment].[EnrollmentDetail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrollment].[EnrollmentDetail]
(
    [EnrollmentID] INT NOT NULL IDENTITY(1, 1), -- primary key
	[SectionID] INT NOT NULL, -- Foreign Key (SectionID)
    [CurrentEnrollment] INT NOT NULL,
    [MaxEnrollmentLimit] INT NOT NULL,
	[OverEnrolled] NCHAR(3),
    -- all tables must have the following 3 columns:
    [UserAuthorizationKey] [Udt].[SurrogateKeyInt] NOT NULL, 
    [DateAdded] [Udt].[DateAdded] NOT NULL,
    [DateOfLastUpdate] [Udt].[DateOfLastUpdate] NOT NULL,
    PRIMARY KEY CLUSTERED(
	[EnrollmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO







--------------------- Alter Tables To Update Defaults/Constraints -------------------





-- Aleks

ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT ('9:15') FOR [ClassTime]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT ('PROJECT 3') FOR [IndividualProject]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT ('GROUP 1') FOR [GroupName]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [DbSecurity].[UserAuthorization] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Process].[WorkflowSteps] ADD  DEFAULT ((0)) FOR [WorkFlowStepTableRowCount]
GO
ALTER TABLE [Process].[WorkflowSteps] ADD  DEFAULT ('09:15') FOR [Class Time]
GO
ALTER TABLE [Process].[WorkflowSteps] ADD  DEFAULT (sysdatetime()) FOR [StartingDateTime]
GO
ALTER TABLE [Process].[WorkflowSteps] ADD  DEFAULT (sysdatetime()) FOR [EndingDateTime]
GO
ALTER TABLE [Process].[WorkflowSteps] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Process].[WorkflowSteps] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Personnel].[Instructor] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Personnel].[Instructor] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Personnel].[Instructor] ADD DEFAULT ('none') FOR [LastName]
GO
ALTER TABLE [Personnel].[Instructor] ADD DEFAULT ('none') FOR [FirstName]
GO
ALTER TABLE [Academic].[Course] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Academic].[Course] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Academic].[Course] ADD DEFAULT ('unknown') FOR [CourseName]
GO

-- Ahnaf
ALTER TABLE [ClassManagement].[Days] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [ClassManagement].[Days] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Enrollment].[EnrollmentDetail] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Enrollment].[EnrollmentDetail] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO

-- Nicholas
ALTER TABLE [ClassManagement].[ModeOfInstruction] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [ClassManagement].[ModeOfInstruction] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Facilities].[RoomLocation] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Facilities].[RoomLocation]  ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE  [ClassManagement].[Schedule] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE  [ClassManagement].[Schedule]  ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO



--Sigi
ALTER TABLE [Enrollment].[Semester] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Enrollment].[Semester] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Academic].[Section] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Academic].[Section] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO

-- Aryeh
ALTER TABLE [Academic].[Department] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Academic].[Department] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [Personnel].[DepartmentInstructor] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Personnel].[DepartmentInstructor] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [ClassManagement].[ClassDays] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [ClassManagement].[ClassDays] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO

-- Edwin
ALTER TABLE [Facilities].[BuildingLocations] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [Facilities].[BuildingLocations] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO
ALTER TABLE [ClassManagement].[Class] ADD  DEFAULT (sysdatetime()) FOR [DateAdded]
GO
ALTER TABLE [ClassManagement].[Class] ADD  DEFAULT (sysdatetime()) FOR [DateOfLastUpdate]
GO


-- add check constraints in the following format: 

-- Aleks
ALTER TABLE [Process].[WorkflowSteps]  WITH CHECK ADD  CONSTRAINT [FK_WorkFlowSteps_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Process].[WorkflowSteps] CHECK CONSTRAINT [FK_WorkFlowSteps_UserAuthorization]
GO
ALTER TABLE [Personnel].[Instructor] WITH CHECK ADD  CONSTRAINT [FK_Instructor_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Personnel].[Instructor] CHECK CONSTRAINT [FK_Instructor_UserAuthorization]
GO
ALTER TABLE [Academic].[Course] WITH CHECK ADD CONSTRAINT [FK_Course_DepartmentID] FOREIGN KEY([DepartmentID])
REFERENCES [Academic].[Department] ([DepartmentID])
GO
ALTER TABLE [Academic].[Course] WITH CHECK ADD  CONSTRAINT [FK_Course_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Academic].[Course] CHECK CONSTRAINT [FK_Course_UserAuthorization]
GO
ALTER TABLE [Academic].[Course] ADD CONSTRAINT [CHK_CreditHours_Positive] CHECK (CreditHours >= 0)
GO
ALTER TABLE [Academic].[Course] ADD CONSTRAINT [CHK_CourseCredit_Positive] CHECK (CourseCredit >= 0)
GO


--Sigi
ALTER TABLE [Enrollment].[Semester]  WITH CHECK ADD  CONSTRAINT [FK_Semester_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Enrollment].[Semester] CHECK CONSTRAINT [FK_Semester_UserAuthorization]
GO
ALTER TABLE [Academic].[Section] WITH CHECK ADD CONSTRAINT [FK_Section_Course] FOREIGN KEY([CourseId])
REFERENCES [Academic].[Course] ([CourseId])
GO
ALTER TABLE [Academic].[Section]  WITH CHECK ADD  CONSTRAINT [FK_Section_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Academic].[Section] CHECK CONSTRAINT [FK_Section_UserAuthorization]
GO

-- Ahnaf
ALTER TABLE [ClassManagement].[Days]  WITH CHECK ADD  CONSTRAINT [FK_Days_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [ClassManagement].[Days] CHECK CONSTRAINT [FK_Days_UserAuthorization]
GO
ALTER TABLE [ClassManagement].[Days] ADD CONSTRAINT CHK_DayOfWeek
CHECK (DayAbbreviation IN ('M', 'T', 'W', 'TH', 'F', 'S', 'SU'))
GO
ALTER TABLE [Enrollment].[EnrollmentDetail]  WITH CHECK ADD  CONSTRAINT [FK_EnrollmentDetail_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Enrollment].[EnrollmentDetail] CHECK CONSTRAINT [FK_EnrollmentDetail_UserAuthorization]
GO
ALTER TABLE [Enrollment].[EnrollmentDetail] WITH CHECK ADD CONSTRAINT [FK_EnrollmentDetail_Section] FOREIGN KEY([SectionID])
REFERENCES [Academic].[Section] ([SectionID])
GO
ALTER TABLE [Enrollment].[EnrollmentDetail] CHECK CONSTRAINT [FK_EnrollmentDetail_Section]
GO



-- Nicholas
ALTER TABLE [ClassManagement].[ModeOfInstruction]  WITH CHECK ADD  CONSTRAINT [FK_ModeOfInst_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [ClassManagement].[ModeOfInstruction] CHECK CONSTRAINT [FK_ModeOfInst_UserAuthorization]
GO
ALTER TABLE [Facilities].[RoomLocation]  WITH CHECK ADD  CONSTRAINT [FK_RoomLocation_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Facilities].[RoomLocation]  CHECK CONSTRAINT [FK_RoomLocation_UserAuthorization]
GO
ALTER TABLE  [ClassManagement].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE  [ClassManagement].[Schedule]  CHECK CONSTRAINT [FK_Schedule_UserAuthorization]
GO
ALTER TABLE [ClassManagement].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_RoomLocation] FOREIGN KEY([RoomID])
REFERENCES [Facilities].[RoomLocation] ([RoomID])
GO
ALTER TABLE [ClassManagement].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_Section] FOREIGN KEY([SectionID])
REFERENCES [Academic].[Section] ([SectionID])
GO
ALTER TABLE [ClassManagement].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_Class] FOREIGN KEY([ClassID])
REFERENCES [ClassManagement].[Class] ([ClassID])
GO
ALTER TABLE [ClassManagement].[Schedule]  WITH CHECK ADD  CONSTRAINT [FK_Schedule_Semester] FOREIGN KEY([SemesterID])
REFERENCES [Enrollment].[Semester] ([SemesterID])
GO


-- Aryeh
ALTER TABLE [Academic].[Department]  WITH CHECK ADD  CONSTRAINT [FK_Department_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Academic].[Department] CHECK CONSTRAINT [FK_Department_UserAuthorization]
GO
ALTER TABLE [Personnel].[DepartmentInstructor]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentInstructor_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Personnel].[DepartmentInstructor] CHECK CONSTRAINT [FK_DepartmentInstructor_UserAuthorization]
GO
ALTER TABLE [Personnel].[DepartmentInstructor]  WITH CHECK ADD  CONSTRAINT [FK_DepartmentInstructor_Department] FOREIGN KEY([DepartmentID])
REFERENCES [Academic].[Department] ([DepartmentID])
GO
ALTER TABLE [Personnel].[DepartmentInstructor] CHECK CONSTRAINT [FK_DepartmentInstructor_Department]
GO
ALTER TABLE [ClassManagement].[ClassDays]  WITH CHECK ADD  CONSTRAINT [FK_ClassDays_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [ClassManagement].[ClassDays] CHECK CONSTRAINT [FK_ClassDays_UserAuthorization]
GO
ALTER TABLE [ClassManagement].[ClassDays]  WITH CHECK ADD  CONSTRAINT [FK_ClassDays_Class] FOREIGN KEY([ClassID])
REFERENCES [ClassManagement].[Class] ([ClassID])
GO
ALTER TABLE [ClassManagement].[ClassDays] CHECK CONSTRAINT [FK_ClassDays_Class]
GO
ALTER TABLE [ClassManagement].[ClassDays]  WITH CHECK ADD  CONSTRAINT [FK_ClassDays_Days] FOREIGN KEY([DayID])
REFERENCES [ClassManagement].[Days] ([DayID])
GO
ALTER TABLE [ClassManagement].[ClassDays] CHECK CONSTRAINT [FK_ClassDays_Days]
GO

-- Edwin
ALTER TABLE [Facilities].[BuildingLocations]  WITH CHECK ADD  CONSTRAINT [FK_BuildingLocations_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [Facilities].[BuildingLocations] CHECK CONSTRAINT [FK_BuildingLocations_UserAuthorization]
GO
ALTER TABLE [ClassManagement].[Class]  WITH CHECK ADD  CONSTRAINT [FK_Class_UserAuthorization] FOREIGN KEY([UserAuthorizationKey])
REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey])
GO
ALTER TABLE [ClassManagement].[Class] CHECK CONSTRAINT [FK_Class_UserAuthorization]
GO
ALTER TABLE [ClassManagement].[Class]  WITH CHECK ADD  CONSTRAINT [FK_Class_Course] FOREIGN KEY([CourseID])
REFERENCES [Academic].[Course] ([CourseID])
GO
ALTER TABLE [ClassManagement].[Class] CHECK CONSTRAINT [FK_Class_Course]
GO
ALTER TABLE [ClassManagement].[Class]  WITH CHECK ADD  CONSTRAINT [FK_Class_Section] FOREIGN KEY([SectionID])
REFERENCES [Academic].[Section] ([SectionID])
GO
ALTER TABLE [ClassManagement].[Class] CHECK CONSTRAINT [FK_Class_Section]
GO
ALTER TABLE [ClassManagement].[Class]  WITH CHECK ADD  CONSTRAINT [FK_Class_Instructor] FOREIGN KEY([InstructorID])
REFERENCES [Personnel].[Instructor] ([InstructorID])
GO
ALTER TABLE [ClassManagement].[Class] CHECK CONSTRAINT [FK_Class_Instructor]
GO
ALTER TABLE [ClassManagement].[Class]  WITH CHECK ADD  CONSTRAINT [FK_Class_RoomLocation] FOREIGN KEY([RoomID])
REFERENCES [Facilities].[RoomLocation] ([RoomID])
GO
ALTER TABLE [ClassManagement].[Class] CHECK CONSTRAINT [FK_Class_RoomLocation]
GO
ALTER TABLE [ClassManagement].[Class]  WITH CHECK ADD  CONSTRAINT [FK_Class_ModeOfInstruction] FOREIGN KEY([ModeID])
REFERENCES [ClassManagement].[ModeOfInstruction] ([ModeID])
GO
ALTER TABLE [ClassManagement].[Class] CHECK CONSTRAINT [FK_Class_ModeOfInstruction]
GO

--------------------------------- CREATE FUNCTIONS --------------------------------


-- Sigi 
-- Create a function to determine the season
CREATE FUNCTION [Udt].GetSeason(@DateAdded DATETIME2)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @Season NVARCHAR(10);

    SET @Season = 
        CASE
            WHEN MONTH(@DateAdded) BETWEEN 1 AND 3 THEN 'Winter'
            WHEN MONTH(@DateAdded) BETWEEN 4 AND 6 THEN 'Spring'
            WHEN MONTH(@DateAdded) BETWEEN 7 AND 9 THEN 'Summer'
            WHEN MONTH(@DateAdded) BETWEEN 10 AND 12 THEN 'Fall'
        END;

    RETURN @Season;
END;
GO

-- Create a function to get the formatted SemesterName
CREATE FUNCTION [Udt].GetSemesterName(@DateAdded DATETIME2)
RETURNS [Udt].SemesterName
AS
BEGIN
    DECLARE @Season NVARCHAR(10);
    DECLARE @Year NVARCHAR(4);
    DECLARE @SemesterName [Udt].SemesterName;

    SET @Season = [Udt].GetSeason(@DateAdded);
    SET @Year = FORMAT(@DateAdded, 'yyyy');
    SET @SemesterName = @Season + ' ' + @Year;

    RETURN @SemesterName;
END;

GO


--Edwin
-- Create a function to determine the BuildingName
CREATE FUNCTION [Udt].[GetBuildingNameAbbrv](@Location VARCHAR(50))
RETURNS [Udt].[BuildingNameAbbrv]
AS
BEGIN
    IF @Location IS NULL OR LTRIM(RTRIM(@Location)) = ''
        RETURN 'TBD';

    DECLARE @BuildingNameAbbrv [Udt].[BuildingNameAbbrv];
    SET @BuildingNameAbbrv = 
        CASE 
            WHEN CHARINDEX(' ', @Location) > 0 
            THEN LEFT(@Location, CHARINDEX(' ', @Location) - 1)
            ELSE 'TBD'
        END;
        
    RETURN @BuildingNameAbbrv;
END;
GO


-- Create a function to determine the BuildingName
CREATE FUNCTION [Udt].[GetBuildingName](@Location VARCHAR(50))
RETURNS [Udt].[BuildingName]
AS
BEGIN
    -- Return 'TBD' if the input is NULL or an empty string
    IF @Location IS NULL OR LTRIM(RTRIM(@Location)) = ''
        RETURN 'TBD';

    DECLARE @BuildingNameAbbrv NVARCHAR(2);
    SET @BuildingNameAbbrv = [Udt].[GetBuildingNameAbbrv](@Location);

    DECLARE @BuildingName [Udt].[BuildingName];
    SET @BuildingName = 
        CASE
            WHEN @BuildingNameAbbrv = 'AE' THEN 'Alumni Hall'
            WHEN @BuildingNameAbbrv = 'CD' THEN 'Campbell Dome'
            WHEN @BuildingNameAbbrv = 'CA' THEN 'Colden Auditorium'
            WHEN @BuildingNameAbbrv = 'CH' THEN 'Colwin Hall'
            WHEN @BuildingNameAbbrv = 'CI' THEN 'Continuing Ed 1'
            WHEN @BuildingNameAbbrv = 'DY' THEN 'Delany Hall'
            WHEN @BuildingNameAbbrv = 'DH' THEN 'Dining Hall'
            WHEN @BuildingNameAbbrv = 'FG' THEN 'FitzGerald Gym'
            WHEN @BuildingNameAbbrv = 'FH' THEN 'Frese Hall'
            WHEN @BuildingNameAbbrv = 'GB' THEN 'G Building'
            WHEN @BuildingNameAbbrv = 'GC' THEN 'Gertz Center'
            WHEN @BuildingNameAbbrv = 'GT' THEN 'Goldstein Theatre'
            WHEN @BuildingNameAbbrv = 'HH' THEN 'Honors Hall'
            WHEN @BuildingNameAbbrv = 'IB' THEN 'I Building'
            WHEN @BuildingNameAbbrv = 'JH' THEN 'Jefferson Hall'
            WHEN @BuildingNameAbbrv = 'KY' THEN 'Kiely Hall'
            WHEN @BuildingNameAbbrv = 'KG' THEN 'King Hall'
            WHEN @BuildingNameAbbrv = 'KS' THEN 'Kissena Hall'
            WHEN @BuildingNameAbbrv = 'KP' THEN 'Klapper Hall'
            WHEN @BuildingNameAbbrv = 'MU' THEN 'Music Building'
            WHEN @BuildingNameAbbrv = 'PH' THEN 'Powdermaker Hall'
            WHEN @BuildingNameAbbrv = 'QH' THEN 'Queens Hall'
            WHEN @BuildingNameAbbrv = 'RA' THEN 'Rathaus Hall'
            WHEN @BuildingNameAbbrv = 'RZ' THEN 'Razran Hall'
            WHEN @BuildingNameAbbrv = 'RE' THEN 'Remsen Hall'
            WHEN @BuildingNameAbbrv = 'RO' THEN 'Rosenthal Library'
            WHEN @BuildingNameAbbrv = 'SB' THEN 'Science Building'
            WHEN @BuildingNameAbbrv = 'SU' THEN 'Student Union'
            WHEN @BuildingNameAbbrv = 'C2' THEN 'Tech Incubator'
            ELSE 'TBD' -- Default case for any other or unexpected abbreviation
        END;

    RETURN @BuildingName;
END;
GO

-- string splitter function for classdays

CREATE FUNCTION dbo.SplitString (@List NVARCHAR(MAX), @Delimiter NVARCHAR(255))
RETURNS TABLE
AS
RETURN ( 
    SELECT [Value] = y.i.value('(./text())[1]', 'nvarchar(4000)')
    FROM ( 
        SELECT x = CONVERT(XML, '<i>' 
        + REPLACE(@List, @Delimiter, '</i><i>') 
        + '</i>').query('.')
    ) AS a CROSS APPLY x.nodes('i') AS y(i)
);
GO


--------------------------------- Create Stored Procedures -------------------------------

/*
Stored Procedure: [Process].[usp_ShowWorkflowSteps]

Description:
This stored procedure is designed to retrieve and display all records from the Process.[WorkFlowSteps] table. 
It is intended to provide a comprehensive view of all workflow steps that have been logged in the system, 
offering insights into the various processes and their execution details.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Show table of all workflow steps
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Process].[usp_ShowWorkflowSteps]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SELECT *
    FROM [Process].[WorkFlowSteps];
END
GO

/*
Stored Procedure: Process.[usp_TrackWorkFlow]

Description:
This stored procedure is designed to track and log each step of various workflows within the system. 
It inserts records into the [WorkflowSteps] table, capturing key details about each workflow step, 
such as its description, the number of table rows affected, and the start and end times. 
This procedure is instrumental in maintaining an audit trail and enhancing transparency in automated processes.


-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Keep track of all workflow steps
-- =============================================
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Process].[usp_TrackWorkFlow]
    -- Add the parameters for the stored procedure here
    @WorkflowDescription NVARCHAR(100),
    @WorkFlowStepTableRowCount INT,
    @StartingDateTime DATETIME2,
    @EndingDateTime DATETIME2,
    @QueryTime BIGINT,
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    INSERT INTO [Process].[WorkflowSteps]
        (
        WorkFlowStepDescription,
        WorkFlowStepTableRowCount,
        StartingDateTime,
        EndingDateTime,
        [QueryTime (ms)],
        UserAuthorizationKey
        )
    VALUES
        (@WorkflowDescription,
        @WorkFlowStepTableRowCount,
        @StartingDateTime,
        @EndingDateTime,
        @QueryTime,
        @UserAuthorizationKey);

END;
GO

/*

Stored Procedure: Process.[Load_UserAuthorization]

Description: Prepopulating the UserAuthorization Table with the Group Names 

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/126/23
-- Description:	Load the names & default values into the user authorization table
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[Load_UserAuthorization]
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [DbSecurity].[UserAuthorization]
        ([GroupMemberLastName],[GroupMemberFirstName])
    VALUES

        ('Georgievska', 'Aleksandra'),
        ('Yakubova', 'Sigalita'),
        ('Kong', 'Nicholas'),
        ('Wray', 'Edwin'),
        ('Ahmed', 'Ahnaf'),
        ('Richman', 'Aryeh');

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 6;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Users',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


/*
Stored Procedure: [Project3].[AddForeignKeysToClassSchedule]

Description:
This procedure is responsible for establishing foreign key relationships across various tables in 
the database. It adds constraints to link fact and dimension tables to ensure referential integrity. 
The procedure also associates dimension tables with the UserAuthorization table, thereby establishing 
a traceable link between data records and the users responsible for their creation or updates.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Add the foreign keys to the start Schema database
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[AddForeignKeysToClassSchedule]
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    -- Aleks
    ALTER TABLE [Process].[WorkflowSteps]
    ADD CONSTRAINT FK_WorkFlowSteps_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [Academic].[Course]
    ADD CONSTRAINT FK_Course_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [Academic].[Course]
    ADD CONSTRAINT FK_Course_DepartmentID
        FOREIGN KEY (DepartmentID)
        REFERENCES [Academic].[Department] (DepartmentID)

    -- Aryeh
    ALTER TABLE [Academic].[Department]
    ADD CONSTRAINT FK_Department_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [Personnel].[DepartmentInstructor]
    ADD CONSTRAINT FK_DepartmentInstructor_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [Personnel].[DepartmentInstructor]
    ADD CONSTRAINT FK_DepartmentInstructor_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES [Academic].[Department] (DepartmentID);
    ALTER TABLE [Personnel].[DepartmentInstructor]
    ADD CONSTRAINT FK_Department_Instructor
        FOREIGN KEY (InstructorID)
        REFERENCES [Personnel].[Instructor] (InstructorID);
    ALTER TABLE [ClassManagement].[ClassDays]
    ADD CONSTRAINT FK_ClassDays_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [ClassManagement].[ClassDays]
    ADD CONSTRAINT FK_ClassDays_Class
        FOREIGN KEY (ClassID)
        REFERENCES [ClassManagement].[Class] (ClassID);
    ALTER TABLE [ClassManagement].[ClassDays]
    ADD CONSTRAINT FK_ClassDays_Days
        FOREIGN KEY (DayID)
        REFERENCES [ClassManagement].[Days] (DayID);


    -- Sigi
    ALTER TABLE [Enrollment].[Semester]
    ADD CONSTRAINT FK_WorkFlowSteps_UserAuthorization
        FOREIGN KEY([UserAuthorizationKey])
        REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey]);

    ALTER TABLE [Academic].[Section]
        ADD CONSTRAINT FK_Section_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [Academic].[Section]
    ADD CONSTRAINT FK_Section_Course
        FOREIGN KEY (CourseID)
        REFERENCES [Academic].[Course] (CourseID)

    -- Ahnaf 
    ALTER TABLE [ClassManagement].[Days]
    ADD CONSTRAINT FK_Days_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
		
    ALTER TABLE [Enrollment].[EnrollmentDetail]
    ADD CONSTRAINT FK_EnrollmentDetail_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
		
    ALTER TABLE [Enrollment].[EnrollmentDetail]
    ADD CONSTRAINT FK_EnrollmentDetail_Section
        FOREIGN KEY (SectionID)
        REFERENCES [Academic].[Section] ([SectionID]);

    -- Nicholas
    ALTER TABLE [ClassManagement].[ModeOfInstruction]  
    ADD CONSTRAINT FK_ModeOfInst_UserAuthorization
        FOREIGN KEY([UserAuthorizationKey])
        REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey]);

	ALTER TABLE [Facilites].[RoomLocation]  
    ADD CONSTRAINT FK_RoomLocation_UserAuthorization 
        FOREIGN KEY([UserAuthorizationKey])
        REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey]);

	ALTER TABLE  [ClassManagement].[Schedule]
    ADD CONSTRAINT FK_Schedule_UserAuthorization 
        FOREIGN KEY([UserAuthorizationKey])
        REFERENCES [DbSecurity].[UserAuthorization] ([UserAuthorizationKey]);

	ALTER TABLE [ClassManagement].[Schedule]
    ADD CONSTRAINT FK_Schedule_RoomID
		FOREIGN KEY (RoomID)
		REFERENCES [Facilities].[RoomLocation] (RoomID);

	ALTER TABLE [ClassManagement].[Schedule]
    ADD CONSTRAINT FK_Schedule_Section
		FOREIGN KEY (SectionID)
		REFERENCES [Academic].[Section] (SectionID);
	
	ALTER TABLE [ClassManagement].[Schedule]
    ADD CONSTRAINT FK_Schedule_Class
		FOREIGN KEY (ClassID)
		REFERENCES [ClassManagement].[Class] (ClassID);

	ALTER TABLE [ClassManagement].[Schedule]
    ADD CONSTRAINT FK_Schedule_Semester
		FOREIGN KEY (SemesterID)
		REFERENCES [Enrollment].[Semester] (SemesterID);


    -- Edwin
    ALTER TABLE [Facilities].[BuildingLocations]
    ADD CONSTRAINT FK_BuildingLocations_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [ClassManagement].[Class]
    ADD CONSTRAINT FK_Class_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES [DbSecurity].[UserAuthorization] (UserAuthorizationKey);
    ALTER TABLE [ClassManagement].[Class]
    ADD CONSTRAINT FK_Class_Course
        FOREIGN KEY (CourseID)
        REFERENCES [Academic].[Course] (CourseID);
    ALTER TABLE [ClassManagement].[Class]
    ADD CONSTRAINT FK_Class_Section
        FOREIGN KEY (SectionID)
        REFERENCES [Academic].[Section] (SectionID);
    ALTER TABLE [ClassManagement].[Class]
    ADD CONSTRAINT FK_Class_Instructor
        FOREIGN KEY (InstructorID)
        REFERENCES [Personnel].[Instructor] (InstructorID);
    ALTER TABLE [ClassManagement].[Class]
    ADD CONSTRAINT FK_Class_RoomLocation
        FOREIGN KEY (RoomID)
        REFERENCES [Facilities].[RoomLocation] (RoomID);
    ALTER TABLE [ClassManagement].[Class]
    ADD CONSTRAINT FK_Class_ModeOfInstruction
        FOREIGN KEY (ModeID)
        REFERENCES [ClassManagement].[ModeOfInstruction] (ModeID);

    -- add more here...


    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Foreign Keys',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO



/*
Stored Procedure: [Project3].[DropForeignKeysFromClassSchedule]

Description:
This procedure is designed to remove foreign key constraints from various tables in the database. 
It primarily focuses on dropping constraints that link fact and dimension tables as well as the 
constraints linking dimension tables to the UserAuthorization table. This is typically performed 
in preparation for data loading operations that require constraint-free bulk data manipulations.

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/13/23
-- Description:	Drop the foreign keys from the start Schema database
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[DropForeignKeysFromClassSchedule]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    -- Aleks
    ALTER TABLE [Process].[WorkflowSteps] DROP CONSTRAINT [FK_WorkFlowSteps_UserAuthorization];
    ALTER TABLE [Academic].[Course] DROP CONSTRAINT [FK_Course_UserAuthorization];
    ALTER TABLE [Academic].[Course] DROP CONSTRAINT [FK_Course_DepartmentID];

    -- Ahnaf
    ALTER TABLE [ClassManagement].[Days] DROP CONSTRAINT [FK_Days_UserAuthorization];

    ALTER TABLE [Enrollment].[EnrollmentDetail] DROP CONSTRAINT [FK_EnrollmentDetail_UserAuthorization];
    ALTER TABLE [Enrollment].[EnrollmentDetail] DROP CONSTRAINT [FK_EnrollmentDetail_Section];

    -- Nicholas
    ALTER TABLE [ClassManagement].[ModeOfInstruction] DROP CONSTRAINT [FK_ModeOfInst_UserAuthorization];
    ALTER TABLE [Facilities].[RoomLocation] DROP CONSTRAINT [FK_RoomLocation_UserAuthorization];
    ALTER TABLE [ClassManagement].[Schedule] DROP CONSTRAINT [FK_Schedule_UserAuthorization];
    ALTER TABLE [ClassManagement].[Schedule]  DROP CONSTRAINT [FK_Schedule_RoomLocation];
    ALTER TABLE [ClassManagement].[Schedule]  DROP CONSTRAINT [FK_Schedule_Section];
    ALTER TABLE [ClassManagement].[Schedule]  DROP CONSTRAINT [FK_Schedule_Class];
    ALTER TABLE [ClassManagement].[Schedule]  DROP CONSTRAINT [FK_Schedule_Semester];

    -- Sigi
    ALTER TABLE [Enrollment].[Semester] DROP CONSTRAINT FK_Semester_UserAuthorization;
    ALTER TABLE [Academic].[Section] DROP CONSTRAINT [FK_Section_UserAuthorization];
    ALTER TABLE [Academic].[Section] DROP CONSTRAINT [FK_Section_Course];

    -- Aryeh
    ALTER TABLE [Academic].[Department] DROP CONSTRAINT FK_Department_UserAuthorization;
    ALTER TABLE [Personnel].[DepartmentInstructor] DROP CONSTRAINT FK_DepartmentInstructor_UserAuthorization;
    ALTER TABLE [Personnel].[DepartmentInstructor] DROP CONSTRAINT FK_DepartmentInstructor_Department;
    ALTER TABLE [Personnel].[DepartmentInstructor] DROP CONSTRAINT FK_DepartmentInstructor_Instructor;
    ALTER TABLE [ClassManagement].[ClassDays] DROP CONSTRAINT FK_ClassDays_UserAuthorization;
    ALTER TABLE [ClassManagement].[ClassDays] DROP CONSTRAINT FK_ClassDays_Class;
    ALTER TABLE [ClassManagement].[ClassDays] DROP CONSTRAINT FK_ClassDays_Days;

    -- Edwin
    ALTER TABLE [Facilities].[BuildingLocations] DROP CONSTRAINT FK_BuildingLocations_UserAuthorization;
    ALTER TABLE [ClassManagement].[Class] DROP CONSTRAINT FK_Class_UserAuthorization;
    ALTER TABLE [ClassManagement].[Class] DROP CONSTRAINT FK_Class_Course;
    ALTER TABLE [ClassManagement].[Class] DROP CONSTRAINT FK_Class_Section;
    ALTER TABLE [ClassManagement].[Class] DROP CONSTRAINT FK_Class_Instructor;
    ALTER TABLE [ClassManagement].[Class] DROP CONSTRAINT FK_Class_RoomLocation;
    ALTER TABLE [ClassManagement].[Class] DROP CONSTRAINT FK_Class_ModeOfInstruction;

    -- add more here...

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Drop Foreign Keys',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


/*
Stored Procedure: [Project3].[LoadInstructors]

-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 12/4/23
-- Description:	Adds the Instructors to the Instructor Table
-- =============================================

*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadInstructors] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [Personnel].[Instructor](
        FirstName, LastName, UserAuthorizationKey, DateAdded
    )
    SELECT DISTINCT
        -- use COALESCE/NULLIF to check when importing the data from the original table to prevent importing nulls 
        COALESCE(NULLIF(LTRIM(RTRIM(SUBSTRING(Instructor, CHARINDEX(',', Instructor) + 2, LEN(Instructor)))), ''), 'none') AS FirstName,
        COALESCE(NULLIF(LTRIM(RTRIM(SUBSTRING(Instructor, 1, CHARINDEX(',', Instructor) - 1))), ''), 'none') AS LastName,
        @UserAuthorizationKey, 
        @DateAdded
    FROM
    [Uploadfile].[CurrentSemesterCourseOfferings]
    ORDER BY LastName;

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Personnel].[Instructor]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Instructor Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 12/4/23
-- Description:	Adds the Courses to the Course Table
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadCourse] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [Academic].[Course](
        [CourseAbbreviation] -- Course (parse letters)
        ,[CourseNumber] -- Course (parse number)
        ,[CourseCredit] -- Course (parse second number in (,))
        ,[CreditHours] -- Course (parse first number in (,))
        ,[CourseName] -- Description 
        ,[DepartmentID] -- fk
        ,UserAuthorizationKey
        ,DateAdded
    )
    SELECT DISTINCT
        LEFT([Course (hr, crd)], PATINDEX('%[ (]%', [Course (hr, crd)]) - 1) -- CourseAbbreviation
        ,SUBSTRING(
                [Course (hr, crd)], 
                PATINDEX('%[0-9]%', [Course (hr, crd)]), 
                CHARINDEX('(', [Course (hr, crd)]) - PATINDEX('%[0-9]%', [Course (hr, crd)])
            ) -- CourseNumber
        ,CAST(SUBSTRING(
                [Course (hr, crd)], 
                CHARINDEX(',', [Course (hr, crd)]) + 2, 
                CHARINDEX(')', [Course (hr, crd)]) - CHARINDEX(',', [Course (hr, crd)]) - 2 
                ) AS FLOAT) --CourseCredit
        ,CAST(SUBSTRING(
                [Course (hr, crd)], 
                CHARINDEX('(', [Course (hr, crd)]) + 1, 
                CHARINDEX(',', [Course (hr, crd)]) - CHARINDEX('(', [Course (hr, crd)]) - 1
                ) AS FLOAT) -- CreditHours 
        ,C.Description -- CourseName
        , ( SELECT TOP 1 D.DepartmentID
            FROM [Academic].[Department] AS D
            WHERE D.DepartmentName = LEFT([Course (hr, crd)], PATINDEX('%[ (]%', [Course (hr, crd)]) - 1))  
        ,@UserAuthorizationKey 
        ,@DateAdded
    FROM
    [Uploadfile].[CurrentSemesterCourseOfferings] AS C;

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Academic].[Course]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Instructor Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO




/*
Stored Procedure: Project2.[TruncateClassScheduleData]

Description:
This procedure is designed to truncate tables in the schema of the data warehouse. 
It removes all records from specified dimension and fact tables and restarts the 
associated sequences. This action is essential for data refresh scenarios where 
existing data needs to be cleared before loading new data.

-- =============================================
-- Author:		Nicholas Kong
-- Create date: 11/13/2023
-- Description:	Truncate the star schema 
-- =============================================
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[TruncateClassScheduleData]
    @UserAuthorizationKey int

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    -- Aleks
    TRUNCATE TABLE [DbSecurity].[UserAuthorization]
    TRUNCATE TABLE [Process].[WorkFlowSteps]
    TRUNCATE TABLE [Personnel].[Instructor]
    TRUNCATE TABLE [Academic].[Course]

    -- Aryeh
    TRUNCATE TABLE [Academic].[Department]
    TRUNCATE TABLE [Personnel].[DepartmentInstructor]
    TRUNCATE TABLE [ClassManagement].[ClassDays]

	-- Nicholas
	TRUNCATE TABLE [ClassManagement].[ModeOfInstruction]
	TRUNCATE TABLE [Facilities].[RoomLocation]
	TRUNCATE TABLE [ClassManagement].[Schedule]

    -- Ahnaf
    TRUNCATE TABLE [ClassManagement].[Days]
	TRUNCATE TABLE [Enrollment].[EnrollmentDetail]

    -- Sigi
    TRUNCATE TABLE [Enrollment].[Semester]
    TRUNCATE TABLE [Academic].[Section]

    -- Edwin
    TRUNCATE TABLE [Facilities].[BuildingLocations]
    TRUNCATE TABLE [ClassManagement].[Class]

    -- add more here...

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 0;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Truncate Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO



/*
Stored Procedure: Project2.[ShowTableStatusRowCount]

Description:
This procedure is designed to report the row count of various tables in the database, 
providing a snapshot of the current data volume across different tables. 
The procedure also logs this operation, including user authorization keys and timestamps, 
to maintain an audit trail.

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 11/13/23
-- Description:	Populate a table to show the status of the row counts
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[ShowTableStatusRowCount]
    @TableStatus VARCHAR(64),
    @UserAuthorizationKey INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();

    DECLARE @DateOfLastUpdate DATETIME2 = SYSDATETIME();

    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    DECLARE @WorkFlowStepTableRowCount INT = 0;

    -- Aleks
        SELECT TableStatus = @TableStatus,
            TableName = '[DbSecurity].[UserAuthorization]',
            [Row Count] = COUNT(*)
        FROM [DbSecurity].[UserAuthorization]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Process].[WorkflowSteps]',
            [Row Count] = COUNT(*)
        FROM [Process].[WorkflowSteps]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Personnel].[Instructor]',
            [Row Count] = COUNT(*)
        FROM [Personnel].[Instructor]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Academic].[Course]',
            [Row Count] = COUNT(*)
        FROM [Academic].[Course] 
    -- Ahnaf
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[ClassManagement].[Days]',
            [Row Count] = COUNT(*)
        FROM [ClassManagement].[Days]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Enrollment].[EnrollmentDetail]',
            [Row Count] = COUNT(*)
        FROM [Enrollment].[EnrollmentDetail]
    -- Nicholas 
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[ClassManagement].[ModeOfInstruction]',
            [Row Count] = COUNT(*)
        FROM [ClassManagement].[ModeOfInstruction]
	UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Facilities].[RoomLocation]',
            [Row Count] = COUNT(*)
        FROM [Facilities].[RoomLocation]
	UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[ClassManagement].[Schedule]',
            [Row Count] = COUNT(*)
        FROM [ClassManagement].[Schedule]
    -- Sigi
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Enrollment].[Semester]',
            [Row Count] = COUNT(*)
        FROM [Enrollment].[Semester]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Academic].[Section]',
            [Row Count] = COUNT(*)
        FROM [Academic].[Section]
    -- Aryeh
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Academic].[Department]',
            [Row Count] = COUNT(*)
        FROM [Academic].[Department]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Personnel].[DepartmentInstructor]',
            [Row Count] = COUNT(*)
        FROM [Personnel].[DepartmentInstructor]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[ClassManagement].[ClassDays]',
            [Row Count] = COUNT(*)
        FROM [ClassManagement].[ClassDays]
    -- Edwin
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[Facilities].[BuildingLocations]',
            [Row Count] = COUNT(*)
        FROM [Facilities].[BuildingLocations]
    UNION ALL
        SELECT TableStatus = @TableStatus,
            TableName = '[ClassManagement].[Class]',
            [Row Count] = COUNT(*)
        FROM [ClassManagement].[Class]


    -- add more here... 
    ;


    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Procedure: Project3[ShowStatusRowCount] loads data into ShowTableStatusRowCount',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


/*
Stored Procedure: [Project3].[LoadSemesters]

-- =============================================
-- Author:		Sigalita Yakubova
-- Create date: 12/4/23
-- Description:	Loads in the Semester Table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadSemesters] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    --Right now this should only fill the table with Fall 2023 but in the future this will be a useful feature
    INSERT INTO [Enrollment].[Semester](
        SemesterName, UserAuthorizationKey, DateAdded
    )
    SELECT DISTINCT [Udt].GetSemesterName(@DateAdded), @UserAuthorizationKey, @DateAdded
    FROM
    [Uploadfile].[CurrentSemesterCourseOfferings]

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Enrollment].[Semester]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Semester Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO

/*
Stored Procedure: [Project3].[LoadSections]

-- =============================================
-- Author:		Sigalita Yakubova
-- Create date: 12/4/23
-- Description:	Loads in the Section Table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadSections] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [Academic].[Section] (Section, Code, CourseID, UserAuthorizationKey, DateAdded)
    SELECT DISTINCT
        Upload.Sec,
        Upload.Code,
        (
            SELECT TOP 1 C.CourseId
            FROM [Academic].[Course] AS C
            WHERE 
                C.CourseAbbreviation = LEFT(Upload.[Course (hr, crd)], PATINDEX('%[ (]%', Upload.[Course (hr, crd)]) - 1) AND 
                C.CourseNumber = SUBSTRING(
                    Upload.[Course (hr, crd)], 
                    PATINDEX('%[0-9]%', Upload.[Course (hr, crd)]), 
                    CHARINDEX('(', Upload.[Course (hr, crd)]) - PATINDEX('%[0-9]%', Upload.[Course (hr, crd)])
                )
        ) AS CourseID,
        @UserAuthorizationKey,
        @DateAdded
    FROM
        [Uploadfile].[CurrentSemesterCourseOfferings] AS Upload;

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Academic].[Section]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Section Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


/*
Stored Procedure: [Project3].[LoadDays]

-- =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 12/4/23
-- Description:	Adds the day abbreviation to the Days Table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadDays] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [ClassManagement].[Days](
        [DayAbbreviation], [UserAuthorizationKey]
    )
    VALUES 
        
        ('M', @UserAuthorizationKey),
        ('T', @UserAuthorizationKey),
        ('W', @UserAuthorizationKey),
        ('TH', @UserAuthorizationKey),
        ('F', @UserAuthorizationKey),
        ('S', @UserAuthorizationKey),
        ('SU', @UserAuthorizationKey)

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = 7;
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Procedure: [Project3].[LoadDays] loads DayAbbreviation into the [Days] table',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO

/*
Stored Procedure: [Project3].[LoadEnrollmentDetail]

-- =============================================
-- Author:		Ahnaf Ahmed
-- Create date: 12/8/23
-- Description:	Loads in the EnrollmentDetail Table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadEnrollmentDetail] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [Enrollment].[EnrollmentDetail]
	(SectionID,
		CurrentEnrollment,
		MaxEnrollmentLimit,
		OverEnrolled,
		UserAuthorizationKey,
		DateAdded)
    SELECT DISTINCT
        S.SectionID,
		CAST(Upload.Enrolled AS INT),
		CAST(Upload.Limit AS INT),
		CASE
			WHEN CAST(Upload.Enrolled AS INT) <= CAST(Upload.Limit AS INT) THEN 'No'
			ELSE 'Yes'
		END,
        @UserAuthorizationKey,
        @DateAdded
    FROM
        [Uploadfile].[CurrentSemesterCourseOfferings] AS Upload
		INNER JOIN [Academic].[Section] AS S
		ON Upload.Code = S.Code

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Enrollment].[EnrollmentDetail]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Procedure: [Project3].[LoadEnrollmentDetail] loads [EnrollmentDetail] table',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


-- =============================================
-- Author:		Nicholas Kong
-- Create date: 12/4/23
-- Description:	Populate a table to show the mode of instruction
-- =============================================


CREATE OR ALTER PROCEDURE [Project3].[LoadModeOfInstruction]
    -- Add parameters if needed
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @DateOfLastUpdate DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO ClassManagement.ModeOfInstruction(
                                                ModeName, 
                                                UserAuthorizationKey, 
                                                DateAdded)
    SELECT DISTINCT Q.[Mode of Instruction], 
            @UserAuthorizationKey, 
            @DateAdded
    FROM [QueensClassSchedule].[Uploadfile].[CurrentSemesterCourseOfferings] as Q
    -- Additional statements or constraints can be added here

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [ClassManagement].[ModeOfInstruction]
                                    );
	DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
	DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Procedure: Project3[LoadModeOfInstruction] loads data into ShowTableStatusRowCount',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;

END;
GO

-- =============================================
-- Author:		Nicholas Kong
-- Create date: 12/6/23
-- Description:	Populate a table to show the room location
-- =============================================

CREATE OR ALTER PROCEDURE [Project3].[LoadRoomLocation]
    -- Add parameters if needed
    @UserAuthorizationKey INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @DateOfLastUpdate DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

	INSERT INTO [Facilities].[RoomLocation](RoomNumber,UserAuthorizationKey, DateAdded)
	SELECT
    CASE
		-- add the edge cases and then manually set it correctly
        WHEN RIGHT(Q.Location, 4) = 'H 17' THEN '17'
        WHEN RIGHT(Q.Location, 4) = '135H' THEN 'A135H'
		WHEN RIGHT(Q.Location, 4) = '135B' THEN 'A135B'
		WHEN RIGHT(Q.Location, 4) = 'H 09' THEN '09'
		WHEN RIGHT(Q.Location, 4) = 'H 12' THEN '12'

		-- checks for null and empty string, if so set default string named TBD
       WHEN Q.Location IS NULL OR LTRIM(RTRIM(Q.Location)) = '' THEN 'TBD'
        ELSE RIGHT(Q.Location, 4)
    END AS RoomNumber, @UserAuthorizationKey, @DateAdded
	FROM [QueensClassSchedule].[Uploadfile].[CurrentSemesterCourseOfferings] as Q

    -- Additional statements or constraints can be added here

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Facilities].[RoomLocation]
                                    );
	DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
	DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Procedure: Project3[LoadRoomLocation] loads data into ShowTableStatusRowCount',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;

END;
GO

-- =============================================
-- Author:		Nicholas Kong
-- Create date: 12/8/23
-- Description:	Populate a table to show the Schedule
-- =============================================

CREATE OR ALTER PROCEDURE [Project3].[LoadSchedule]
  --Add parameters if needed
  @UserAuthorizationKey INT
  AS
  BEGIN

  SET NOCOUNT ON;
  DECLARE @DateAdded DATETIME2 = SYSDATETIME();
  DECLARE @DateOfLastUpdate DATETIME2 = SYSDATETIME();
  DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

	INSERT INTO [ClassManagement].[Schedule]	(RoomID,
												SectionID,
												ClassID,
												SemesterID,
												StartTimeRange, 
												EndTimeRange, 
												UserAuthorizationKey, 
												DateAdded)
	SELECT
		-- roomID
		( SELECT TOP 1 R.RoomID
            FROM [Facilities].[RoomLocation] AS R
            WHERE R.RoomNumber = CASE
                                    -- add the edge cases and then manually set it correctly
                                    WHEN RIGHT(Q.Location, 4) = 'H 17' THEN '17'
                                    WHEN RIGHT(Q.Location, 4) = '135H' THEN 'A135H'
                                    WHEN RIGHT(Q.Location, 4) = '135B' THEN 'A135B'
                                    WHEN RIGHT(Q.Location, 4) = 'H 09' THEN '09'
                                    WHEN RIGHT(Q.Location, 4) = 'H 12' THEN '12'

                                    -- checks for null and empty string, if so set default string named TBD
                                    WHEN Q.Location IS NULL OR LTRIM(RTRIM(Q.Location)) = '' THEN 'TBD'
                                        ELSE RIGHT(Q.Location, 4)
                                END
        ),
		-- SectionId
		 ( SELECT TOP 1 S.SectionID
            FROM [Academic].[Section] AS S
            WHERE S.Code = Q.Code -- Section Code
                AND S.Section = Q.Sec -- Section Number
        ),
		-- ClassID
		( SELECT TOP 1 C.ClassID
            FROM [ClassManagement].[Class] AS C
				INNER JOIN [Academic].[Section] AS S
				ON C.SectionID = S.SectionID
            WHERE C.SectionId = S.SectionID 
        ),
		-- SemesterId
		(SELECT TOP 1 S.SemesterID
            FROM [Enrollment].[Semester] AS S
			WHERE S.SemesterName = 'Fall 2023'
         ),
		-- StartTimeRange
		CONVERT(TIME, NULLIF(LEFT(Q.Time, CHARINDEX('-', Q.Time) - 1), 'TBD'), 108) AS ConvertedStartTime, 
		--EndTimeRange
		CONVERT(TIME, NULLIF(RIGHT(Q.Time, LEN(Q.Time) - CHARINDEX('-', Q.Time)), 'TBD'), 108) AS ConvertedEndTime, 
		@UserAuthorizationKey, @DateAdded
	FROM [QueensClassSchedule].[Uploadfile].[CurrentSemesterCourseOfferings] as Q;


    -- Additional statements or constraints can be added here

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [ClassManagement].[Schedule]
                                    );
	DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
	DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Procedure: Project3[LoadSchedule] loads data into ShowTableStatusRowCount',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;

END;
GO

/*
Stored Procedure: [Project3].[LoadDepartments]

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 12/5/23
-- Description:	Adds the Departments to the Department Table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadDepartments] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [Academic].[Department] (
        DepartmentName, UserAuthorizationKey, DateAdded
    )
    SELECT DISTINCT
        LEFT([Course (hr, crd)], CHARINDEX(' ', [Course (hr, crd)]) - 1) AS DepartmentName,
        @UserAuthorizationKey, 
        @DateAdded
    FROM [Uploadfile].[CurrentSemesterCourseOfferings]
    ORDER BY DepartmentName

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Academic].[Department]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Department Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO



/*
Stored Procedure: [Project3].[LoadDepartmentInstructor]

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 12/6/23
-- Description:	Adds the values to the Department / Instructor bridge table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadDepartmentInstructor] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [Personnel].[DepartmentInstructor] (
        DepartmentID, InstructorID, UserAuthorizationKey, DateAdded
    )
    SELECT DISTINCT D.DepartmentID, I.InstructorID, @UserAuthorizationKey, @DateAdded
    FROM Academic.Department AS D
        CROSS JOIN Personnel.Instructor AS I
        INNER JOIN Uploadfile.CurrentSemesterCourseOfferings AS U
            ON LEFT(U.[Course (hr, crd)], CHARINDEX(' ', U.[Course (hr, crd)]) - 1) = D.DepartmentName
            AND LTRIM(RTRIM(SUBSTRING(U.Instructor, CHARINDEX(',', U.Instructor) + 2, LEN(U.Instructor)))) = I.FirstName
            AND LTRIM(RTRIM(SUBSTRING(U.Instructor, 1, CHARINDEX(',', U.Instructor) - 1))) = I.LastName

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Personnel].[DepartmentInstructor]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Department Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO



/*
Stored Procedure: [Project3].[LoadClassDays]

-- =============================================
-- Author:		Aryeh Richman
-- Create date: 12/10/23
-- Description:	Adds the values to the Class / Day bridge table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadClassDays] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [ClassManagement].[ClassDays] (
        ClassID, DayID, UserAuthorizationKey, DateAdded
    )
    SELECT DISTINCT C.ClassID, D.DayID, @UserAuthorizationKey, @DateAdded
    FROM ClassManagement.Class AS C
        CROSS JOIN ClassManagement.[Days] AS D
        INNER JOIN Academic.Section AS S 
            ON S.SectionID = C.SectionID
        INNER JOIN Uploadfile.CurrentSemesterCourseOfferings AS U
            ON U.Code = S.Code
        CROSS APPLY dbo.SplitString(U.Day, ',') AS SS
        WHERE D.DayAbbreviation = LTRIM(RTRIM(SS.Value))

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [ClassManagement].[ClassDays]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add ClassDays Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


/*
Stored Procedure: [Project3].[LoadBuildingLocations]

-- =============================================
-- Author:		Edwin Wray
-- Create date: 12/5/23
-- Description:	Adds the BuildingLocations to the BuildingLocations Table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadBuildingLocations] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [Facilities].[BuildingLocations] (
        BuildingNameAbbrv, BuildingName, UserAuthorizationKey, DateAdded
    )
    SELECT DISTINCT
        [UDT].[GetBuildingNameAbbrv]([Location]) AS BuildingNameAbbrv,
        [UDT].[GetBuildingName]([Location]) AS BuildingName,
        @UserAuthorizationKey, 
        @DateAdded
    FROM [Uploadfile].[CurrentSemesterCourseOfferings]
    ORDER BY BuildingName

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [Facilities].[BuildingLocations]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add BuildingLocations Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO

 
/*
Stored Procedure: [Project3].[LoadClass]

-- =============================================
-- Author:		Edwin Wray
-- Create date: 12/5/23
-- Description:	Adds Classes to the Class Table
-- =============================================

*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadClass] @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DateAdded DATETIME2 = SYSDATETIME();
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    INSERT INTO [ClassManagement].[Class] (
        CourseID, SectionID, InstructorID, RoomID, ModeID, UserAuthorizationKey, DateAdded
    ) 
    SELECT DISTINCT
        ( SELECT TOP 1 C.CourseID
            FROM [Academic].[Course] AS C
            WHERE C.CourseAbbreviation = LEFT([Course (hr, crd)], PATINDEX('%[ (]%', [Course (hr, crd)]) - 1) -- CourseAbbreviation
                    AND C.CourseNumber = SUBSTRING([Course (hr, crd)], PATINDEX('%[0-9]%', [Course (hr, crd)]), 
                            CHARINDEX('(', [Course (hr, crd)]) - PATINDEX('%[0-9]%', [Course (hr, crd)])) -- CourseNumber
        )
        , ( SELECT TOP 1 S.SectionID
            FROM [Academic].[Section] AS S
            WHERE S.Code = U.Code -- Section Code
                AND S.Section = U.Sec -- Section Number
        )
        , ( SELECT TOP 1 I.InstructorID
            FROM [Personnel].[Instructor] AS I
            WHERE I.FirstName = COALESCE(NULLIF(LTRIM(RTRIM(SUBSTRING(U.Instructor, CHARINDEX(',', U.Instructor) + 2, LEN(U.Instructor)))), ''), 'none') -- FirstName
                AND I.LastName = COALESCE(NULLIF(LTRIM(RTRIM(SUBSTRING(U.Instructor, 1, CHARINDEX(',', U.Instructor) - 1))), ''), 'none') -- LastName
        )
        , ( SELECT TOP 1 R.RoomID
            FROM [Facilities].[RoomLocation] AS R
            WHERE R.RoomNumber = CASE
                                    -- add the edge cases and then manually set it correctly
                                    WHEN RIGHT(U.Location, 4) = 'H 17' THEN '17'
                                    WHEN RIGHT(U.Location, 4) = '135H' THEN 'A135H'
                                    WHEN RIGHT(U.Location, 4) = '135B' THEN 'A135B'
                                    WHEN RIGHT(U.Location, 4) = 'H 09' THEN '09'
                                    WHEN RIGHT(U.Location, 4) = 'H 12' THEN '12'

                                    -- checks for null and empty string, if so set default string named TBD
                                    WHEN U.Location IS NULL OR LTRIM(RTRIM(U.Location)) = '' THEN 'TBD'
                                        ELSE RIGHT(U.Location, 4)
                                END
        )
        , ( SELECT TOP 1 M.ModeID
            FROM [ClassManagement].[ModeOfInstruction] AS M
            WHERE M.ModeName = U.[Mode of Instruction]
        )
        , @UserAuthorizationKey 
        , @DateAdded
    FROM [Uploadfile].[CurrentSemesterCourseOfferings] AS U;

    DECLARE @WorkFlowStepTableRowCount INT;
    SET @WorkFlowStepTableRowCount = (
                                    SELECT COUNT(*) 
                                    FROM [ClassManagement].[Class]
                                    );
    DECLARE @EndingDateTime DATETIME2 = SYSDATETIME();
    DECLARE @QueryTime BIGINT = CAST(DATEDIFF(MILLISECOND, @StartingDateTime, @EndingDateTime) AS bigint);
    EXEC [Process].[usp_TrackWorkFlow] 'Add Class Data',
                                       @WorkFlowStepTableRowCount,
                                       @StartingDateTime,
                                       @EndingDateTime,
                                       @QueryTime,
                                       @UserAuthorizationKey;
END;
GO


-- add more stored procedures here... 




----------------------------------------------- CREATE VIEWS -------------------------------------------------------














--------------------------------------- DB CONTROLLER STORED PROCEDURES ----------------------------------------------

/*
-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/14/23
-- Description:	Clears all data from the Class Schedule db
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[TruncateClassScheduleDatabase]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    -- Drop All of the foreign keys prior to truncating tables in the Class Schedule db
    EXEC [Project3].[DropForeignKeysFromClassSchedule] @UserAuthorizationKey = 1;

    --	Check row count before truncation
    EXEC [Project3].[ShowTableStatusRowCount] @UserAuthorizationKey = 6,  
		@TableStatus = N'''Pre-truncate of tables'''

    --	Always truncate the Star Schema Data
    EXEC  [Project3].[TruncateClassScheduleData] @UserAuthorizationKey = 3;

    --	Check row count AFTER truncation
    EXEC [Project3].[ShowTableStatusRowCount] @UserAuthorizationKey = 6,  
		@TableStatus = N'''Post-truncate of tables'''
END;
GO


/*
This T-SQL script is for creating a stored procedure named LoadClassScheduleDatabase within a SQL Server database, likely for the 
purpose of managing and updating a star schema data warehouse structure. Here's a breakdown of what this script does:



-- =============================================
-- Author:		Aleksandra Georgievska
-- Create date: 11/14/23
-- Description:	Procedure runs other stored procedures to populate the data
-- =============================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [Project3].[LoadClassScheduleDatabase]
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartingDateTime DATETIME2 = SYSDATETIME();

    /*
            Note: User Authorization keys are hardcoded, each representing a different group user 
                    Aleksandra Georgievska → User Key 1
                    Sigalita Yakubova → User Key 2
                    Nicholas Kong → User Key 3
                    Edwin Wray → User Key 4
                    Ahnaf Ahmed → User Key 5
                    Aryeh Richman → User Key 6
    */

    -- ADD EXEC COMMANDS:

    -- TIER ONE TABLE LOADS
    -- Aleks
    EXEC [Project3].[Load_UserAuthorization] @UserAuthorizationKey = 1
    EXEC [Project3].[LoadInstructors] @UserAuthorizationKey = 1
    
    -- Aryeh
    EXEC [Project3].[LoadDepartments] @UserAuthorizationKey = 6
    
    -- Nicholas
    EXEC [Project3].[LoadModeOfInstruction] @UserAuthorizationKey = 3

    -- Ahnaf
    EXEC [Project3].[LoadDays] @UserAuthorizationKey = 5
    -- Sigi
    EXEC [Project3].[LoadSemesters] @UserAuthorizationKey = 2
    -- Edwin
    EXEC [Project3].[LoadBuildingLocations] @UserAuthorizationKey = 4	


    -- TIER 2 TABLE LOADS
    -- Aleks
    EXEC [Project3].[LoadCourse] @UserAuthorizationKey = 1

    -- Aryeh
    EXEC [Project3].[LoadDepartmentInstructor] @UserAuthorizationKey = 6

    -- Nicholas
    EXEC [Project3].[LoadRoomLocation]  @UserAuthorizationKey = 3


    -- TIER 3 TABLE LOADS	
    --Sigi
    EXEC [Project3].[LoadSections] @UserAuthorizationKey = 2

	-- Edwin
    EXEC [Project3].[LoadClass] @UserAuthorizationKey = 4

	-- Ahnaf
	EXEC [Project3].[LoadEnrollmentDetail] @UserAuthorizationKey = 5

	-- TIER 4 TABLE LOADS
	-- Nicholas 
	EXEC [Project3].[LoadSchedule]  @UserAuthorizationKey = 3

    -- areyh
    EXEC [Project3].[LoadClassDays]  @UserAuthorizationKey = 6

    --	Check row count before truncation
    EXEC [Project3].[ShowTableStatusRowCount] @UserAuthorizationKey = 6,  -- Change to the appropriate UserAuthorizationKey
		@TableStatus = N'''Row Count after loading the Class Schedule db'''

END;
GO

