source $params

az monitor log-analytics workspace create \
    --subscription $subscription_id \
    --resource-group $rg \
    --location $location \
    --tags $tags \
    --workspace-name $log_analytics_workspace \
    --retention-time $log_analytics_retention