
pipeline {
    agent {
        label any
    }

    stages {
        stage('Source Code') {
            steps {
                script {
                    sh 'ls -l'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'cd projects/gen3-kubes/blobIndex/AzureIndexTrigger'
		        sh 'docker build -t acrgen3klnow.azurecr.io/gen3/blobtriggerdocker:klnow01 .'
            }
        }

        stage('Push to docker registry') {
            steps {
                sh 'docker push acrgen3klnow.azurecr.io/gen3/blobtriggerdocker:klnow01'	
            }
        }
    }
    post {
    	success {
        	setBuildStatus("Build succeeded", "SUCCESS");
    	}
    	failure {
        	setBuildStatus("Build failed", "FAILURE");
    	}
    }
}

