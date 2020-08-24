source $params

# If this VNET has subnets allocated do not attempt to deploy as 
# it will try to wipe the subnets that are there and may have 
# been deployed by other applications
if [[ $(az network vnet list \
        --resource-group $rg \
        | jq '.[].name') =~ "$vnet_name" ]] \
    && [[ $(az network vnet subnet list \
            --resource-group $rg \
            --vnet-name $vnet_name \
            | jq '. | length' ) == 0 ]]; then
    az network vnet create \
        --subscription $subscription_id \
        --resource-group $rg \
        --location $location \
        --tags $tags \
        --name $vnet_name \
        --address-prefixes $vnet_cidr
fi