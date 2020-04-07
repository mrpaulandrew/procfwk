Install-Module -Name "Az.DataFactory"
Update-Module -Name "Az.DataFactory"
Import-Module -Name "Az.DataFactory"

# Set global variable as required:
$tenantId = ""
$subscriptionId = ""

$resourceGroupName = "ADF.procfwk"
$dataFactoryName = ""
$region = ""

#SPN for deploying ADF:
$spId = ""
$spKey = ""

# Login as a Service Principal
$passwd = ConvertTo-SecureString $spKey -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($spId, $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId | Out-Null

Get-AzDataFactoryV2Pipeline -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroupName 

