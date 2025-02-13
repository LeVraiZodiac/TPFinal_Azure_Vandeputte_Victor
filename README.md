```
az group create --name my-final-web-app-resource --location "UK South"
az appservice plan create --name my-app-service-plan --resource-group my-final-web-app-resource --location "UK South" --sku F1 --is-linux
az webapp create --name my-final-web-app --resource-group my-final-web-app-resource --plan my-app-service-plan --runtime "NODE:20-lts"
az webapp config appsettings set --name my-final-web-app --resource-group my-final-web-app-resource --settings WEBSITE_NODE_DEFAULT_VERSION=20-lts WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
az webapp deployment source config --name my-final-web-app --resource-group my-final-web-app-resource --repo-url https://github.com/LeVraiZodiac/TPFinal_Azure_Vandeputte_Victor --branch main --manual-integration  
```

Aller dans Groupe de ressource sur Azure puis dans my-final-web-app-resource puis dans my-final-web-app puis dans le menu à gauche dans 
