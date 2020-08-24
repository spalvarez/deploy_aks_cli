source $params

az keyvault create \
    --subscription $subscription_id \
    --resource-group $rg \
    --location $location \
    --tags $tags \
    --name $keyvault_name \
    --enable-purge-protection \
    --no-self-perms