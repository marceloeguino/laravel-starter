pipeline {
    agent { label 'docker-worker' }

    parameters {
        string(name: 'ROLLBACK_SHA', defaultValue: '', description: 'Git SHA to rollback to. If set, skips build and deploy, only runs rollback + healthcheck.')
    }

    environment {
        DO_SSH     = credentials('do-ssh-key')          // SSH private key for Droplet
        DOCR_TOKEN = credentials('docr-token')          // DigitalOcean Registry token
        APP_KEY    = credentials('laravel-app-key')     // Laravel APP_KEY
        REGISTRY   = "registry.digitalocean.com/laravel-challenge"
        IMAGE_NAME = "hello-laravel"
        SSH_USER   = "laravel"
        SSH_HOST   = "10.100.0.2"
    }

    stages {

        stage('Checkout') {
            when { expression { return !params.ROLLBACK_SHA } }
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            when { expression { return !params.ROLLBACK_SHA } }
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

        stage('Login & Push') {
            when { expression { return !params.ROLLBACK_SHA } }
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

        stage('Deploy') {
            when { expression { return !params.ROLLBACK_SHA } }
            steps {
                script {
                    deployToDroplet(env.GIT_SHA)
                }
            }
        }

        stage('Rollback') {
            when { expression { return params.ROLLBACK_SHA } }
            steps {
                script {
                    echo "Rolling back to image SHA: ${params.ROLLBACK_SHA}"
                    deployToDroplet(params.ROLLBACK_SHA)
                }
            }
        }

        stage('Healthcheck') {
            steps {
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no -i \$DO_SSH ${SSH_USER}@${SSH_HOST} bash -s << 'ENDSSH'
                        set -eux

                        # Check if container is running
                        docker ps --filter "name=hello" --format "table {{.Names}}\t{{.Status}}"

                        # Healthcheck: call the Laravel health endpoint
                        HEALTH_URL="http://127.0.0.1/api/hello"
                        RESPONSE=\$(curl -s -o /dev/null -w "%{http_code}" \$HEALTH_URL)

                        if [ "\$RESPONSE" != "200" ]; then
                            echo "ERROR: Healthcheck failed, status code: \$RESPONSE"
                            exit 1
                        else
                            echo "Healthcheck passed: \$RESPONSE"
                        fi
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

//
// --- Helper function ---
//
def deployToDroplet(sha) {
    sh """
        ssh -o StrictHostKeyChecking=no -i \$DO_SSH ${SSH_USER}@${SSH_HOST} bash -s << 'ENDSSH'
        set -eux

        #APP_KEY="${APP_KEY}"
        #REGISTRY="${REGISTRY}"
        #IMAGE_NAME="${IMAGE_NAME}"
        #DOCR_TOKEN="${DOCR_TOKEN}"
        #GIT_SHA="${sha}"

        # Login to registry
        echo "\${DOCR_TOKEN}" | docker login registry.digitalocean.com -u doctl --password-stdin

        # Pull image
        docker pull \${REGISTRY}/\${IMAGE_NAME}:\${GIT_SHA}

        # Stop & remove old container
        docker stop hello || true
        docker rm hello || true

        # Run container
        docker run -d --name hello -p 80:80 \\
            -e APP_ENV=production \\
            -e APP_KEY="\$APP_KEY" \\
            -e BUILD_SHA="\${GIT_SHA}" \\
            -e BUILD_AT="\$(date +%FT%T%z)" \\
            --restart unless-stopped \\
            "\${REGISTRY}/\${IMAGE_NAME}:\${GIT_SHA}"
ENDSSH
    """
}
