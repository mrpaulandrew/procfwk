CREATE PROCEDURE [procfwkHelpers].[GetMermaidPipelineLineageMarkdown]
    (
    @BatchName VARCHAR(255) = NULL
    )
AS
BEGIN
    SET NOCOUNT ON;

    --local variables
    DECLARE @PageContent NVARCHAR(MAX) = '';
    DECLARE @BaseData TABLE
        (
        [OrchestratorId] INT NOT NULL,
        [OrchestratorName] NVARCHAR(200) NOT NULL,
        [StageId] INT NOT NULL,
        [StageName] VARCHAR(225) NOT NULL,
        [PipelineId] INT NOT NULL,
        [PipelineName] NVARCHAR(200) NOT NULL
        )
 
    --get reusable metadata
    IF @BatchName IS NULL
	    BEGIN
		    INSERT INTO @BaseData
		    SELECT
			    o.[OrchestratorId],
			    o.[OrchestratorName],
			    s.[StageId],
			    s.[StageName],
			    p.[PipelineId],
			    p.[PipelineName]
		    FROM
			    [procfwk].[Pipelines] p
			    INNER JOIN [procfwk].[Orchestrators] o
				    ON p.[OrchestratorId] = o.[OrchestratorId]
			    INNER JOIN [procfwk].[Stages] s
				    ON p.[StageId] = s.[StageId]
		    WHERE
			    p.[Enabled] = 1;
	    END
    ELSE
	    BEGIN
		    INSERT INTO @BaseData
		    SELECT
			    o.[OrchestratorId],
			    o.[OrchestratorName],
			    s.[StageId],
			    s.[StageName],
			    p.[PipelineId],
			    p.[PipelineName]
		    FROM
			    [procfwk].[Pipelines] p
			    INNER JOIN [procfwk].[Orchestrators] o
				    ON p.[OrchestratorId] = o.[OrchestratorId]
			    INNER JOIN [procfwk].[Stages] s
				    ON p.[StageId] = s.[StageId]
			    INNER JOIN [procfwk].[BatchStageLink] bs
				    ON s.[StageId] = bs.[StageId]
			    INNER JOIN [procfwk].[Batches] b
				    ON bs.[BatchId] = b.[BatchId]
		    WHERE
			    p.[Enabled] = 1
			    AND b.[BatchName] = @BatchName;
	    END
 
    --add orchestrator(s) sub graphs
    ;WITH orchestrators AS
        (
        SELECT DISTINCT
            [OrchestratorId],
            [OrchestratorName],
            'subgraph ' + [OrchestratorName] + CHAR(13) + 
            'style ' + [OrchestratorName] + ' fill:#E2F0D9,stroke:#E2F0D9' + CHAR(13) + 
            '##o' + CAST([OrchestratorId] * 10000 AS VARCHAR) + '##' + CHAR(13) + 'end' + CHAR(13)
             AS OrchestratorSubGraphs
        FROM
            @BaseData
        )
    SELECT
        @PageContent += OrchestratorSubGraphs
    FROM
        orchestrators;
 
    --add stage sub graphs
    ;WITH stages AS
        (
        SELECT DISTINCT
            [OrchestratorId],
            [StageName],
            [StageId]
        FROM
            @BaseData
        ),
        stageSubs AS
        (
        SELECT
            [OrchestratorId],
            STRING_AGG('subgraph ' + [StageName] + CHAR(13) + 
                'style ' + [StageName] + ' fill:#FFF2CC,stroke:#FFF2CC' + CHAR(13) + 
                '##s' + CAST([StageId] AS VARCHAR) + '##' + CHAR(13) + 'end', CHAR(13)
                ) AS 'StageSubGraphs'
        FROM
            stages
        GROUP BY
            [OrchestratorId]
        )
    SELECT     
        @PageContent = REPLACE(@PageContent,'##o' + CAST([OrchestratorId] * 10000 AS VARCHAR) + '##',[StageSubGraphs])
    FROM
        stageSubs;
 
    --add pipelines within stage
    ;WITH pipelines AS
        (
        SELECT
            [StageId],
            STRING_AGG(
                CONCAT('p',CAST([PipelineId] * 10 AS VARCHAR),'(',[PipelineName],')',CHAR(13),
                'style ','p',CAST([PipelineId] * 10 AS VARCHAR),' fill:#F2F2F2,stroke:#F2F2F2'),CHAR(13)
                ) AS 'PipelinesInStage'
        FROM
            @BaseData
        GROUP BY
            [StageId]
        )
    SELECT
        @PageContent = REPLACE(@PageContent,'##s' + CAST([StageId] AS VARCHAR) + '##',[PipelinesInStage])
    FROM
        pipelines
 
    --add stage nodes
    ;WITH stageNodes AS
        (
        SELECT DISTINCT
            [StageId],
            's' + CAST([StageId] * 100 AS VARCHAR) + '[' + [StageName] + ']' + CHAR(13) +
            'style s' + CAST([StageId] * 100 AS VARCHAR) + ' fill:#FFF2CC,stroke:#FFF2CC' + CHAR(13) AS StageNode
        FROM
            @BaseData
        )
    SELECT
        @PageContent = @PageContent + [StageNode]
    FROM
        stageNodes
    ORDER BY
        [StageId];
 
    --add stage to pipeline relationships
    SELECT 
        @PageContent = @PageContent + 's' + CAST([StageId] * 100 AS VARCHAR) 
        + ' --> ' + 'p' + CAST([PipelineId] * 10 AS VARCHAR) + CHAR(13)
    FROM
        @BaseData;
 
    --add stage to stage relationships
    ;WITH maxStage AS
        (
        SELECT
            MAX([StageId]) -1 AS maxStageId
        FROM
            @BaseData
        ),
        stageToStage AS
        (
        SELECT DISTINCT
            's' + CAST(b.[StageId] * 100 AS VARCHAR) 
            + ' ==> ' + 's' + CAST((b.[StageId] + 1) * 100 AS VARCHAR) + CHAR(13) AS Content
        FROM
            @BaseData b
            CROSS JOIN maxStage
        WHERE
            b.[StageId] <= maxStage.[maxStageId]
        )
    SELECT
        @PageContent = @PageContent + [Content]
    FROM
        stageToStage;
 
    --add pipeline to pipeline relationships
    SELECT
        @PageContent = @PageContent + 'p' + CAST(pd.[PipelineId] * 10 AS VARCHAR) 
        + ' -.- ' + 'p' + CAST(pd.[DependantPipelineId] * 10 AS VARCHAR) + CHAR(13)
    FROM
        [procfwk].[PipelineDependencies] pd
        INNER JOIN @BaseData b1
            ON pd.[PipelineId] = b1.[PipelineId]
        INNER JOIN @BaseData b2
            ON pd.[DependantPipelineId] = b2.[PipelineId];
 
    --add batch subgraph
    IF @BatchName IS NULL
	    BEGIN
		    SELECT
			    @PageContent = 'subgraph procfwk' + CHAR(13) +
			    'style procfwk fill:#DEEBF7,stroke:#DEEBF7' + CHAR(13) + @PageContent
	    END
    ELSE
	    BEGIN
		    SELECT
			    @PageContent = 'subgraph ' + [BatchName] + CHAR(13) +
			    'style ' + @BatchName + ' fill:#DEEBF7,stroke:#DEEBF7' + CHAR(13) + @PageContent
		    FROM
			    [procfwk].[Batches]
		    WHERE
			    [BatchName] = @BatchName;
	    END
 
    SET @PageContent = @PageContent + 'end';
 
    --add mermaid header
    SELECT
        @PageContent = '::: mermaid' + CHAR(13) + 'graph LR' + CHAR(13) + @PageContent;
 
    --PRINT @PageContent --PRINT could be limited by 8000 bytes for large solutions

    --return output using 'print big' code:
    --source: https://www.richardswinbank.net/tsql/print_big
    DECLARE @text NVARCHAR(MAX)
    SET @text = @PageContent

    DECLARE @lineSep NVARCHAR(2) = CHAR(13) + CHAR(10)  -- Windows \r\n
    DECLARE @maxLen INT = 4000
 
    DECLARE @lastLineSep INT
    DECLARE @len INT
    DECLARE @off INT = 1
 
    WHILE @off < LEN(@text)
    BEGIN
	    SET @lastLineSep = CHARINDEX(REVERSE(@lineSep), REVERSE(SUBSTRING(@text, @off, @maxLen + LEN(@lineSep))))
	    SET @len = @maxLen - CASE @lastLineSep WHEN 0 THEN 0 ELSE @lastLineSep - 1 END
	    PRINT SUBSTRING(@text, @off, @len)
	    SET @off += CASE @lastLineSep WHEN 0 THEN 0 ELSE LEN(@lineSep) END + @len
    END
END