source $params

#############################
## App Gateway Provisioning
#############################

#Create the vnet the app gateway will be bridged to
az network vnet subnet create \
    --subscription $subscription_id \
    --resource-group $rg \
    --name $app_gateway_subnet \
    --vnet-name $vnet_name \
    --address-prefixes $app_gateway_subnet_cidr

# Create the App Gateway itself  
az network application-gateway create \
    --subscription $subscription_id \
    --resource-group $rg \
    --name $app_gateway_name \
    --location $location \
    --tags "$tags" \
    --capacity $app_gateway_capacity \
    --max-capacity $app_gateway_max_capacity \
    --min-capacity $app_gateway_capacity\
    --sku $app_gateway_sku \
    --vnet-name $vnet_name \
    --subnet $app_gateway_subnet \
    --public-ip-address $app_gateway_public_ip_name \
    --public-ip-address-allocation "Static"

##############################
## App Gateway Configuration
##############################

# Create HTTPS Port
az network application-gateway frontend-port create \
    --subscription $subscription_id \
    --resource-group $rg \
    --gateway-name $app_gateway_name \
    --name $app_gateway_https_port_name \
    --port 440

# Create the HTTPS listener
az network application-gateway http-listener create \
    --subscription $subscription_id \
    --resource-group $rg \
    --gateway-name $app_gateway_name \
    --name $istio_https_listener \
    --frontend-port $app_gateway_https_port_name

# Create a backend pool for istio's ingress gateway 
# provided it isn't there yet since we don't want to
# overwrite application configured settings.
# IP address will be specified later when istio is configured
if [[ ! $(az network application-gateway address-pool list \
        --subscription $subscription_id \
        --resource-group  $rg \
        --gateway-name $app_gateway_name \
        | jq '.[].name')  =~ "${istio_backend_pool_name}" ]]; then
    az network application-gateway address-pool create \
        --subscription $subscription_id \
        --resource-group $rg \
        --gateway-name $app_gateway_name \
        --name $istio_backend_pool_name
fi

#Create a health probe for the Istio-exposed endpoints
az network application-gateway probe create \
    --subscription $subscription_id \
    --resource-group $rg \
    --gateway-name $app_gateway_name \
    --name $istio_health_probe \
    --protocol $istio_backend_protocol \
    --host "127.0.0.1" \
    --path $istio_health_probe_path \
    --interval $istio_health_probe_interval \
    --timeout $istio_backend_timeout \
    --threshold $istio_health_probe_failure_threshold

# Create http settings for the Istio health probe location
az network application-gateway http-settings create \
    --subscription $subscription_id \
    --resource-group $rg \
    --gateway-name $app_gateway_name \
    --name $istio_http_settings \
    --protocol $istio_backend_protocol \
    --port $istio_backend_port \
    --cookie-based-affinity Disabled \
    --timeout $istio_backend_timeout \
    --enable-probe true \
    --probe $istio_health_probe

# Create the rule to forward requests to the Istio backend pool
az network application-gateway rule create \
    --subscription $subscription_id \
    --resource-group $rg \
    --gateway-name $app_gateway_name \
    --name $istio_https_rule_name \
    --address-pool $istio_backend_pool_name \
    --http-listener $istio_https_listener \
    --http-settings $istio_http_settings

#################################
## Delete Default Configuration
#################################

if [[ $(az network application-gateway rule list \
        --resource-group $rg \
        --gateway-name $app_gateway_name \
        | jq '.[].name') =~ "rule1" ]]; then

    # Delete the default rule created
    az network application-gateway rule delete \
        --gateway-name $app_gateway_name \
        --resource-group  $rg \
        --name rule1 \
        --subscription $subscription_id

    # Delete the default backend pool
    az network application-gateway address-pool delete \
        --gateway-name $app_gateway_name \
        --resource-group  $rg \
        --name appGatewayBackendPool \
        --subscription $subscription_id

    # Delete the default http-settings
    az network application-gateway http-settings delete \
        --gateway-name $app_gateway_name \
        --resource-group  $rg \
        --name appGatewayBackendHttpSettings \
        --subscription $subscription_id
fi

#################################
## Redirect HTTP to HTTPS
#################################

# Create a redirect config so that we can redirect requests to
# the default HTTP listener over to the HTTPS listener
az network application-gateway redirect-config create \
    --subscription $subscription_id \
    --resource-group $rg \
    --name $istio_redirect_rule_name \
    --gateway-name $app_gateway_name \
    --type "Permanent" \
    --target-listener $istio_https_listener \
    --include-query-string "true" \
    --include-path "true"

#Update the default routing rule for the default http listener to redirect to Https
az network application-gateway rule create \
    --subscription $subscription_id \
    --resource-group $rg \
    --gateway-name $app_gateway_name \
    --name $istio_redirect_rule_name \
    --redirect-config $istio_redirect_rule_name \
    --http-listener "appGatewayHttpListener"
