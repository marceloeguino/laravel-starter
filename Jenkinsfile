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
                    sh 'echo $DOCR_TOKEN | docker login registry.digitalocean.com -u doctl --password-stdin'

                    sh '''
                        docker push ${REGISTRY}/${IMAGE_NAME}:${GIT_SHA} || true
                        docker push ${REGISTRY}/${IMAGE_NAME}:latest || true
                    '''
                }
            }
        }

        stage('Deploy to Droplet') {
            steps {
                script {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$DO_SSH chelo@192.168.31.200 bash -s << 'ENDSSH'
                        set -eux

                        # Assign Jenkins env vars to shell vars
                        APP_KEY="${APP_KEY}"
                        REGISTRY="${REGISTRY}"
                        IMAGE_NAME="${IMAGE_NAME}"
                        GIT_SHA="${GIT_SHA}"
                        DOCR_TOKEN="${DOCR_TOKEN}"

                        # Print variables for debugging
                        echo "REGISTRY: $REGISTRY"
                        echo "IMAGE_NAME: $IMAGE_NAME"
                        echo "GIT_SHA: $GIT_SHA"
                        echo "APP_KEY: $APP_KEY"
                        echo "BUILD_AT: $(date +%FT%T%z)"

                        # Login to registry
                        echo "$DOCR_TOKEN" | docker login registry.digitalocean.com -u doctl --password-stdin

                        # Pull image
                        docker pull ${REGISTRY}/${IMAGE_NAME}:${GIT_SHA}

                        # Stop & remove old container
                        docker stop hello || true
                        docker rm hello || true

                        # Run container
                        docker run -d --name hello -p 80:80 \
                            -e APP_ENV=production \
                            -e APP_KEY="$APP_KEY" \
                            -e BUILD_SHA="${GIT_SHA}" \
                            -e BUILD_AT="$(date +%FT%T%z)" \
                            --restart unless-stopped \
                            "${REGISTRY}/${IMAGE_NAME}:${GIT_SHA}"
ENDSSH
                    """
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