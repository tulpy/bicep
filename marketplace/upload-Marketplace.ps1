$pkgstoragecontext = New-AzStorageContext -StorageAccountName tulpymarketplacestore -UseConnectedAccount

New-AzStorageContainer -Name appcontainer1 -Context $pkgstoragecontext -Permission blob

$blobparms = @{
  File = "app.zip"
  Container = "appcontainer1"
  Blob = "app.zip"
  Context = $pkgstoragecontext
}

Set-AzStorageBlobContent @blobparms

$packageuri=(Get-AzStorageBlob -Container appcontainer1 -Blob app.zip -Context $pkgstoragecontext).ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri

$principalid=(Get-AzADGroup -DisplayName secOps).Id

$roleid=(Get-AzRoleDefinition -Name Owner).Id