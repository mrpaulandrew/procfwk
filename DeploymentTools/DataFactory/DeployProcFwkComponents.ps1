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

# Get Deployment Objects and Params files
$scriptPath = (Get-Item -Path ".\").FullName #+ "\DeploymentTools\DataFactory\"
$deploymentFilePath = $scriptPath + "\ProcFwkComponents.json"

Write-Host $scriptPath

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
        Set-AzDataFactoryV2Pipeline `
            -ResourceGroupName $resourceGroupName `
            -DataFactoryName $dataFactoryName `
            -Name $pipelineName `
            -DefinitionFile $componentPath `
            -Force | Format-List | Out-Null

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