source $params

az group create \
    --subscription $subscription_id \
    --location $location \
    --tags $tags \
    --name $rg