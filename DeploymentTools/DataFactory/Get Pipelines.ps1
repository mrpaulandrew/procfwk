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
Import-Module -Name "Az.DataFactory"

# Login as a Service Principal
$passwd = ConvertTo-SecureString $spKey -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($spId, $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId | Out-Null

Get-AzDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName 

