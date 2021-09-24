# Create your Bicep file

## Demo 1: Create resources

* Show input parameters

* Show variables

* Add **Storage Account** with required properties

* Add **App Service Plan** via *res-app-plan*

* Add **App Service** via required properties

* Create a **Resource Group** via Azure CLI

```
az group create --name yac-dev-bicepdemo-rg --location westeurope
```

* Deploy **Bicep** without providing parameters and cancel it

```
az deployment group create `
   --resource-group yac-dev-bicepdemo-rg `
   --template-file infra.bicep
```

* Show all parameter files

* Deploy **Bicep** with parameter file

```
az group deployment create `
   --resource-group yac-dev-bicepdemo-rg `
   --template-file infra.bicep `
   --parameters infra.dev.parameters.json
```

## Demo 2: Handle connection string

* Copy new variables

```bicep
var secretName = '${storageAccountName}-connectionstring'
var keyVaultName = '${prefix}-vault'
var keyVaultSoftDelete = env == 'prd' ? true : false
```

* Add the **Key Vault** via snippet

* Add the **Key Vault Secret** via required properties

* Add the **Role Assignment** via required properties (**2020-04-01-preview**)

* Copy the **App Settings**

* Configure the **Outputs**

* Visualize the bicep file

* Deploy again

## Demo 3: Deploy locally

* Show script

* Run script

TODO

## Improvements

* Add conditions
* Add loops
* Add module (with deployment name)
* Add infra vs app pipeline