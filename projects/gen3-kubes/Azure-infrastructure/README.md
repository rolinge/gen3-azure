# Gen3 Kubernetes driven environment

## Objective
Create a Gen3 infrastructure using Kubernetes, HDInsights, Spark, and other Azure based assets using terraform, helm, and as few as possible manual operations.

# Technologies
- Azure Public Cloud (azure-cli) installed on your Mac, PC, or Linux system
- Terraform for managing the Azure assets
- Docker for running the microservices
- Kubernetes for hosting the microservices
- Helm for managing Kubernetes objects





#get kubernetes credentials for the first admin
LAMU02XLNBTJHC8:kubernetes-setup rolinge$ az aks get-credentials --resource-group k8s-gen3-cg2 --name aks_k8sgen3cg2 --admin

kubectl apply namespaces.yaml
kubectl apply clusteroles, roles
kubectl apply StorageConfig
vi opendistro/customevalues.yaml   (change the name)
cd <opendistro>/helm  && helm install <name> -f customvalues.yaml .

use the info in database_setup.txt to create users and assign permissions.  This requires getting the postgres server name and postgres password from the terraform output.

in the gen3-helm directory, edit the values file for your specific settings.

helm install nginx-ingress ingress-nginx/ingress-nginx --namespace default --set controller.replicaCount=2



# DCE Kubernetes Sandbox (AKS)

