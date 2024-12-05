New-AzResourceGroup -Name marketplacestore -Location australiaeast

$pkgstorageparms = @{
  ResourceGroupName = "marketplacestore"
  Name = "tulpymarketplacestore"
  Location = "australiaeast"
  SkuName = "Standard_LRS"
  Kind = "StorageV2"
  MinimumTlsVersion = "TLS1_2"
  AllowBlobPublicAccess = $true
  AllowSharedKeyAccess = $false
}

$pkgstorageaccount = New-AzStorageAccount @pkgstorageparms

