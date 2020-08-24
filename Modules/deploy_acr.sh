source $params

az acr create \
    --subscription $subscription_id \
    --resource-group $rg \
    --location $location \
    --tags $tags \
    --name $acr_name \
    --sku $acr_sku