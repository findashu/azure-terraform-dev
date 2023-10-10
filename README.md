# Basic Setup / Prerequisite

* Install [Azure Cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos#install-with-homebrew)
* Install [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/install-cli)
* [Azure Provider Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Deploy the resources
* Ensure prerequisite tools are installed
* Connect Azure Account - `az login`
* Run below terraform commands
```
terraform init
terraform plan
terraform apply

``` 


## Basic Azure CLI Commands

```
* az login
* az account show

```

## Basic Terraform CLI Commands

* Format Terraform File ```terraform fmt```
* Initialise ```terraform init```
* Plan ```terraform plan```
* Apply the Plan ```terraform apply```
* List All resources ```terraform state list```
* Show detail of a resource ```terraform state show resource_name```
* See entire state ```terraform show```
* Destroy Plan ```terraform plan -destroy```
* Apply destroy ```terraform apply -destroy```