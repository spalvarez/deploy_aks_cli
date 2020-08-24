export subscription_id=""
export rg="sean-test-rg"
export location="eastus"
export tags="owner='Sean Alvarez' createdBy='Sean Alvarez'"

#-------------------
# Application Gateway
#-------------------
export app_gateway_name="sean-test-ag"
export app_gateway_capacity="2"
export app_gateway_max_capacity="5"
export app_gateway_sku="WAF_v2"
export app_gateway_public_ip_name="sean-test-app-gateway-ip"
export app_gateway_https_port_name="https-port"
export istio_backend_pool_name="IstioBackendPool"
export istio_https_listener="IstioHttpsListener"
export istio_redirect_rule_name="redirect-http"
export istio_http_settings="istioHttpSettings"
export istio_backend_port="80"
export istio_backend_protocol="http"
export istio_https_rule_name="istioHttpsRule"
export istio_health_probe="istioHttpProbe"
export istio_health_probe_path="/cluster/health"
export istio_health_probe_interval="30"
export istio_backend_timeout="30"
export istio_health_probe_failure_threshold="3"

#-------------------
# ACR
#-------------------
export acr_name="salvareztestacr"
export acr_sku="standard"

#-------------------
# Keyvault
#-------------------
export keyvault_name="sean-test-keyvault"
export keyvault_id="/subscriptions/$subscription_id/resourceGroups/$rg/providers/Microsoft.KeyVault/vaults/$keyvault_name"

#-------------------
# VNET
#-------------------
export vnet_name="sean-test-vnet"
export vnet_id="/subscriptions/$subscription_id/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet_name"
# VNET provides a max of 65,534 configurable addresses
# 10.1.0.0/16 gives us that amount
export vnet_cidr="10.240.0.0/16"
export aks_subnet_name="aks"
export aks_subnet_id="/subscriptions/$subscription_id/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$vnet_name/subnets/$aks_subnet_name"
# AKS Subnet CIDR must support max number of allocatable addresses
# With max of 50 nodes at 110 pods each we need:
# 1 IP per node for Azure services + 1 node for upgrade surge + pods*nodes
# 51 + (51*150) = 7,701
# 10.240.25.0/19 provides 8,190 addresses
export aks_subnet_cidr="10.240.0.0/19"
export app_gateway_subnet="appgateway"
export app_gateway_subnet_cidr="10.240.100.0/24"

#-------------------
# Log Analytics
#-------------------
export log_analytics_workspace="sean-test-la"
export log_analytics_workspace_id="/subscriptions/$subscription_id/resourceGroups/$rg/providers/Microsoft.OperationalInsights/workspaces/$log_analytics_workspace"
export log_analytics_retention="45"

#-------------------
# AKS Vars
#-------------------
export aks_name="sean-test-aks"
export k8s_version="1.17.9"
export node_vm_size="Standard_D2_v2"
export node_labels="environment=non_production"
export node_count="3"
export max_autoscale_node_count="50"
export max_pods_per_node="150"
export load_balancer_sku="Standard"
# this can be used across AKS clusters. It will be used for any networking required
# by scenarios like a docker build issued within the cluster
export docker_bridge_cidr="172.17.0.1/16"
# Address range used by the control plane. Can be re-used across k8s clusters
export service_cidr="10.240.250.0/24"
# 10.240.250.1 is used by default.svc.cluster.local, so DNS can use .2
export dns_service_ip="10.240.250.2"
