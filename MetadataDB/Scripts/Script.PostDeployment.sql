/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
--load metadata
:r .\Metadata\DataFactorys.sql
:r .\Metadata\Stages.sql
:r .\Metadata\Pipelines.sql
:r .\Metadata\PipelineParams.sql
:r .\Metadata\PipelineDependencies.sql
:r .\Metadata\Recipients.sql
:r .\Metadata\AlertOutcomes.sql

--restore log data
:r .\LogData\ExecutionLogRestore.sql
:r .\LogData\ErrorLogRestore.sql

--merged
:r .\Metadata\Properties.sql
:r .\Metadata\RecipientAlertsLink.sql
