SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [Standards].[Get_AssessmentsBySearchTerm]
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
        a.Name AS name,
        'Assessment' AS objectType,
        a.AssessmentID AS objectId,
		a.IsClosed,
        --has edit over all
        31 AS SecurityAllowAttributes,
        --masteradmin has all rights to everyone
        31 AS CascadingSecurityAllowAttributes
    FROM Standards.VAssessments a
    WHERE a.SiteID = @SiteID
        AND a.Name LIKE @SearchTerm
    ORDER BY
        (
            SELECT NULL
        )
    OPTION (RECOMPILE);
END;
ELSE
BEGIN
    SELECT TOP (@topN) 
        a.Name AS name,
        'Assessment' AS objectType,
        a.AssessmentID AS objectId,
		a.IsClosed,
        v.SecurityAllowAttributes, 
        NULL AS CascadingSecurityAllowAttributes
    FROM Standards.VAssessments a
         INNER JOIN dbo.VUsersExplicitRightsToAssessments v ON v.SiteID = a.SiteID
                                                          AND v.AssessmentID = a.AssessmentID
    WHERE v.SiteID = @SiteID
          AND v.UserID = @UserId
           AND v.UserID = @UserId
          AND (v.SecurityAllowAttributes >= @MinimumPermissions)
          AND a.Name LIKE @SearchTerm
    ORDER BY
    (
        SELECT NULL
    )
    OPTION (RECOMPILE);
END;
GO


