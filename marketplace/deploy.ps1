New-AzResourceGroup -Name bicepDefinitionGroup -Location westus

$deployparms = @{
  ResourceGroupName = "marketplacestore"
  TemplateFile = "deployDefinition.bicep"
  TemplateParameterFile = "deployDefinition-parameters.bicepparam"
  Name = "deployDefinition"
}

New-AzResourceGroupDeployment @deployparms