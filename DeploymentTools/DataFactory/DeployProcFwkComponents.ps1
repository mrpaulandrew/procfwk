# Set global variables as required:
$resourceGroupName = "ADF.procfwk"
$dataFactoryName = "FrameworkFactory"
$region = "uksouth"

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
$passwd = ConvertTo-SecureString $spKey -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($spId, $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId | Out-Null

#$VerbosePreference = 'Continue'
$ErrorActionPreference = 'Stop'

# Get Deployment Objects and Params files
$scriptPath = Join-Path -Path (Get-Location) -ChildPath "\DeploymentTools\DataFactory"
$deploymentFilePath = Join-Path -Path $scriptPath -ChildPath "\ProcFwkComponents.json"

$opt = New-AdfPublishOption
$deploymentObject = (Get-Content $deploymentFilePath) | ConvertFrom-Json 
$objectsToInclude = $deploymentObject.datasets + $deploymentObject.linkedServices + $deploymentObject.pipelines + $deploymentObject.triggers
$objectsToInclude | ForEach-Object { 
    $objName = $_.substring(1).Replace('.json', '').Replace('/', '.') 
    $opt.Includes.Add($objName, "")
}

# Deployment of ADF
$AdfPath = Join-Path -Path (Get-Location) -ChildPath "DataFactory"
$opt.CreateNewInstance = $true
$opt.DeleteNotInSource = $false
$opt.StopStartTriggers = $true
Publish-AdfV2FromJson -RootFolder $AdfPath `
    -ResourceGroupName $resourceGroupName `
    -DataFactoryName $dataFactoryName `
    -Location $region `
    -Option $opt `
    -Stage "all"


