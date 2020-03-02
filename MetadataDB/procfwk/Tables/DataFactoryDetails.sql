CREATE TABLE [procfwk].[DataFactoryDetails](
	[DataFactoryId] [int] IDENTITY(1,1) NOT NULL,
	[DataFactoryName] [varchar](128) NOT NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_DataFactoryDetails] PRIMARY KEY CLUSTERED ([DataFactoryId] ASC)
 )