

pipeline {
    stages {
        stage('Source Code') {
            steps {
                script {
                    sh 'ls -l'
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'gen3-acr-klnow', url: "https://acrgen3klnow.azurecr.io/"]) {
                    sh '''
                    cd projects/gen3-kubes/blobIndex/AzureIndexTrigger
                    docker build -t acrgen3klnow.azurecr.io/gen3/blobtriggerdocker:klnow01 .
                    docker push acrgen3klnow.azurecr.io/gen3/blobtriggerdocker:klnow01
                    '''
        		}
    		}
		}
	}
}
