pipeline {
    // Runs on the k8s-master node, which is registered as a Jenkins Agent
    // (labelled "k8s-master") so kubectl runs right next to the cluster.
    agent { label 'k8s-master' }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')   // Jenkins credential ID (username + password/token)
        DOCKERHUB_USER        = "${DOCKERHUB_CREDENTIALS_USR}"
        IMAGE_NAME            = "beginner-html-site"
        IMAGE_TAG              = "${env.BUILD_NUMBER}"
        FULL_IMAGE             = "${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    // Auto-trigger on every push to the forked repo (paired with a GitHub
    // webhook -> http://<jenkins-master-ip>:8080/github-webhook/)
    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${FULL_IMAGE} -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                sh "docker push ${FULL_IMAGE}"
                sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    sed -i "s|image: .*|image: ${FULL_IMAGE}|g" k8s/deployment.yaml
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl rollout status deployment/beginner-html-site --timeout=120s
                """
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
        success {
            echo "Deployed ${FULL_IMAGE} — site reachable on NodePort 30010."
        }
        failure {
            echo "Pipeline failed — check the stage logs above."
        }
    }
}
