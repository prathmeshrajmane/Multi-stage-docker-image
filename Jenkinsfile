pipeline {
	agent any
	environment {
		DOCKER_HUB_CREDENTIALS_ID = 'dockerhub'
		DOCKER_HUB_REPO = 'prathmeshrajmane/multi-stage-app'
		CONTAINER_PORT = '8080'
		HOST_PORT = '8085'
		CONTAINER_NAME = 'Multi-stage-app'
	}
	stages {
		stage('Checkout Github'){
			steps {
				git branch: 'master', credentialsId: 'git', url: 'https://github.com/prathmeshrajmane/Multi-stage-docker-image.git'
			}
		}		
		stage('Build Docker Image'){
			steps {
				script {
					dockerImage = docker.build("${DOCKER_HUB_REPO}:latest")
				}
			}
		}
    
		stage('Trivy Scan'){
			steps {
				// echo "Failing on HIGH/CRITICAL vulnerabilities..."
           			// sh 'trivy image --severity HIGH,CRITICAL --exit-code 1 --no-progress ${DOCKER_HUB_REPO}:latest'
			        echo "Running Trivy vulnerability scan..."
			        sh 'trivy image --severity HIGH,CRITICAL --no-progress --format template --template "@html.tpl" -o report.html ${DOCKER_HUB_REPO}:latest'
				    // sh 'trivy image --severity HIGH,CRITICAL --no-progress --format table trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest'
				   // sh 'trivy image --severity HIGH,CRITICAL --exit-code 1 --no-progress --format table -o trivy-scan-report.txt ${DOCKER_HUB_REPO}:latest'
			}
		}
		stage('Grype Static Analysis Scan'){
			steps {
				 // echo "Failing on HIGH/CRITICAL vulnerabilities..."
         		 	//   sh 'grype ${DOCKER_HUB_REPO}:latest --fail-on high -o table'
			        echo "Running Grype vulnerability scan..."
				    sh 'grype ${DOCKER_HUB_REPO}:latest --output table > grype-scan-report.txt '
				   // sh 'grype ${DOCKER_HUB_REPO}:latest --fail-on critical --output table > grype-scan-report.txt '

			}
		}
		stage('Push Image to DockerHub'){
			steps {
				script {
					docker.withRegistry('https://registry.hub.docker.com', "${DOCKER_HUB_CREDENTIALS_ID}"){
						dockerImage.push('latest')
					}
				}
			}
		}
		
	stage('Deploy Application') {
            steps {
                script {
                    echo "Stopping existing container if running..."
                    sh """
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    """
                    echo "Running the new container..."
                    sh """
                        docker pull ${DOCKER_HUB_REPO}:latest
                        docker run -d -p ${HOST_PORT}:${CONTAINER_PORT} --name ${CONTAINER_NAME} ${DOCKER_HUB_REPO}:latest
                    """
                }
            }
        }
stage('Runtime Security Check') {
       steps {
           script {
               echo "Monitoring runtime with Falco..."
               sh '''
               docker run -d --name ${CONTAINER_NAME} ${DOCKER_HUB_REPO}:latest
               sleep 10  # Wait for container to start
               if journalctl -u falco --since "1 minute ago" | grep -q "suspicious"; then
                   echo "Runtime threat detected!"
                   exit 1
               fi
               '''
           }
       }
   }

stage('Validate Deployment') {
       steps {
           sh "curl -sSf http://localhost:${HOST_PORT}/health || exit 1"
       }
   }
    }
	post {
		success {
			echo 'Build & Deploy completed succesfully'
		}
		failure {
			echo 'Build & Deploy failed. Check logs'
		}
	}
}
