def SAFE_BRANCH_NAME = env.BRANCH_NAME.replaceAll("[/_.\$%^&*()@!]","")

pipeline {
	agent {
		label 'docker-slave'
	}

    environment {
        TAG = SAFE_BRANCH_NAME

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
            steps {
                sh 'pwd'
                sh 'cd ../../Azure-infrastructure'
                sh 'terraform apply -target=azurerm_function_app.funcapp -var blobindexfunction_version=$TAG'
            }
        }
	}
}
