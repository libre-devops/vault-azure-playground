# Define your tenant ID, client ID, and client secret
$tenantId = $Env:ARM_TENANT_ID
$clientId = $Env:ARM_CLIENT_ID
$clientSecret = $Env:ARM_CLIENT_SECRET

# Define the resource (Microsoft Graph)
$resource = "https://graph.microsoft.com"

# Define the Azure AD authorization endpoint
$authUrl = "https://login.microsoftonline.com/$tenantId/oauth2/token"

# Define the body of the POST request
$body = @{
    "resource" = $resource
    "client_id" = $clientId
    "client_secret" = $clientSecret
    "grant_type" = "client_credentials"
}

# Execute the POST request to get the access token
$tokenResponse = Invoke-RestMethod -Method Post -Uri $authUrl -Body $body

# Extract the access token
$accessToken = $tokenResponse.access_token
echo $accessToken
