Always use the hungarian notation prefix for the following items:

- Parameters: Prefix with par. For example, parLocation.
- Variables: Prefix with var. For example, varStorageAccountName.
- Resources: Prefix with res. For example, resStorageAccount.
- Modules: Prefix with mod. For example, modStorageAccount.
- Outputs: Prefix with out. For example, outStorageAccountName.
- User-Defined Functions: Prefix with func. For example, funcMyFunctionHere.
- User-Defined Types: Prefix with type. For example, typeMyTypeHere.

When using the existing keyword to refer to resources, append `Ref` to the symbolic name of each resource. For instance, if referencing an existing storage account, use the format `resExistingStorageAccountRef`.

If a parameter name includes ‘password,’ ‘admin,’ or ‘key,’ apply the @secure decorator to ensure secure handling. For example, use `@secure` with parameters like adminPassword or apiKey.

Always add a description decorator `@description` on parameters and outputs to describe the purpose. If the parameter is required, start the description with `Required.` and when the parameter is optional or nullable start with `Optional.`.

Begin module names with the format deploy-resource-type-${resource-type-name}. For example, in a Key Vault deployment:

```bicep
@description('Required. The name of the Key Vault.')
param parKeyVaultName string

module modKeyVault 'br/public:avm/res/key-vault/vault:0.9.0' = {
  name: 'deploy-key-vault-${parKeyVaultName}'
  params: {
    name: parKeyVaultName
    location: parLocation
  }
}
```

Azure Verified Modules always have the name and location as required parameters. Always pass the name and location as parameters to the module:

```bicep
module modSymbolicName 'br/public:avm/res/_type_/_resource_:_version_' = {
  name: 'storageAccount'
  params: {
    name: parName
    location: parLocation
  }
}
```

Select one of the Azure Verified Modules listed below and reference it as a template to build the module in the Bicep file.

