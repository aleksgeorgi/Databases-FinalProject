USE [ClassSchedule_9:15_Group1]
GO

-- Run the next command to populate the ClassSchedule database with all of the data 
EXEC [Project3].[LoadClassScheduleDatabase]  @UserAuthorizationKey = 1;

-- Run the next code to execute the Workflow steps to demo in the JDBC
SELECT  WFS.[Class Time], 
        WFS.[EndingDateTime], 
        WFS.StartingDateTime, 
        WFS.UserAuthorizationKey, 
        WFS.WorkFlowStepDescription, 
        WFS.WorkFlowStepKey, 
        WFS.WorkFlowStepTableRowCount
FROM [Process].[WorkflowSteps] AS WFS

-- Show the UserAuthorization table 
SELECT *
FROM [DbSecurity].[UserAuthorization]