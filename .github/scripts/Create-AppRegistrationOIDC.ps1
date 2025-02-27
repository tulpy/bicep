[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $true)]
  [string]$workloadShortName,

  [Parameter(Mandatory = $true)]
  [string]$applicationRegistrationName,

  [Parameter(Mandatory = $true)]
  [string]$gitHubOrganisation,

  [Parameter(Mandatory = $true)]
  [string]$gitHubRepoName
)

Install-Module Microsoft.Graph -Force -verbose
Get-Module Microsoft.Graph
Import-Module Microsoft.Graph -Force

$AccessToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com" -AsSecureString).Token
(Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token
$sec = ConvertTo-SecureString $AccessToken -AsPlainText -Force

Connect-MgGraph -AccessToken $sec -NoWelcome
Import-Module Microsoft.Graph.Applications

$myApp = Get-MgApplication -Filter "DisplayName eq '$applicationRegistrationName'" -ErrorAction SilentlyContinue        
if ($myApp) {
  Write-Output "Application Registration $applicationRegistrationName already exists. Skipping creation..."
}
else {
  $myApp = New-MgApplication -DisplayName "$applicationRegistrationName"
  Write-Output "Application Registration $applicationRegistrationName created successfully."
}
$myApp

start-sleep -Seconds 300
$subscriptionId = (Get-AzContext).Subscription.Id
$tenantId = (Get-AzContext).Subscription.TenantId
$gitBranch = "main"
$gitFederationName = "fed-credentials-$($workloadShortName)"
$clientId = $myApp.id
$policy = "repo:$gitHubOrganisation/$($githubRepoName):ref:refs/heads/$gitBranch"
$creds = get-MgApplicationFederatedIdentityCredential -ApplicationId $myApp.id | where-object { $_.Subject -eq $policy }

if ($creds) {
  Write-Output "Policy details $policy already exists. Skipping creation..."
}
else {
  $federatedApp = New-MgApplicationFederatedIdentityCredential -ApplicationId $clientId `
    -Audiences api://AzureADTokenExchange -Issuer "https://token.actions.githubusercontent.com" -Name $gitFederationName -Subject $policy
}
Write-Output "devObjectId=$myApp.ObjectId" >> $env:GITHUB_ENV