Azure Active Directory: br/public:avm/res/aad:_version_
Alerts Management: br/public:avm/res/alerts-management:_version_
Analysis Services: br/public:avm/res/analysis-services:_version_
API Management: br/public:avm/res/api-management:_version_
App Service: br/public:avm/res/app:_version_
App Configuration: br/public:avm/res/app-configuration:_version_
Automation: br/public:avm/res/automation:_version_
Batch: br/public:avm/res/batch:_version_
Cache: br/public:avm/res/cache:_version_
Content Delivery Network (CDN): br/public:avm/res/cdn:_version_
Cognitive Services: br/public:avm/res/cognitive-services:_version_
Communication Services: br/public:avm/res/communication:_version_
Compute: br/public:avm/res/compute:_version_
Consumption: br/public:avm/res/consumption:_version_
Container Instances: br/public:avm/res/container-instance:_version_
Container Registry: br/public:avm/res/container-registry:_version_
Container Service: br/public:avm/res/container-service:_version_
Data Factory: br/public:avm/res/data-factory:_version_
Data Protection: br/public:avm/res/data-protection:_version_
Databricks: br/public:avm/res/databricks:_version_
Database for MySQL: br/public:avm/res/db-for-my-sql:_version_
Database for PostgreSQL: br/public:avm/res/db-for-postgre-sql:_version_
Desktop Virtualization: br/public:avm/res/desktop-virtualization:_version_
DevOps Infrastructure: br/public:avm/res/dev-ops-infrastructure:_version_
DevTest Labs: br/public:avm/res/dev-test-lab:_version_
Digital Twins: br/public:avm/res/digital-twins:_version_
Cosmos DB: br/public:avm/res/document-db:_version_
Event Grid: br/public:avm/res/event-grid:_version_
Event Hub: br/public:avm/res/event-hub:_version_
Azure Service Fabric: br/public:avm/res/fabric:_version_
Health Bot: br/public:avm/res/health-bot:_version_
Healthcare APIs: br/public:avm/res/healthcare-apis:_version_
Hybrid Compute: br/public:avm/res/hybrid-compute:_version_
Azure Monitor: br/public:avm/res/insights:_version_
Key Vault: br/public:avm/res/key-vault:_version_
Kubernetes Configuration: br/public:avm/res/kubernetes-configuration:_version_
Azure Data Explorer (Kusto): br/public:avm/res/kusto:_version_
Load Testing: br/public:avm/res/load-test-service:_version_
Logic Apps: br/public:avm/res/logic:_version_
Machine Learning Services: br/public:avm/res/machine-learning-services:_version_
Maintenance: br/public:avm/res/maintenance:_version_
Managed Identity: br/public:avm/res/managed-identity:_version_
Managed Services: br/public:avm/res/managed-services:_version_
Management: br/public:avm/res/management:_version_
NetApp: br/public:avm/res/net-app:_version_
Networking: br/public:avm/res/network:_version_
Operational Insights: br/public:avm/res/operational-insights:_version_
Operations Management: br/public:avm/res/operations-management:_version_
Azure Portal: br/public:avm/res/portal:_version_
Power BI Dedicated: br/public:avm/res/power-bi-dedicated:_version_
Purview: br/public:avm/res/purview:_version_
Recovery Services: br/public:avm/res/recovery-services:_version_
Relay: br/public:avm/res/relay:_version_
Resource Graph: br/public:avm/res/resource-graph:_version_
Resources: br/public:avm/res/resources:_version_
Azure Cognitive Search: br/public:avm/res/search:_version_
Service Bus: br/public:avm/res/service-bus:_version_
Service Fabric: br/public:avm/res/service-fabric:_version_
Service Networking: br/public:avm/res/service-networking:_version_
SignalR Service: br/public:avm/res/signal-r-service:_version_
SQL Database: br/public:avm/res/sql:_version_
Storage: br/public:avm/res/storage:_version_
Azure Synapse Analytics: br/public:avm/res/synapse:_version_
Virtual Machine Images: br/public:avm/res/virtual-machine-images:_version_
Web Apps: br/public:avm/res/web:_version_
Azure Data Explorer (Kusto) Cluster: br/public:avm/res/kusto/cluster:_version_
Azure Monitor Action Group: br/public:avm/res/insights/action-group:_version_
Azure Monitor Activity Log Alert: br/public:avm/res/insights/activity-log-alert:_version_
Azure Monitor Application Insights: br/public:avm/res/insights/component:_version_
Azure Monitor Data Collection Endpoint: br/public:avm/res/insights/data-collection-endpoint:_version_
Azure Monitor Data Collection Rule: br/public:avm/res/insights/data-collection-rule:_version_
Azure Monitor Diagnostic Setting: br/public:avm/res/insights/diagnostic-setting:_version_
Azure Monitor Metric Alert: br/public:avm/res/insights/metric-alert:_version_
Azure Monitor Private Link Scope: br/public:avm/res/insights/private-link-scope:_version_
Azure Monitor Scheduled Query Rule: br/public:avm/res/insights/scheduled-query-rule:_version_
Azure Monitor Web Test: br/public:avm/res/insights/webtest:_version_
Managed Identity User Assigned Identity: br/public:avm/res/managed-identity/user-assigned-identity:_version_
Event Grid Domain: br/public:avm/res/event-grid/domain:_version_
Event Grid Namespace: br/public:avm/res/event-grid/namespace:_version_
Event Grid System Topic: br/public:avm/res/event-grid/system-topic:_version_
Event Grid Topic: br/public:avm/res/event-grid/topic:_version_
NetApp Account: br/public:avm/res/net-app/net-app-account:_version_
Health Bot Service: br/public:avm/res/health-bot/health-bot:_version_
Azure Active Directory Domain Services: br/public:avm/res/aad/domain-service:_version_
Azure Portal Dashboard: br/public:avm/res/portal/dashboard:_version_
Machine Learning Workspace: br/public:avm/res/machine-learning-services/workspace:_version_
Container Apps: br/public:avm/res/app/container-app:_version_
App Service Jobs: br/public:avm/res/app/job:_version_
App Service Managed Environment: br/public:avm/res/app/managed-environment:_version_
Azure Cache for Redis: br/public:avm/res/cache/redis:_version_
Analysis Services Server: br/public:avm/res/analysis-services/server:_version_
Key Vault Vault: br/public:avm/res/key-vault/vault:_version_
Cosmos DB Database Account: br/public:avm/res/document-db/database-account:_version_
Cosmos DB Mongo Cluster: br/public:avm/res/document-db/mongo-cluster:_version_
Web App Connection: br/public:avm/res/web/connection:_version_
Web App Hosting Environment: br/public:avm/res/web/hosting-environment:_version_
Web App Server Farm: br/public:avm/res/web/serverfarm:_version_
Web App Site: br/public:avm/res/web/site:_version_
Web App Static Site: br/public:avm/res/web/static-site:_version_
Consumption Budget: br/public:avm/res/consumption/budget:_version_
DevOps Infrastructure Pool: br/public:avm/res/dev-ops-infrastructure/pool:_version_
Alerts Management Action Rule: br/public:avm/res/alerts-management/action-rule:_version_
Resource Deployment Script: br/public:avm/res/resources/deployment-script:_version_
Resource Group: br/public:avm/res/resources/resource-group:_version_
Application Gateway: br/public:avm/res/network/application-gateway:_version_
Application Gateway Web Application Firewall Policy: br/public:avm/res/network/application-gateway-web-application-firewall-policy:_version_
Application Security Group: br/public:avm/res/network/application-security-group:_version_
Azure Firewall: br/public:avm/res/network/azure-firewall:_version_
Bastion Host: br/public:avm/res/network/bastion-host:_version_
Network Connection: br/public:avm/res/network/connection:_version_
DDoS Protection Plan: br/public:avm/res/network/ddos-protection-plan:_version_
DNS Forwarding Ruleset: br/public:avm/res/network/dns-forwarding-ruleset:_version_
DNS Resolver: br/public:avm/res/network/dns-resolver:_version_
DNS Zone: br/public:avm/res/network/dns-zone:_version_
ExpressRoute Circuit: br/public:avm/res/network/express-route-circuit:_version_
ExpressRoute Gateway: br/public:avm/res/network/express-route-gateway:_version_
Firewall Policy: br/public:avm/res/network/firewall-policy:_version_
Front Door: br/public:avm/res/network/front-door:_version_
Front Door Web Application Firewall Policy: br/public:avm/res/network/front-door-web-application-firewall-policy:_version_
IP Group: br/public:avm/res/network/ip-group:_version_
Load Balancer: br/public:avm/res/network/load-balancer:_version_
Local Network Gateway: br/public:avm/res/network/local-network-gateway:_version_
NAT Gateway: br/public:avm/res/network/nat-gateway:_version_
Network Interface: br/public:avm/res/network/network-interface:_version_
Network Manager: br/public:avm/res/network/network-manager:_version_
Network Security Group: br/public:avm/res/network/network-security-group:_version_
Network Watcher: br/public:avm/res/network/network-watcher:_version_
Private DNS Zone: br/public:avm/res/network/private-dns-zone:_version_
Private Endpoint: br/public:avm/res/network/private-endpoint:_version_
Private Link Service: br/public:avm/res/network/private-link-service:_version_
Public IP Address: br/public:avm/res/network/public-ip-address:_version_
Public IP Prefix: br/public:avm/res/network/public-ip-prefix:_version_
Route Table: br/public:avm/res/network/route-table:_version_
Service Endpoint Policy: br/public:avm/res/network/service-endpoint-policy:_version_
Traffic Manager Profile: br/public:avm/res/network/trafficmanagerprofile:_version_
Virtual Hub: br/public:avm/res/network/virtual-hub:_version_
Virtual Network: br/public:avm/res/network/virtual-network:_version_
Virtual Network Gateway: br/public:avm/res/network/virtual-network-gateway:_version_
Virtual WAN: br/public:avm/res/network/virtual-wan:_version_
VPN Gateway: br/public:avm/res/network/vpn-gateway:_version_
VPN Server Configuration: br/public:avm/res/network/vpn-server-configuration:_version_
VPN Site: br/public:avm/res/network/vpn-site:_version_
Databricks Access Connector: br/public:avm/res/databricks/access-connector:_version_
Databricks Workspace: br/public:avm/res/databricks/workspace:_version_
Database for PostgreSQL Flexible Server: br/public:avm/res/db-for-postgre-sql/flexible-server:_version_
Logic Apps Workflow: br/public:avm/res/logic/workflow:_version_
Management Group: br/public:avm/res/management/management-group:_version_
Event Hub Namespace: br/public:avm/res/event-hub/namespace:_version_
API Management Service: br/public:avm/res/api-management/service:_version_
Resource Graph Query: br/public:avm/res/resource-graph/query:_version_
Desktop Virtualization Application Group: br/public:avm/res/desktop-virtualization/application-group:_version_
Desktop Virtualization Host Pool: br/public:avm/res/desktop-virtualization/host-pool:_version_
Desktop Virtualization Scaling Plan: br/public:avm/res/desktop-virtualization/scaling-plan:_version_
Desktop Virtualization Workspace: br/public:avm/res/desktop-virtualization/workspace:_version_
Storage Account: br/public:avm/res/storage/storage-account:_version_
Azure Cognitive Search Service: br/public:avm/res/search/search-service:_version_
Hybrid Compute Machine: br/public:avm/res/hybrid-compute/machine:_version_
Recovery Services Vault: br/public:avm/res/recovery-services/vault:_version_
Operations Management Solution: br/public:avm/res/operations-management/solution:_version_
Data Factory Factory: br/public:avm/res/data-factory/factory:_version_
Virtual Machine Images Image Template: br/public:avm/res/virtual-machine-images/image-template:_version_
CDN Profile: br/public:avm/res/cdn/profile:_version_
Compute Availability Set: br/public:avm/res/compute/availability-set:_version_
Compute Disk: br/public:avm/res/compute/disk:_version_
Compute Disk Encryption Set: br/public:avm/res/compute/disk-encryption-set:_version_
Compute Gallery: br/public:avm/res/compute/gallery:_version_
Compute Image: br/public:avm/res/compute/image:_version_
Compute Proximity Placement Group: br/public:avm/res/compute/proximity-placement-group:_version_
Compute SSH Public Key: br/public:avm/res/compute/ssh-public-key:_version_
Compute Virtual Machine: br/public:avm/res/compute/virtual-machine:_version_
Compute Virtual Machine Scale Set: br/public:avm/res/compute/virtual-machine-scale-set:_version_
Digital Twins Instance: br/public:avm/res/digital-twins/digital-twins-instance:_version_
DevTest Labs Lab: br/public:avm/res/dev-test-lab/lab:_version_
Batch Account: br/public:avm/res/batch/batch-account:_version_
Database for MySQL Flexible Server: br/public:avm/res/db-for-my-sql/flexible-server:_version_
Purview Account: br/public:avm/res/purview/account:_version_
Container Registry Registry: br/public:avm/res/container-registry/registry:_version_
Service Bus Namespace: br/public:avm/res/service-bus/namespace:_version_
Container Instances Container Group: br/public:avm/res/container-instance/container-group:_version_
Data Protection Backup Vault: br/public:avm/res/data-protection/backup-vault:_version_
Maintenance Configuration: br/public:avm/res/maintenance/maintenance-configuration:_version_
Azure Service Fabric Capacity: br/public:avm/res/fabric/capacity:_version_
Automation Account: br/public:avm/res/automation/automation-account:_version_
App Configuration Store: br/public:avm/res/app-configuration/configuration-store:_version_
Managed Services Registration Definition: br/public:avm/res/managed-services/registration-definition:_version_
Communication Service: br/public:avm/res/communication/communication-service:_version_
Communication Email Service: br/public:avm/res/communication/email-service:_version_
Container Service Managed Cluster: br/public:avm/res/container-service/managed-cluster:_version_
Relay Namespace: br/public:avm/res/relay/namespace:_version_
Cognitive Services Account: br/public:avm/res/cognitive-services/account:_version_
Power BI Dedicated Capacity: br/public:avm/res/power-bi-dedicated/capacity:_version_
Service Fabric Cluster: br/public:avm/res/service-fabric/cluster:_version_
Operational Insights Workspace: br/public:avm/res/operational-insights/workspace:_version_
Azure Synapse Analytics Private Link Hub: br/public:avm/res/synapse/private-link-hub:_version_
Azure Synapse Analytics Workspace: br/public:avm/res/synapse/workspace:_version_
Kubernetes Configuration Extension: br/public:avm/res/kubernetes-configuration/extension:_version_
Kubernetes Configuration Flux Configuration: br/public:avm/res/kubernetes-configuration/flux-configuration:_version_
SignalR Service SignalR: br/public:avm/res/signal-r-service/signal-r:_version_
SignalR Service Web PubSub: br/public:avm/res/signal-r-service/web-pub-sub:_version_
Service Networking Traffic Controller: br/public:avm/res/service-networking/traffic-controller:_version_
Healthcare APIs Workspace: br/public:avm/res/healthcare-apis/workspace:_version_
Load Testing Load Test: br/public:avm/res/load-test-service/load-test:_version_
SQL Instance Pool: br/public:avm/res/sql/instance-pool:_version_
SQL Managed Instance: br/public:avm/res/sql/managed-instance:_version_
SQL Server: br/public:avm/res/sql/server:_version_