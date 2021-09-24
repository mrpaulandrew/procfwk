/*
See below blog post for context
https://mrpaulandrew.com/2021/07/29/using-mermaid-to-create-a-procfwk-pipeline-lineage-diagram/
*/

SET NOCOUNT ON;
 
--local variables
DECLARE @BatchName VARCHAR(255) = 'Daily'; --set as required
 
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
SELECT
    @PageContent = 'subgraph ' + [BatchName] + CHAR(13) +
    'style ' + @BatchName + ' fill:#DEEBF7,stroke:#DEEBF7' + CHAR(13) + @PageContent
FROM
    [procfwk].[Batches]
WHERE
    [BatchName] = @BatchName;
 
SET @PageContent = @PageContent + 'end';
 
--add mermaid header
SELECT
    @PageContent = '::: mermaid' + CHAR(13) + 'graph LR' + CHAR(13) + @PageContent;
 
--return output
PRINT @PageContent