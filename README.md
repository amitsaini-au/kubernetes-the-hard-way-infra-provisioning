# kubernetes-the-hard-way-infra-provisioning
This repo contains the terraform code to provision infrastructure for the kubernetes-the-hard-way tutorial which can be found here https://github.com/kelseyhightower/kubernetes-the-hard-way.

## Purpose:
This repo is no way a replacement of the original tutorial. Basic motive here is to skip the provisioning steps and follow the tutorial from step 4 (https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md)

## Instructions:
1. Go to the gcp directory and run `terraform init`.
2. Download service account credentials for you project from GCP console https://console.cloud.google.com/apis/credentials/serviceaccountkey and move it into the gcp directory.
2. Update project id by adding  `project_id = "{YOUR_PROJECT_ID}"` in terraform.tfvars.
3. You can also update region and zone if required.
4. Run `terraform apply`
