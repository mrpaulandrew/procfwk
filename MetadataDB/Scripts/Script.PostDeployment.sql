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
--load default metadata
:r .\Metadata\Properties.sql
:r .\Metadata\DataFactorys.sql
:r .\Metadata\Stages.sql
:r .\Metadata\Pipelines.sql
:r .\Metadata\PipelineParams.sql
:r .\Metadata\PipelineDependencies.sql
:r .\Metadata\Recipients.sql
:r .\Metadata\AlertOutcomes.sql
:r .\Metadata\RecipientAlertsLink.sql

--restore log data
:r .\LogData\ExecutionLogRestore.sql
:r .\LogData\ErrorLogRestore.sql

--object transfers
:r .\Metadata\TransferHelperObjects.sql
:r .\Metadata\TransferReportingObjects.sql