# Azure Cloud Resume Challenge

## Overview
In the pursuit to expand my skills and knowledge in Azure, I embarked on the [Azure Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/azure/). This repository is the outcome of my efforts, showcasing a cloud-based resume hosted on Azure. My journey included creating cloud resources with Terraform, automating deployments with GitHub Actions, developing a serverless backend function using Azure Functions and crafting a responsive frontend. My primary objective was to design a process that was easily reproducible by adhering to Infrastructure as Code (IaC) principles. This experience enhanced my technical abilities and deepened my understanding of Azure cloud and IaC.

The completed resume can be found at [https://www.laurencejwoodley.com](https://www.laurencejwoodley.com).

The main knowledge sources used to complete this challenge were:

  -  Microsoft documentations
  -  [Terraform Azure Provider documentation for version 3.79.0](https://registry.terraform.io/providers/hashicorp/azurerm/3.79.0/docs)
  - [ACG Projects: Build Your Resume on Azure with Blob Storage, Functions, CosmosDB, and GitHub Actions](https://www.youtube.com/watch?v=ieYrBWmkfno&t=2686s)
  - ChatGPT

## Prerequisite
Before starting, ensure the following tools are installed on your system:

1. __Azure CLI__: For managing Azure resources
1. __Terraform__: For creating Azure resources
1. __Python__: For running backend scripts and tests
1. __GitHub CLI__: For creating repository secrets

Additionally, set up dedicated Azure subscriptions for production and development environments. This ensures that production resources are developed and maintained independently of development resources.

## Configuring Secrets and Azure Credentials for GitHub Actions
[OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux#use-the-azure-login-action-with-openid-connect) (OIDC) is used to authenticate with Azure from a GitHub Actions workflow. The official [GitHub docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) contains information on setting up a workflow for OIDC. 

### Azure Subscription Setup
You must be logged into an Azure subscription for OIDC configuration. Follow these steps if you
need to log into your subscription.
1. __Azure Account Login__: Run `az login`.

2. __Subscription Verification__: Use `az account show` to show the Azure subscription. If an account switch is needed run

```bash
# lists the subscription names
az account list --output table

az account set --subscription <subscription_name>
```

### Github Setup
1. __GitHub Environemnts__: Create `PROD` and `TEST` [Github environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment).

2. __GitHub Secrets Management__: Copy [examples/prod.env](examples/prod.env) to `prod.env` and populate the required variables. The variables are necessary for terraform to build Azure resources. Run 
`gh secret set -f prod.env --env PROD` to set the secrets in the `PROD` environment. Repeat these steps for the TEST environment.

3. __OIDC Configuration__: Run the following to configure OIDC and store the credentials in the desired environemnt. 
```bash
./open_id_connect.sh <APP_NAME> <SUBSCRIPTION_NAME> <GITHUB_ENVIRONMENT>
```

## Development Environment
Complete the following steps for developing on Azure from your local machine. These steps should be completed before any changes are made to terraform scripts. Step 1 is only necessary on initial setup.
Steps 2 and 3 are not necessary if you are already logged into the desired subscription.

1. __Terraform Variables__: Copy [examples/terraform.tfvars](examples/terraform.tfvars) to [terraform](terraform) and populate.

2. __Azure Account Login__: Refer to the previous section for login instructions.

3. __Initialize Development Environment__: Run `./build.sh` to set up the Azure development environment.

4. __Clean Up__: Once done, run `./destroy.sh` to destroy the development environment.


## Testing Process
 
Tests are automatically triggered upon modifications to any of the following directories: [./terraform](./terraform), [./backend/api](./backend/api), or [./frontend](./frontend). This process applies to both pull requests and pushes to the main branch. 

Each pull request initiates the build of a fresh Azure testing environment created via [.github/workflows/build-test.yml](./.github/workflows/build-test.yml). This ensures that every code change is  tested in a clean environment before integration.

Two main tests are ran:

1.  `./backend/tests/test_api.py` tests that the API is functional and responsive.

2.  `./backend/tests/test_webpage.py` tests that the visit count is displayed on the the webpage.

## Production Deployment
The production deployment is triggered when there are changes to [./terraform](./terraform), [./backend/api](./backend/api) or [./frontend](./frontend) directories of the main branch. `.github/workflows/deploy-prod.yml` orchestrates the deployment by calling several jobs, each tailored to handle specific components of the deployment.

- __Infrastructure Deployment__: Azure resources are deployed with Terraform via `deploy-azure-resources`.

- __Backend Deployment__: The severless backend is deployed with `deploy-backend`

- __Frontend Deployment__: The frontend is deployed with `deploy-frontend`

- __Automated Tests__: Tests are executed via `.github/workflows/run-tests.yml`

These jobs are executed sequentially. Additionally, any job corresponding to a directory without changes will be skipped.
