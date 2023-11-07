SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Get_CoursesBySearchTerm]
    @SiteID INT,
    @UserId INT,
    @IsMasterAdmin BIT,
    @SearchTerm NVARCHAR(255),
    @MinimumPermissions INT,
    @TopN INT = 100
AS
SET NOCOUNT ON;
IF @IsMasterAdmin = 1
BEGIN
    SELECT TOP (@topN)
        c.CourseName AS name,
        'Course' AS objectType,
        c.CourseID AS objectId,
		c.IsArchived,
		c.Enabled,
        --has edit over all
        31 AS SecurityAllowAttributes,
        --masteradmin has all rights to everyone
        31 AS CascadingSecurityAllowAttributes
    FROM dbo.VCourses c
    WHERE c.SiteID = @SiteID
        AND c.CourseName LIKE @SearchTerm
    ORDER BY
        (
            SELECT NULL
        )
    OPTION (RECOMPILE);
END;
ELSE
BEGIN
    SELECT TOP (@topN) 
        c.CourseName AS name,
        'Course' AS objectType,
        c.CourseID AS objectId,
		c.IsArchived,
		c.Enabled,
        v.SecurityAllowAttributes, 
        NULL AS CascadingSecurityAllowAttributes
    FROM dbo.VCourses c
         INNER JOIN dbo.VUsersExplicitRightsToCourses v ON v.SiteID = c.SiteID
	 AND v.CourseID = c.CourseID
    WHERE v.SiteID = @SiteID
          AND v.UserID = @UserId
           AND v.UserID = @UserId
          AND (v.SecurityAllowAttributes >= @MinimumPermissions)
          AND c.CourseName LIKE @SearchTerm
    ORDER BY
    (
        SELECT NULL
    )
    OPTION (RECOMPILE);
END;
GO