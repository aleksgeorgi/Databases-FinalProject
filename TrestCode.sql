USE QueensClassSchedule;
GO

USE QueensClassSchedule;
GO

SELECT 
    CASE 
        WHEN CHARINDEX(' ', Location) > 0 
        THEN LEFT(Location, CHARINDEX(' ', Location) - 1)
        ELSE 'TBD'
    END AS BuildingAbbrv
    , CASE
        WHEN 
            CASE 
                WHEN CHARINDEX(' ', Location) > 0 
                THEN LEFT(Location, CHARINDEX(' ', Location) - 1)
                ELSE 'TBD'
            END 
        = 'KY' THEN 'Kiely Hall'
    END AS BuildingName
    , CASE 
        WHEN CHARINDEX(' ', Location) > 0 
        THEN RIGHT(Location, LEN(Location) - CHARINDEX(' ', Location))
        ELSE 'TBD'
    END AS RoomNumber
    , Code
FROM Uploadfile.CurrentSemesterCourseOfferings
ORDER BY Code
