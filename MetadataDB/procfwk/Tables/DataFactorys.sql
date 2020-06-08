CREATE TABLE [procfwk].[DataFactorys](
	[DataFactoryId] [int] IDENTITY(1,1) NOT NULL,
	[DataFactoryName] NVARCHAR(200) NOT NULL,
	[ResourceGroupName] NVARCHAR(200) NOT NULL, 
	[Description] NVARCHAR(MAX) NULL,	
    CONSTRAINT [PK_DataFactorys] PRIMARY KEY CLUSTERED ([DataFactoryId] ASC)
 )