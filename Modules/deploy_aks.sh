source $params

#Deploy the VNET AKS Nodes will be deployed in
az network vnet subnet create \
    --subscription $subscription_id \
    --resource-group $rg \
    --name $aks_subnet_name \
    --vnet-name $vnet_name \
    --address-prefixes $aks_subnet_cidr

#Create the cluster itself
az aks create \
    --subscription $subscription_id \
    --resource-group $rg \
    --name $aks_name \
    --location $location \
    --tags "$tags" \
    --kubernetes-version $k8s_version \
    --uptime-sla \
    --vm-set-type "VirtualMachineScaleSets" \
    --attach-acr $acr_name \
    --network-plugin "azure" \
    --network-policy "calico" \
    --vnet-subnet-id $aks_subnet_id \
    --docker-bridge-address $docker_bridge_cidr \
    --dns-service-ip $dns_service_ip \
    --service-cidr $service_cidr \
    --enable-aad \
    --enable-managed-identity \
    --node-vm-size $node_vm_size \
    --nodepool-labels $node_labels \
    --node-count $node_count \
    --max-pods $max_pods_per_node \
    --enable-cluster-autoscaler \
    --min-count $node_count \
    --max-count $max_autoscale_node_count \
    --enable-addons monitoring \
    --workspace-resource-id $log_analytics_workspace_id \
    --load-balancer-sku $load_balancer_sku

#Get the System MSI of the cluster
aks_identity=$(az aks show \
                --resource-group $rg \
                --name $aks_name \
                --query "identity" | jq -r '.principalId')

# Add MSI as Network Contributor on VNET to manage subnet allocation
az role assignment create --assignee $aks_identity --role "Network Contributor" --scope $vnet_id

#Add MSI to Keyvault to list and read secrets (if it's specified')
if [[ ! -z $keyvault_name ]] && [[ " $(az keyvault list | jq '.[].name') " =~ "${keyvault_name}" ]]; then
    az role assignment create --assignee $aks_identity --role "Reader" --scope $keyvault_id
    az keyvault set-policy --name $keyvault_name --object-id $aks_identity --secret-permissions get list 
fi