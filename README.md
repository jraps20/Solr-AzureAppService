# Solr-AzureAppService

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

Install Solr as an App Service in about 10 minutes. Click the button above and follow the prompts. Full credit goes to Dan Cruickshank. His guide was used as the basis for this one-click deployment:

https://getfishtank.ca/blog/installing-solr-app-service-in-sitecore-azure-paas

This script sets the `httpsOnly` property to `true` by default, but it can be modified in the parameters (in the prompts).

Verified on Solr 6.6.2 and 7.2.1. 