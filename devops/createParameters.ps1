#Subscription
$tenantId = ""
$subscriptionId = ""

#Resource Group
$resourceGroupName = "rg-demo-web"
$resourceGroupLocation = "northeurope"

#$managedIdentityName = "MyDockerDemoIdentity"

#App Service Plan
$aspName = "dockerdemo-asp"
$aspSku = "P1V3" 
$aspIsWindows = $true

#Container Registry
$acrName = "mynewacr"
$acrSku = "Basic"

#WebApplication
$webImageName = "creportdemo"
$webImageTag = "latest"
$webAppResourceName = "mydockerdemo"
$fullImageName = "$acrName/$webImageName`:$webImageTag"