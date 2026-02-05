@export()
var locPrefixes = {
  australiacentral: 'auc'
  australiacentral2: 'auc2'
  australiaeast: 'aue'
  australiasoutheast: 'ause'
  brazilsouth: 'brs'
  brazilsoutheast: 'brse'
  canadacentral: 'canc'
  canadaeast: 'cane'
  centralindia: 'cin'
  centralus: 'cus'
  centraluseuap: 'cuseuap'
  eastasia: 'ea'
  eastus: 'eus'
  eastus2: 'eus2'
  eastus2euap: 'eus2euap'
  francecentral: 'frc'
  francesouth: 'frs'
  germanynorth: 'gern'
  germanywestcentral: 'gerwc'
  japaneast: 'jae'
  japanwest: 'jaw'
  jioindiacentral: 'jioinc'
  jioindiawest: 'jioinw'
  koreacentral: 'koc'
  koreasouth: 'kors'
  northcentralus: 'ncus'
  northeurope: 'neu'
  norwayeast: 'nore'
  norwaywest: 'norw'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  southeastasia: 'sea'
  southindia: 'sin'
  swedencentral: 'swc'
  switzerlandnorth: 'swn'
  switzerlandwest: 'sww'
  uaecentral: 'uaec'
  uaenorth: 'uaen'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'weu'
  westindia: 'win'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
}

@export()
var delimiter = {
  dash: '-'
  none: ''
}

@export()
var resPrefixes = {
  azureAutomation: 'aa'
  azureBastion: 'bas'
  azureDdos: 'ddos'
  azureFirewall: 'afw'
  azureFirewallPolicy: 'afp'
  azureMonitor: 'amo'
  azureSQL: 'sql'
  azureVwan: 'vwan'
  azureVwanHub: 'vhub'
  containerInstance: 'aci'
  containerRegistry: 'acr'
  connection: 'conx'
  dataCollectionRule: 'dcr'
  datafactory: 'adf'
  databricks: 'dbw'
  eventHub: 'ehn'
  github: 'gh'
  grafana: 'grf'
  intLoadBalancer: 'ilb'
  keyVault: 'kv'
  localNetworkGateway: 'lng'
  logAnalytics: 'log'
  mySQL: 'mysql'
  networkSecurityGroup: 'nsg'
  platform: 'plat'
  platformConn: 'conn'
  platformIdam: 'idam'
  platformMgmt: 'mgmt'
  privateDnsResolver: 'dns'
  privateEndpoint: 'pe'
  publicIp: 'pip'
  recoveryVault: 'rsv'
  resourceGroup: 'arg'
  routeTable: 'udr'
  shir: 'shir'
  storage: 'sta'
  synapse: 'syn'
  updateManagement: 'um'
  userAssignedIdentity: 'uai'
  virtualNetwork: 'vnet'
  virtualNetworkGateway: 'vng'
}

@export()
var commonResourceGroupNames = [
  'alertsRG'
  'ascExportRG'
  'networkWatcherRG'
]

@export()
var sharedNSGrulesInbound = [
  {
    name: 'INBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-any-PROT-Icmp-ALLOW'
    properties: {
      protocol: 'Icmp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: 'VirtualNetwork'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1000
      direction: 'Inbound'
      description: 'Shared - Allow Inbound ICMP traffic (Port *) from the subnet.'
    }
  }
  {
    name: 'INBOUND-FROM-azureBastion-TO-subnet-PORT-22-3389-PROT-Tcp-ALLOW'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: ''
      destinationPortRanges: [
        '22'
        '3389'
      ]
      sourceAddressPrefix: '10.4.0.0/26'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: '*'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1001
      direction: 'Inbound'
      description: 'Shared - Allow Inbound SSH and Bastion Management traffic (Port 22 & 3389) to the subnet.'
    }
  }
  {
    name: 'INBOUND-FROM-any-TO-any-PORT-any-PROT-any-DENY'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: '*'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: '*'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Deny'
      priority: 4096
      direction: 'Inbound'
      description: 'Shared - Deny Inbound traffic (Port *) from the subnet.'
    }
  }
]

@export()
var sharedNSGrulesOutbound = [
  {
    name: 'OUTBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-any-PROT-Icmp-ALLOW'
    properties: {
      protocol: 'Icmp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: 'VirtualNetwork'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1000
      direction: 'Outbound'
      description: 'Shared - Allow Outbound ICMP traffic (Port *) from the subnet.'
    }
  }
  {
    name: 'OUTBOUND-FROM-subnet-TO-virtualNetwork-PORT-22-3389-PROT-Tcp-DENY'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: ''
      destinationPortRanges: [
        '22'
        '3389'
      ]
      sourceAddressPrefix: 'VirtualNetwork'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: '*'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Deny'
      priority: 1001
      direction: 'Outbound'
      description: 'Shared - Deny Outbound SSH and Management traffic (Port 22 & 3389) from the subnet.'
    }
  }
  {
    name: 'OUTBOUND-FROM-subnet-TO-any-PORT-443-PROT-Tcp-ALLOW'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '443'
      destinationPortRanges: []
      sourceAddressPrefix: '*'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: '*'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1150
      direction: 'Outbound'
      description: 'Shared - Allow Outbound HTTPS traffic (Port 443) from the subnet.'
    }
  }
  {
    name: 'OUTBOUND-FROM-subnet-TO-kms-PORT-1688-PROT-Tcp-ALLOW'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: ''
      destinationPortRanges: [
        '1688'
      ]
      sourceAddressPrefix: '*'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: ''
      destinationAddressPrefixes: [
        '20.118.99.224/32'
        '40.83.235.53/32'
      ]
      destinationApplicationSecurityGroupIds: []
      access: 'Allow'
      priority: 1200
      direction: 'Outbound'
      description: 'Shared - Allow Outbound KMS traffic (Port 1688) from the subnet.'
    }
  }
  {
    name: 'OUTBOUND-FROM-any-TO-any-PORT-any-PROT-any-DENY'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourcePortRanges: []
      destinationPortRange: '*'
      destinationPortRanges: []
      sourceAddressPrefix: '*'
      sourceAddressPrefixes: []
      sourceApplicationSecurityGroupIds: []
      destinationAddressPrefix: '*'
      destinationAddressPrefixes: []
      destinationApplicationSecurityGroupIds: []
      access: 'Deny'
      priority: 4096
      direction: 'Outbound'
      description: 'Shared - Deny Outbound traffic (Port *) from the subnet.'
    }
  }
]

@export()
var sharedRoutes = [
  {
    name: 'FROM-subnet-TO-default-0.0.0.0-0'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.4.0.68'
    }
  }
]
