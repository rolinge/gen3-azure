
def SAFE_BRANCH_NAME = env.BRANCH_NAME.replaceAll("[/_.\$%^&*()@!]","")

pipeline {
    agent {
        label 'docker-slave'
    }

    environment {
        TAG = "${SAFE_BRANCH_NAME}"

    }
    stages {
        stage('Source Code') {
            steps {
                sh 'ls -l'
            }
        }

        stage('Connect to Azure') {
            steps {
                sh 'which az'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'gen3-acr-klnow', url: "https://acrgen3klnow.azurecr.io/"]) {
                    sh '''
                    cd projects/gen3-kubes/blobIndex/AzureIndexTrigger
                    docker build -t acrgen3klnow.azurecr.io/gen3/blobtriggerdocker:$TAG .
                    docker push acrgen3klnow.azurecr.io/gen3/blobtriggerdocker:$TAG
                    '''
                    }
                }
        }

        stage('Terraform Commands') {
            environment {
                USER_CREDENTIALS = credentials('gen3-acr-klnow')
            }
            steps {
                withCredentials([azureServicePrincipal('azure-ectgenomics-deploy')]) {
                    withDockerRegistry([credentialsId: 'gen3-acr-klnow', url: "https://acrgen3klnow.azurecr.io/"]) {
                        sh '''
                        docker login acrgen3klnow.azurecr.io --password $USER_CREDENTIALS_PS --username $USER_CREDENTIALS_USR 
                        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                        az webapp config container set --docker-custom-image-name acrgen3klnow.azurecr.io/gen3/blobtriggerdocker:$TAG --name blobindexfuncdevklnow --resource-group k8s-gen3 --docker-registry-server-url https://acrgen3klnow.azurecr.io/ --docker-registry-server-password $USER_CREDENTIALS_PSW --docker-registry-server-user $USER_CREDENTIALS_USR 
                        '''
                    }
                }
            }
        }
    }
}