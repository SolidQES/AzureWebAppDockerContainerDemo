. ".\createParameters.ps1"
az login
az account set --subscription $subscriptionId

#Check if group already exists and create it 
$groupExits = az group exists --name $resourceGroupName
if($groupExits -eq $true)
{
    Write-Host "$resourceGroupName already exists" -ForegroundColor Green
}else{
    Write-Host "Creating $resourceGroupName" -ForegroundColor Yellow
    az group create --name $resourceGroupName --location $resourceGroupLocation --subscription $subscriptionId
    Write-Host "Create group operation completed" -ForegroundColor Green
}

#Check if Azure Service Plan exists
$currentAsp = az appservice plan show --resource-group $resourceGroupName --subscription $subscriptionId  --name $aspName
if($currentAsp -eq $null)
{

    Write-Host "Creating Azure Service Plan $aspName in $resourceGroupName"
    if($aspIsWindows  -eq $true)
    {
        az appservice plan create --name $aspName --sku $aspSku --location $resourceGroupLocation --resource-group $resourceGroupName --hyper-v
    }else{
        az appservice plan create --name $aspName --sku $aspSku --location $resourceGroupLocation --resource-group $resourceGroupName --is-linux
    }
    
}
else 
{
    if($currentAsp.sku.Tier -Like "Premium*")
    {
        throw "$aspName cannot run container web apps"
    }else
    {
        Write-Host "$aspName already exits and can run container web apps"
    }

}

#Creating and login in Azure Container Registry
$acr = az acr show --name $acrName | ConvertFrom-Json
if($acr -eq $null )
{
    az acr create --name $acrName --resource-group $resourceGroupName --sku $acrSku --admin-enabled true
    $acr = az acr show --name $acrName | ConvertFrom-Json
}
else
{
    Write-Host "Already exists $acrName.azurecr.io"
}

$acrCredentials = az acr credential show --resource-group $resourceGroupName --name $acrName | ConvertFrom-Json
$acrPassword = $acrCredentials.passwords[0].value
$acrUserName = $acrCredentials.username

$acrPassword  | docker login "$acrName.azurecr.io" --username $acrUserName --password-stdin



#Create an identity to manage permissions 
#$azIdentity = az identity show --name $managedIdentityName --resource-group $resourceGroupName | ConvertFrom-Json
#if($azIdentity -eq $null)
#{
#    az identity create --name $managedIdentityName --resource-group $resourceGroupName      
#    $azIdentity = az identity show --name $managedIdentityName --resource-group $resourceGroupName | ConvertFrom-Json
#}

#$rg = az group show --name $resourceGroupName | ConvertFrom-Json


#az role assignment create --role "Contributor" --assignee $azIdentity.clientId --scope $rg.id
#az acr identity assign --identities $managedIdentityName  --name $acrName
#az role assignment create --role "AcrPull" --assignee $azIdentity.clientId --scope $acr.id


#Create a new WebApp if not exists

$acrSecurePassword = $acrPassword | ConvertTo-SecureString -AsPlainText -Force


if($aspIsWindows)
{
    #Powershell Az Module requires auth.
    Connect-AzAccount

    $winFxVersion = "DOCKER|$acrName.azurecr.io/$webImageName`:$webImageTag"
    $dockerRegistryUrl =  "https:`\\$acrName.azurecr.io"

    New-AzResourceGroupDeployment  -ResourceGroupName $resourceGroupName -TemplateFile crystalreportwebapp\template.json `
    -subscriptionId "$subscriptionId" `
    -name "DeployContainerAsWebApp" `
    -nameFromTemplate "$webAppResourceName" `
    -location "$resourceGroupLocation" `
    -hostingPlanName "$aspName" `
    -serverFarmResourceGroup "$resourceGroupName" `
    -alwaysOn $true `
    -windowsFxVersion "$winFxVersion" `
    -dockerRegistryUrl $dockerRegistryUrl `
    -dockerRegistryUsername "$acrUserName" `
    -dockerRegistryPassword $acrSecurePassword 


}else {
    az webapp create --resource-group $resourceGroupName --plan $aspName --name $webAppResourceName -i "$acrName.azurecr.io/$webImageName`:$webImageTag" --assign-identity $azIdentity.clientId  
}

