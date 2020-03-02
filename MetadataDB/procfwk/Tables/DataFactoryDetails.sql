CREATE TABLE [procfwk].[DataFactoryDetails](
	[DataFactoryId] [int] IDENTITY(1,1) NOT NULL,
	[DataFactoryName] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_DataFactoryDetails] PRIMARY KEY CLUSTERED ([DataFactoryId] ASC)
 )