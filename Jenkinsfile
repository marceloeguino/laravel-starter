pipeline {
    agent { label 'docker-worker' }

    environment {
        DO_SSH = credentials('do-ssh-key')          // SSH private key for Droplet
        DOCR_TOKEN = credentials('docr-token')      // DigitalOcean Registry token
        APP_KEY = credentials('laravel-app-key')    // Laravel APP_KEY
        REGISTRY = "registry.digitalocean.com/laravel-challenge"
        IMAGE_NAME = "hello-laravel"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    env.GIT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Building Docker image with SHA: ${GIT_SHA}"

                    sh '''
                        docker build \
                          --build-arg APP_KEY=$APP_KEY \
                          -t ${REGISTRY}/${IMAGE_NAME}:${GIT_SHA} \
                          -t ${REGISTRY}/${IMAGE_NAME}:latest .
                    '''
                }
            }
        }

        stage('Login & Push to DOCR') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docr-token', url: 'https://registry.digitalocean.com']) {
                        sh '''
                            docker push ${REGISTRY}/${IMAGE_NAME}:${GIT_SHA}
                            docker push ${REGISTRY}/${IMAGE_NAME}:latest
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout registry.digitalocean.com || true'
        }
        failure {
            echo "Pipeline failed. Check logs above."
        }
    }
}