# Set global variables as required:
$resourceGroupName = "ADF.procfwk"
$dataFactoryName = "FrameworkFactoryDev"
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

# Login as a Service Principal
$passwd = ConvertTo-SecureString $spKey -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential($spId, $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId | Out-Null

# Get Deployment Objects and Params files
$scriptPath = "C:\Users\PaulAndrew\Source\GitHub\ADF.procfwk\DeploymentTools\DataFactory\"
#$deploymentFilePath = $scriptPath + "\ProcFwkComponents.json"
$deploymentFilePath = "C:\Users\PaulAndrew\Source\GitHub\ADF.procfwk\DeploymentTools\DataFactory\ProcFwkComponents.json"

#Write-Host $scriptPath

$deploymentObject = (Get-Content $deploymentFilePath) | ConvertFrom-Json 

<#
Create Data Factory
#>
Write-Host ""
Write-Host "-----------------------Data Factory-------------------------"

$check = Get-AzDataFactoryV2 `
    -ResourceGroupName $resourceGroupName `
    -DataFactoryName $dataFactoryName `
    -ErrorAction SilentlyContinue

if($check -eq $null)
    {
    Write-Host "Creating Data Factory:" $dataFactoryName
    
    try
        {
        Set-AzDataFactoryV2 `
            -ResourceGroupName $resourceGroupName `
            -DataFactoryName $dataFactoryName `
            -Location $region | Format-List | Out-Null

        Write-Host "...done" -ForegroundColor Green
        Write-Host ""
        }
    catch
        {
        Write-Host "Failed to created data factory:" $dataFactoryName -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
        Exit
        }
    }
else 
    {
    Write-Host "Data Factory $dataFactoryName already exists..."
    }

<#
Deploy Linked Services
#>
Write-Host ""
Write-Host "----------------------Linked Services-----------------------"

ForEach ($linkedService in $deploymentObject.linkedServices)
    {
    $componentPath = $scriptPath.Replace("DeploymentTools\","") + $linkedService   
    
    $linkedServiceFile = (Get-Content $componentPath) | ConvertFrom-Json
    $linkedServiceName = $linkedServiceFile.name
    Write-Host "Deploying Linked Service:" $linkedServiceName 

    try
        {
        Set-AzDataFactoryV2LinkedService `
            -ResourceGroupName $resourceGroupName `
            -DataFactoryName $dataFactoryName `
            -Name $linkedServiceName `
            -DefinitionFile $componentPath `
            -Force | Format-List | Out-Null

        Write-Host "...done" -ForegroundColor Green
        Write-Host ""
        }
    catch
        {
        Write-Host "Failed to deploy linked service:" $linkedServiceName -ForegroundColor Green
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
        Exit
        }
    }

<#
Deploy Datasets
#>
Write-Host ""
Write-Host "--------------------------Datasets--------------------------"

ForEach ($dataSet in $deploymentObject.datasets)
    {
    $componentPath = $scriptPath.Replace("DeploymentTools\","") + $dataSet  

    $datasetFile = (Get-Content $componentPath) | ConvertFrom-Json
    $datasetName = $datasetFile.name
    Write-Host "Deploying Dataset:" $datasetName
    
    try
        {
        Set-AzDataFactoryV2Dataset `
            -ResourceGroupName $resourceGroupName `
            -DataFactoryName $dataFactoryName `
            -Name $datasetName `
            -DefinitionFile $componentPath `
            -Force | Format-List | Out-Null

        Write-Host "...done" -ForegroundColor Green
        Write-Host ""
        }
    catch
        {
        Write-Host "Failed to deploy dataset:" $datasetName -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
        Exit
        }    
    }

<#
Deploy Pipelines
#>
Write-Host ""
Write-Host "-------------------------Pipelines--------------------------"

ForEach ($pipeline in $deploymentObject.pipelines)
    {
    $componentPath = $scriptPath.Replace("DeploymentTools\","") + $pipeline

    $pipelineFile = (Get-Content $componentPath) | ConvertFrom-Json
    $pipelineName = $pipelineFile.name
    Write-Host "Deploying Pipeline:" $pipelineName
    
    try
        {
        ##Bug in SDK means this native cmdlet can't be used if pipeline contains a Wait activity expression.
        <#
        Set-AzDataFactoryV2Pipeline `
            -ResourceGroupName $resourceGroupName `
            -DataFactoryName $dataFactoryName `
            -Name $pipelineName `
            -DefinitionFile $componentPath `
            -Force | Format-List | Out-Null
        #>
        $body = (Get-Content -Path $componentPath | Out-String)        
        $json = $body | ConvertFrom-Json

        New-AzResource `
            -ResourceType 'Microsoft.DataFactory/factories/pipelines' `
            -ResourceGroupName $resourceGroupName `
            -Name "$dataFactoryName/$pipelineName" `
            -ApiVersion "2018-06-01" `
            -Properties $json `
            -IsFullObject -Force | Out-Null

        Write-Host "...done" -ForegroundColor Green
        Write-Host ""
        }
    catch
        {
        Write-Host "Failed to deploy pipeline:" $pipelineName -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
        Exit
        }
    }


<#
Deploy Triggers
#>
Write-Host ""
Write-Host "-------------------------Triggers---------------------------"

ForEach ($trigger in $deploymentObject.triggers)
    {
    $componentPath = $scriptPath.Replace("DeploymentTools\","") + $trigger

    $triggerFile = (Get-Content $componentPath) | ConvertFrom-Json
    $triggerName = $triggerFile.name
    Write-Host "Deploying Trigger:" $triggerName
    
    $currentTrigger = Get-AzDataFactoryV2Trigger `
        -ResourceGroupName $resourceGroupName `
        -DataFactoryName $dataFactoryName `
        -Name $triggerName `
        -ErrorAction SilentlyContinue
    
    try
        {
        if($currentTrigger -ne $null)
            {
            #Stop trigger if already deployed as can't deploy over running trigger.                
            Stop-AzDataFactoryV2Trigger `
                -ResourceGroupName $resourceGroupName `
                -DataFactoryName $dataFactoryName `
                -Name $triggerName -Force | Out-Null
            }
            
        Set-AzDataFactoryV2Trigger `
            -ResourceGroupName $resourceGroupName `
            -DataFactoryName $dataFactoryName `
            -Name $triggerName `
            -DefinitionFile $componentPath `
            -Force | Format-List | Out-Null

        Write-Host "...done" -ForegroundColor Green
        Write-Host ""
        }
    catch
        {
        Write-Host "Failed to deploy trigger:" $triggerName -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
        Exit
        }
    }