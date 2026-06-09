# Backend bootstrap

Run **once**, before the root module's `terraform init`. Creates the Azure Storage
account + container that hold the root module's remote state. Uses **local state**
itself (chicken-and-egg).

## Steps

```bash
cd bootstrap

export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
export ARM_TENANT_ID="<your-tenant-id>"
# Auth via `az login`, OIDC, or ARM_CLIENT_ID/ARM_CLIENT_SECRET.

terraform init
terraform apply \
  -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
  -var "storage_account_name=<globally-unique-name>"
```

## After apply

1. Note the outputs (`resource_group_name`, `storage_account_name`, `container_name`).
2. Grant the principal that runs the root module **`Storage Blob Data Contributor`**
   on the storage account (required because `shared_access_key_enabled = false`
   forces Azure AD auth):

   ```bash
   az role assignment create \
     --assignee "<root-principal-object-id>" \
     --role "Storage Blob Data Contributor" \
     --scope "$(terraform output -raw storage_account_id 2>/dev/null || echo <storage-account-resource-id>)"
   ```

3. Initialise the root module with these values:

   ```bash
   cd ..
   terraform init \
     -backend-config="resource_group_name=$(terraform -chdir=bootstrap output -raw resource_group_name)" \
     -backend-config="storage_account_name=$(terraform -chdir=bootstrap output -raw storage_account_name)" \
     -backend-config="container_name=$(terraform -chdir=bootstrap output -raw container_name)" \
     -backend-config="key=datadog-azure-monitoring.tfstate"
   ```

> The bootstrap's own `terraform.tfstate` is local — keep it safe or migrate it to
> the created account afterwards. It is git-ignored.
