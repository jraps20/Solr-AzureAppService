# Solr-AzureAppService for Sitecore

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

Install Solr as an App Service in about 10 minutes preconfigured for Sitecore 8.2u7+. Click the button above and follow the prompts. Be sure to select the proper Solr Version for your Sitecore installation (https://kb.sitecore.net/articles/227897). Once this deployment completes, all prerequisites for Sitecore are in place. You may run quick start templates or install directly from "Sitecore Experience Cloud" Azure resource and provide the Solr link, e.g. https://myappservice.dev.azure.net/solr. Full credit goes to Dan Cruickshank. His guide was used as the basis for this one-click deployment:

https://getfishtank.ca/blog/installing-solr-app-service-in-sitecore-azure-paas

This script sets the `httpsOnly` property to `true` by default, but it can be modified in the parameters (in the prompts).

## Deployment Summary

1. \[Deploy to Azure\] button looks for `azuredeploy.json` file at repo root
2. `azuredeploy.json` deploys resources. Notable steps listed below:
    1. `solrVersion` parameter is added as an `appSetting` to the web app. This is required to parameterize it when calling `Deploy-SolrAzureAppService.ps1`
    2. `web > config` resource. Sets `javaVersion` to 1.8 which supports all (?) Solr versions
    3. `sourcecontrols` resource. This is the brains of the operation. It deploys THIS repository to your web app.
        1. With this resource deployment, if a file named `.deployment` exists at the repo root, it is executed once the repo has been cloned to your web app
3. The `.deployment` file calls `Deploy-SolrAzureAppService.ps1` with the Solr version as a parameter (parameters are only accessible from the `.deployment` file). 
4. `Deploy-SolrAzureAppService.ps1` is where the majority of work occurs. This is where Dan's manual work was implemented in an automated fashion
    1. This script downloads and extracts the desired Solr version to the web root
    2. It also copies the `web.config` from the repo to the web root

## View deployment logs

To see the deployment logs, find your deployed App Service in Azure, then in the left-hand navigation select `Development Tools > Advanced Tools (Kudu)`, then click `Go` to launch Kudu. Once Kudu launches in a new tab, from the primary navigation select `Tools > Zip Push Deploy`. Once this page loads, expand the deployment steps at the bottom to see the log output and any errors.

### Resources
- https://github.com/projectkudu/kudu/wiki/Customizing-deployments
