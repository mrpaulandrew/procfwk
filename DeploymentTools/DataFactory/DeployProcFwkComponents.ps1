function Publish-procfwkadf 
{
Param(
    [Parameter(Mandatory)]
    [string]$resourceGroupName,
    [Parameter(Mandatory)]
    [string]$dataFactoryName,
    [Parameter(Mandatory)]
    [string]$region,
    [Parameter(Mandatory)]
    [string]$adfPath,
    [Parameter(Mandatory)]
    [string]$scriptPath
)

#SPN for deploying ADF:
$tenantId = [System.Environment]::GetEnvironmentVariable('AZURE_TENANT_ID')
$subscriptionId = [System.Environment]::GetEnvironmentVariable('AZURE_SUBSCRIPTION_ID')
$spId = [System.Environment]::GetEnvironmentVariable('AZURE_CLIENT_ID')
$spKey = [System.Environment]::GetEnvironmentVariable('AZURE_CLIENT_SECRET')

#Modules
Import-Module -Name "Az"
#Update-Module -Name "Az"

Import-Module -Name "Az.DataFactory"
#Update-Module -Name "Az.DataFactory"

Import-Module -Name "azure.datafactory.tools"
#Update-Module -Name "azure.datafactory.tools"

Get-Module -Name "*DataFactory*"

# Login as a Service Principal
if ($spId) {
    $passwd = ConvertTo-SecureString $spKey -AsPlainText -Force
    $pscredential = New-Object System.Management.Automation.PSCredential($spId, $passwd)
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId | Out-Null
}
Get-AzContext

# Get Deployment Objects and Params files
$deploymentFilePath = Join-Path -Path $scriptPath -ChildPath "ProcFwkComponents.json"
$configFilePath = Join-Path -Path $scriptPath -ChildPath "config-all.csv"
$Env:SQLDatabase = "secretKeyToDbConnectionString"

$opt = New-AdfPublishOption
$deploymentObject = (Get-Content $deploymentFilePath) | ConvertFrom-Json 
$objectsToInclude = $deploymentObject.datasets + $deploymentObject.linkedServices + $deploymentObject.pipelines + $deploymentObject.triggers
$objectsToInclude | ForEach-Object { 
    $objName = $_.substring(1).Replace('.json', '').Replace('/', '.') 
    $opt.Includes.Add($objName, "")
}

# Deployment of ADF
$opt.CreateNewInstance = $true
$opt.DeleteNotInSource = $false
$opt.StopStartTriggers = $true
Publish-AdfV2FromJson -RootFolder $adfPath `
    -ResourceGroupName $resourceGroupName `
    -DataFactoryName $dataFactoryName `
    -Location $region `
    -Option $opt `
    -Stage $configFilePath

}


# Run function
$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path -Path (Get-Location) -ChildPath "\DeploymentTools\DataFactory"
$AdfPath = Join-Path -Path (Get-Location) -ChildPath "DataFactory"

Publish-procfwkadf  -resourceGroupName 'rg-pademo' -dataFactoryName 'adf-metadata-driven-proc' -region 'uksouth' `
    -adfPath "$AdfPath" -scriptPath "$scriptPath"