## Objective
Quickly get started with the the Azure Kubernetes Service in your DCE sandbox. Learn and explore best practices with this [everything-as-code](https://openpracticelibrary.com/practice/everything-as-code/) implementation.

## Overview
DCE Kubernetes (AKS) deploys a VM scalesets and multi node pools Kubernetes cluster on Azure using AKS (Azure Kubernetes Service) and adds support for monitoring by attaching a Log Analytics solution.

### Prerequisites
- [x] A DCE subscription with an active [Azure DCE account](https://cloud.optum.com/app/dashboard). Learn more about DCE [here](https://cloud.optum.com/docs/dce/overview).
- [x] An editor like VSCode to make a change (optional).
- [x] [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) installed and configured.
- [x] Kubernetes command-line tool, kubectl, installed. Request from [AppStore](https://appstore.uhc.com/AppInfo/AppVersionId/16407?BackToList=/AppList/AppList).
- [x] Terraform (~>0.12.0). Learn more [here](https://www.optumdeveloper.com/content/odv-optumdev/optum-developer/en/development-tools-and-standards/infrastructure-as-a-code/hashicorp.html).
- [x] Git (>2.9)

### A few key points about the infrastructure that you are going to create:

| Name                              | Description                                                                                                                                       | Type   | Default         |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | --------------- |
| resource_group_name               | Specifies the Resource Group where the Managed Kubernetes Cluster should exist.        Changing this forces a new resource to be created.                | string |     [MS ID]-[01]          |
| kubernetes_version                | Version of Kubernetes specified when creating the AKS managed cluster (https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions). This deployment provides you with version: 1.18.8. | string |      1.18.8           |
| agent_pool_profile_vm_count       | Number of Agents (VMs) in the Pool. For your DCE account the value is set to 2 VMSS nodes. **Do NOT change this value.**                                                | string | 2               |
| agent_pool_profile_vm_size        | The default size of the VMs in your kubernetes cluster is configured to be as Standard_D2s_v3. **Do NOT change this value.**                                  | string | Standard_DS2_v3 |                    |
tags                              | Map of tags to assign to the resource. **Do NOT change this value.**                                                                                                            | map    | {}              |
|log_analytics_workspace_id        | Log analytics workspace for writing logs from the Kubernetes master components. This is enabled for log and health monitoring of the kubernetes cluster.                                                                   | string |                |

## Deploying to your DCE account

See the Health Care Cloud Technical Guide: [_How to Deploy Workshops to Your DCE Account_](https://commercialcloud.optum.com/docs/technical-guides/deploy-workshop-to-redbox.html)

## Verifying your deployment

### Viewing the AKS resources Application

* After your build is complete, visit the Azure portal. All the resources can be found under your resource group.
![ResourceGroups](/assets/portal-1.png)

At this stage, you have an AKS cluster that is up and running. Your Jenkins console output terminal should present you with a kubeconfig value and name of your resource group. You are going to use this tf output information to access the AKS cluster that you just created.

### Find the token in Jenkins

* Access the Jenkins console output for your most recent successful build. The build process will provision bunch of artifacts for your MS-ID. After the successful build you should see the output similar to below screens.

* Copy the entire value *(starting at **apiversion** and ending at the line of **token**)* of kube_config in a notepad/textpad. This kubeconfig include the details for the cluster and context. *This is a sensitive information and the kubeconfig files are typically saved to the user's disk and selected via an environment variable. We recommend deleting your build from Jenkins soon after you have copied the kubeconfig information.*

![ResourceGroups](/assets/jenkins-0.png)   |   ![ResourceGroups](/assets/jenkins-1.png)


### Setup Kubectl and connect to AKS

You can use **kubectl** to connect to your AKS cluster. kubectl uses kubeconfig files to find the information it needs to choose a cluster and communicate. Use the following commands in your terminal; these commands will configure your kubeconfig file.

* Copy the kubeconfig value in a notepad/textpad. In a terminal window, enter the following command

> vi ~/dce_kubeconfig

*This example is using dce_kubeconfig as the file to store kube_config value. You can choose any name that suits your naming convention.*

*If you choose not to save the kubeconfig file in the default location ($HOME/.kube) or with the default name (config), set the value of the KUBECONFIG environment variable to point to the name and location of the kubeconfig file. For example, enter the following command in the terminal: Export the file in your session to activate the connection.

> export KUBECONFIG=~/dce_kubeconfig

> Note 1: By default, kubectl checks ~/.kube/config for a kubeconfig file. If no kubeconfig file already exists in the default location, then you can directly paste the kubeconfig value @ ~/.kube/config. There are ways to merge your multiple kubeconfig files but that is beyond the scope of this excercise.

> Note 2: If you have not saved the file in the default location, then the kubectl session will be lost when you close your terminal.

### Verify that kubectl can access the AKS cluster

Verify that kubectl can connect to the cluster by entering the following command in the terminal:

> kubectl get serviceaccounts

or

> kubectl get sa

The output is similar to this:

![output](/assets/output-1.png)


## Testing Steps:

If you have followed all the preceding sections and subsections, you are ready to deploy your first container to AKS.

* Find the nodes in your cluster by using kubectl command line.
    > kubectl get nodes

You should find two nodes and your output is similar to this:

![output](/assets/output-2.png)

Now it is time to test and deploy the Nginx image. To do so, please use terminal shell using the kubectl command line.

* deploy a nginx image like:
    > $ kubectl create deployment nginx-dce --image=nginx:1.14.2

*In the above command, you deployed one replica of nginx to your nodes and AKS will create one pod to run the image*


* Verify the Pods like:
    > $ kubectl get pods

At this stage, the deployment has started. You are going to expose port 80 to the Nginx web server and allow access to it using a web browser. Without exposing the deployment, you can’t access the service.

   >  $ kubectl expose deployment nginx --type=LoadBalancer --port 80 --name=nginxsvc

After exposing the deployment, AKS will create a service called nginxsvc with port 80 allowed.

* To check if the service is ready, and get the external IP address of the deployment, run the following command:


    > $ kubectl get service --watch

![service ready](/assets/ready.png)

* You can see the end result of the deployment and service, where Nginx is now accessible via a public IP address.

![nginx web server](/assets/nginx.png)


* To delete the deployment after you are done testing, run the following code:

> $ Kubectl delete deployment nginx-dce

> $ Kubectl delete service nginxsvc

### Helpful Resources:

* [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes)
* [Kubectl Guide](https://www.optumdeveloper.com/content/odv-optumdev/optum-developer/en/getting-started/health-care-cloud-getting-started/getting-started-with-kubernetes/step-6--configure-kubernetes-cli---kubectl.html)
* [Optum Standard AKS Recommendations](https://cloud.optum.com/docs/technical-guides/aks-guide/) (for teams with an enterprise subscription needing further information)

### Looking for More?
This EaC pattern for DCE provides a environment for learning or POCing AKS and may not be suitable for all use cases. Let us know what else you'd like to see by submitting a [product feature request](https://github.optum.com/healthcarecloud-dce/feature-requests/issues/new/choose).
