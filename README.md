# Bicep

This demo showcases how you can create an Azure PaaS solution with Bicep.

## Prerequisites

* Have Azure CLI installed
* Visual Studio Extension for Bicep language support
* Install Bicep

```
az bicep install
```

## Create  bicep file

* Create an `infra.bicep` file 

* Open in Visual Studio Code

* Use often `Ctrl + Space` to get some intellisense

* Configure the targetScope

```
targetScope = 'subscription'
```

## Configure parameters

* Configure the parameters as provided in the `infra.bicep` file

## Configure variables

* Configure the variables as provided in the `infra.bicep` file

## Configure resource group

* Create a resource group with the `required properties` intellisense

* Complete like in the `infra.bicep` file

## Deploy the template

* Open PowerShell

* Login with Azure CLi and select the right subscription

```cli
az logout
az login --tenant <tenant-id>
az account set --subscription <subscription-id>
cd infra
```

* Deploy the Bicep template without passing parameters

```cli
az deployment sub create --location 'westeurope' --template-file infra.bicep
```

* Provide the mandatory parameters inline:
    * **env:** dev
    * **storageAccountSku:** Standard_LRS
    * **appServicePlanSku:** F1


* Deploy the Bicep template with inline **incorrect** parameters

```cli
az deployment sub create --location 'westeurope' --template-file infra.bicep --parameters env=develop 
```

* Deploy the Bicep template with inline **correct** parameters

```cli
az deployment sub create --location 'westeurope' --template-file infra.bicep --parameters env=dev storageAccountSku=Standard_LRS appServicePlanSku=F1
```

* Create an ARM parameter file `infra.parameters.dev.json`

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
  "env": {
      "value": "dev"
  },
  "storageAccountSku": {
      "value": "Standard_LRS"
  },
  "appServicePlanSku": {
      "value": "F1"
  },
  "location": {
      "value": "westeurope"
      }
  }
}
```

* Deploy the Bicep template with the parameter file

```cli
az deployment sub create --location 'westeurope' --template-file infra.bicep --parameters ./infra.parameters.dev.json 
```

## Create Storage Account

* Create new module in `modules` subfolder, named `storageaccount.bicep`
  * This showcases loop
  * This showcases parents
  * This showcases outputs

* Consume this module from within the `infra.bicep` file


## Show complete example

* Visualize the Bicep file via `F1 > bicep: Open Visualizer `
