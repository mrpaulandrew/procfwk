# Set global variables as required:
$resourceGroupName = "ADF.procfwk"
$dataFactoryName = "FrameworkFactory"
$region = "uksouth"

# ADF deployment from PS script
.\DeploymentTools\DataFactory\DeployProcFwkComponents.ps1 `
    -resourceGroupName "$resourceGroupName" `
    -dataFactoryName "$dataFactoryName" `
    -region "$region"


.\DeploymentTools\DataFactory\PopulatePipelinesInDb.ps1 `
    -SqlServerName '*****.database.windows.net' `
    -SqlDatabaseName 'adfprocfwk' `
    -SqlUser 'adm' `
    -SqlPass '******' `
    -resourceGroupName "$resourceGroupName" `
    -dataFactoryName "$dataFactoryName" `
    -region "$region"

