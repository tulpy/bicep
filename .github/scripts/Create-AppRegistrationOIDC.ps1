            # Install-Module Microsoft.Graph -Force -verbose
            # Get-Module Microsoft.Graph
            # Import-Module Microsoft.Graph -Force
            $AccessToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com" -AsSecureString).Token
            (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token
            $sec = ConvertTo-SecureString $AccessToken -AsPlainText -Force
            Connect-MgGraph -AccessToken $sec -NoWelcome
            Import-Module Microsoft.Graph.Applications
            $appName = "${{ env.spnDevName }}"
            $myApp = Get-MgApplication -Filter "DisplayName eq '$appName'" -ErrorAction SilentlyContinue        
            if ($myApp) {
                Write-Output "Application Registration $appName already exists. Skipping creation..."
            } else {
                $myApp = New-MgApplication -DisplayName "$appName"
                Write-Output "Application Registration $appName created successfully."
            }
            $myApp 
            start-sleep -Seconds 300
            $subscriptionId = (Get-AzContext).Subscription.Id
            $tenantId = (Get-AzContext).Subscription.TenantId
            $githubOrganisation = "tulpy"
            $githubRepo = "${{ inputs.gitHubRepoName}}"
            $gitBranch = "main"
            $gitFederationName = "fed-credentials-${{ env.workloadShortName }}"
            $clientId = $myApp.id
            $policy = "repo:$githubOrganisation/$($githubRepo):ref:refs/heads/$gitBranch"
            $creds = get-MgApplicationFederatedIdentityCredential -ApplicationId $myApp.id | where-object {$_.Subject -eq $policy}
            if($creds){
              Write-Output "Policy details $policy already exists. Skipping creation..."
            } else {
              $federatedApp = New-MgApplicationFederatedIdentityCredential -ApplicationId $clientId `
              -Audiences api://AzureADTokenExchange -Issuer "https://token.actions.githubusercontent.com" -Name $gitFederationName -Subject $policy
            }
            echo "devObjectId=$myApp.ObjectId" >> $env:GITHUB_ENV