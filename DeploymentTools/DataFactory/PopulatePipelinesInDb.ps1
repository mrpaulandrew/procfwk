Param(
    [Parameter(Mandatory)]
    [string]$SqlServerName,
    [Parameter(Mandatory)]
    [string]$SqlDatabaseName,
    [Parameter(Mandatory)]
    [string]$SqlUser,
    [Parameter(Mandatory)]
    [string]$SqlPass,
    [Parameter(Mandatory)]
    [string]$resourceGroupName,
    [Parameter(Mandatory)]
    [string]$dataFactoryName,
    [Parameter(Mandatory)]
    [string]$region
)

$ErrorActionPreference = 'Stop'

#Install-Module -Name SqlServer -AllowClobber
Import-Module -Name SqlServer

$pipelines = Get-AzDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName 

foreach ($p in $pipelines) {
    Write-Host $p.name
    $query = "EXEC [procfwkHelpers].[AddPipelineViaPowerShell] '$resourceGroupName', '$dataFactoryName', '$($p.Name)';"
    Invoke-Sqlcmd -ServerInstance "$SqlServerName" -Database "$SqlDatabaseName" -Query "$query" -Username "$SqlUser" -Password "$SqlPass"
}

Write-Host "List of ADF pipelines has been populated into database."


