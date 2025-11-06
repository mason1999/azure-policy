# Azure Policy as Code

## Overview
This repository automates policy for an Azure environment via native IaC tooling on Azure. Configuration is given via JSON in the **policy-definitions**, **policy-assignments** and **policy-initiatives** folder and read into the bicep files to be deployed. Operationally, JSON schema is configured with plenty of examples to allow for smooth authoring of policy definitions and assignments in a comprehensive manner.

---

## ✅ Features

- ✅ Templates for definitions and assignments out-of-the-box.
- ✅ Helper script to aid in the deployment and deletion process (using deployment stacks).
- ✅ Language neutral configuration for the definitions and assignments (in JSON).
- ✅ JSON schema integration for native / out-of-the-box in the .vscode folder.

---

## 🧱 Requirements

- **Azure CLI:** (>=)2.76.0
- **Bicep CLI:** (>=)0.38.33
- **jq:** (>=)1.6
- **Bash:** (>=)5.0.0
- **Visual Studio Code:** For intellisense with JSON schema.
- **Owner Permissions on the root management group in Azure**

---

## 🚀 Usage

To begin:
1. Clone the repository with `git clone https://github.com/mason1999/azure-policy.git`
1. Authenticate using the azure cli
1. Replace all instances of `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` with the root management group id in the repository
1. Replace all instances of `11111111-1111-1111-1111-111111111111` with the subscription id you want to assign your policy to.
1. Replace all instances of `test-rg` with the resource group you want to assign your policy to.
1. Replace `/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourcegroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-1` with the proper resource id of your first managed identity.
1. Replace `/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourcegroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-2` with the proper resource id of your second managed identity.
1. Run the script `./bicep/policy.sh -c` which will create create the definitions and assignments via a deployment stack (deployed to the root maangement group).
1. Run the script `./bicep/policy.sh -d` which will delete the deployment stack (and all the definitions and assignments) for a comprehensive cleanup.

## Appendix
There are some niceties inside the .vscode folder like how we manage provider aliases to obtain nice intellisense for the providers on a need-to-know basis.
