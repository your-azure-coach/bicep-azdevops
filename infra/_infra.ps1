param(
    [string]$environment = "dev"
)

#region Global Functions

function Write-Info {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Key,
    
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    )
    
    $Time = (Get-Date -f "yyyy-MM-dd HH:mm:ss")
    $Log = "$Time : -$Key : $Value"
    Write-Host $Log -ForegroundColor "Gray"
}

function Write-Action {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Value
    )
    
    $Time = (Get-Date -f "yyyy-MM-dd HH:mm:ss")
    $Log = "##[debug] $Time : -$Value..."
    Write-Host $Log -ForegroundColor "Cyan"
}

function Write-Progress {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
    
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Started','Completed')]
        [string]$Status
    )

    $Time = (Get-Date -f "yyyy-MM-dd HH:mm:ss")
    $Log = "$Time : $Message"
    
    Switch ($Status)
    {
        "Started" { 
            Write-Host "##[group]$Log" -ForegroundColor "Green"
        }
        "Completed"   { 
            Write-Host "##[endgroup]" -ForegroundColor "Green"
        }
    }
}

#endregion

#region Configure execution environment
Write-Progress -Message "Configure execution environment" -Status "Started"

    Write-Action -Value "Configure error handling settings"
    $ErrorActionPreference = "Stop"
    $ExceptionMessage = "Error during deployment.  Check the logs for more details."

    Write-Action -Value "Promote Bicep input parameters as environment variables"
    Write-Info -Key "Parameter file" -Value ($parametersFilePath = "infra.parameters.$environment.json")
    $parameters = Get-Content -Raw -Path "$parametersFilePath" | ConvertFrom-Json
    foreach($parameter in $parameters.parameters.PSObject.Properties)
    {
        Set-Item -Path ("Env:{0}" -f $parameter.name) -Value $parameter.value.value
        Write-Info -Key "Parameter >> $($parameter.name)" -Value $parameter.value.value
    }

    Write-Action -Value "Retrieve release info"
    Write-Info -Key "Release Id" -Value ($releaseId = [guid]::NewGuid().Guid)
    if (Test-Path 'env:Agent_Id')
    {
        Write-Info -Key "Environment" -Value "Azure DevOps Pipelines"
        Write-Info -Key "Release Url" -Value ($releaseUrl = "$($env:SYSTEM_COLLECTIONURI)$($env:SYSTEM_TEAMPROJECT)/_build/results?buildId=$($env:BUILD_BUILDID)&view=results")

    }
    elseif (Test-Path 'env:GITHUB_ACTION') {
        Write-Info -Key "Environment" -Value "GitHub Actions"
        Write-Info -Key "Release Url" -Value ($releaseUrl = "$env:GITHUB_SERVER_URL/$env:GITHUB_REPOSITORY/actions/runs/$env:GITHUB_RUN_ID")
    }
    else {
        Write-Info -Key "Environment" -Value "Local execution"
        Write-Info -Key "Release Url" -Value ($releaseUrl = "None")
    }

Write-Progress -Status "Completed"
#endregion

#region Pre-deployment scripts
Write-Progress -Message "Excecute pre-deployment scripts" -Status "Started"

    Write-Action -Value "No scripts to execute"

Write-Progress -Status "Completed"
#endregion

#region Deploy infra with Bicep file
Write-Progress -Message "Deploy infrastructure with Bicep" -Status "Started"

    Write-Action -Value "Validate Bicep deployment"
    if(!($whatIfResult = az deployment sub what-if  `
        --name "infra-$environment-$releaseId" `
        --template-file infra.bicep `
        --parameters "infra.parameters.$environment.json" `
        --parameters releaseUrl=$releaseUrl `
        --parameters releaseId=$releaseId `
        --location "$env:location" `
        --no-pretty-print `
        --only-show-errors)){ Write-Error "$ExceptionMessage" }

    Write-Action -Value "Deploy Bicep file to subscription"
    if(!($deploymentResult = az deployment sub create  `
        --name "infra-$environment-$releaseId" `
        --template-file infra.bicep `
        --parameters "infra.parameters.$environment.json" `
        --parameters releaseUrl=$releaseUrl `
        --parameters releaseId=$releaseId `
        --location "$env:location" `
        --only-show-errors)){ Write-Error "$ExceptionMessage" }
    $result = $deploymentResult | ConvertFrom-Json
    Write-Info -Key "Status" -Value $result.properties.provisioningState

    Write-Action -Value "Promote Bicep outputs as environment variables"
    foreach ($output in $result.properties.outputs.PSObject.Properties)
    {
        Set-Item -Path ("Env:{0}" -f $output.name) -Value $output.value.value
        Write-Info -Key "Output >> $($output.name)" -Value $output.value.value
    }
    
Write-Progress -Status "Completed"
#endregion

#region Pre-deployment scripts
Write-Progress -Message "Excecute post-deployment scripts" -Status "Started"

    Write-Action -Value "Restart App Service to refresh Key Vault references (example)"
    az webapp restart --name $env:appServiceName --resource-group $env:resourceGroupName

Write-Progress -Status "Completed"
#endregion