export params="./Params/params-test.sh"

./Modules/deploy_resource_group.sh
./Modules/deploy_vnet.sh
./Modules/deploy_keyvault.sh
./Modules/deploy_log_analytics.sh
./Modules/deploy_acr.sh
./Modules/deploy_app_gateway.sh
./Modules/deploy_aks.sh