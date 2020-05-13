CREATE TABLE [procfwk].[DataFactorys](
	[DataFactoryId] [int] IDENTITY(1,1) NOT NULL,
	[DataFactoryName] [nvarchar](200) NOT NULL,
	[ResourceGroupName] NVARCHAR(200) NOT NULL, 
	[Description] [nvarchar](MAX) NULL,	
    CONSTRAINT [PK_DataFactorys] PRIMARY KEY CLUSTERED ([DataFactoryId] ASC)
 )