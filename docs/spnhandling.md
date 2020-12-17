# Service Principal Handling (Database vs Key Vault)

___
[<< Contents](/procfwk/contents) 

___

## Azure Key Vault Roles

![Key Vault Icon](/procfwk/keyvault.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}Before detailing the different approaches within this code project for handling service principal values its important to define how the processing frameworking can _optionally_ use Azure Key Vault. Specifically Key Vault can add an extra layer of security to this solution in the following two ways:

1. Handling credentials used by the [orchestrator](/procfwk/orchestrators) to authenticate against the metadata [SQL database](/procfwk/database) and [Functions Apps](/procfwk/functions) required by the processing framework for normal operations. This is done as part of the [Linked Service](/procfwk/linkedservices) connections within the [orchestrator](/procfwk/orchestrators).

2. Storing the service principal credentials (Application Id and Secret) required by the framework to interact with worker [pipelines](/procfwk/pipeline) and the target [orchestrator](/procfwk/orchestrators) instance where those worker pipelines reside.

The following content within this page only focuses on the second use case (role) for Azure Key Vault within the context of the processing framework and calling worker pipelines.

___

## Worker Authentication 

The processing framework supports the ability to use a different set of credentials for the execution of every single worker pipeline. This also includes the ability to call worker pipelines in different Azure [tenants and subscriptions](/procfwk/crosstenantexecution), as well as different [orchestrator](/procfwk/orchestrators) instances. 

To make this possible each Azure [Function](/procfwk/functions) used within the framework execution is given a set of service principal (SPN) details at runtime and is responsbile for instantiating and authenticating with its own SDK clients, provided by the respective function [service](/procfwk/services) classes. Once the management client connection is made using the .Net SDK the pipeline classes/methods are called to interact with the worker pipelines.

Given this understanding in the orchestration pipelines, the authentication details required by a given worker pipeline are provided from the metadata database using the infant pipeline [activities](/procfwk/activities). In each case, the database [table](/procfwk/tables) [dbo].[ServicePrincipals] is used to store the SPN information and joined to the worker pipeline information via a link table.

Depending on the framework configuration the [dbo].[ServicePrincipals] will contain either:

* Encrypted sets of SPN details, stored in the database directly.
  * The Application Id available in clear text.
  * The Appliction Secret as an encrypted VARBINARY value.
* A set of Key Vault URL's where the SPN details can be returned from as Key Vault secrets.

The different methods of handling SPN details within the processing framework is configured using the database [properties](/procfwk/properties) table. The property used is called __SPNHandlingMethod__ and can have one of the following values. These values corrospond to the behaviour points above.

In both case the configuration aware helper stored procedure __[procfwkHelpers].[AddServicePrincipalWrapper]__ can be used to add your SPN details to the metadata and linked to a worker pipeline.

```sql
EXEC [procfwkHelpers].[AddServicePrincipalWrapper]
@DataFactory = N'FrameworkFactory',
@PrincipalIdValue = '$(CLIENT_ID_or_kvURL)',
@PrincipalSecretValue = '$(CLIENT_SECRET_or_kvURL)',
@PrincipalName = '$(CLIENT_NAME)';
```

### StoreInDatabase

[ ![](/procfwk/spn-in-database.png) ](/procfwk/spn-in-database.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 250px;"}The database provides authentication details to the Azure Functions when the infant [pipeline](/procfwk/pipelines) activity gets the worker authentication information, this includes the tenant and subscription Id values. Where applicable these values are deycrypted by the stored procedure __[procfwk].[GetWorkerAuthDetails]__ at runtime and added to the various function request bodys via a pipeline variable.

The worker pipeline authentication details are requested and returned from the database once per infant pipeline.

___


### StoreInKeyVault

[ ![](/procfwk/spn-in-keyvault.png) ](/procfwk/spn-in-keyvault.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 250px;"}The database provides authentication details to the Azure Functions when the infant [pipline](/procfwk/pipelines) activity gets the worker authentication information. However, the App Id and App Secret are Key Vault URL's rather than the actual decryted values.

The function recognises a URL has been provided in the request body using the internal helper methods, instantiates its own Key Vault client authenticating using the Function App Managed Service Identity (MSI). Then queries Key Vault using the URL to return the secret values.

Once the Key Vault URL's have been resolved to values, the [orchestrator](/procfwk/orchestrators) required client is established.

If using this approach for handling SPN details the Function App MSI needs adding to the Key Vault access policy within your environment.

[https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity)

___

Currently the processing framework only supports one type of SPN handling for all worker pipelines. If hybrid SPN handling is required where by some values use a Key Vault and some workers have values stored directly in the database please raise a [new feature request](https://github.com/mrpaulandrew/procfwk/issues/new?labels=enhancement&template=feature-request.md&title=){:target="_blank"}. 

___

### Activity Secure Inputs/Outputs

Regardless of the choosen method for handling SPN values when used within the asociated framework pipeline activities, the [orchestrators](/procfwk/orchestrators) feature for secure activity inputs and outputs is enabled. This means at runtime and in operational logs the plain text SPN values aren't visable.

![secureinput](/procfwk/activity-secureinput.png)

The above screen snippet shows the affect of this when inspecting the input of the [Execute Pipeline](/procfwk/executepipeline) function activity as part of a framework debug run.

If troubleshooting a worker pipeline authentication issue this feature will need to be manually disabled for a given activity.

___