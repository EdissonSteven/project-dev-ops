pipeline {
    agent any
    
    environment {
        // Configuración de Docker Hub (o registry privado)
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_NAME = 'retailtech/product-service'
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
        
        // Configuración de Kubernetes
        K8S_NAMESPACE = "${env.BRANCH_NAME == 'main' ? 'production' : 'staging'}"
        KUBECONFIG = credentials('kubeconfig-credentials')
    }
    
    options {
        // Mantener últimos 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Timeout del pipeline
        timeout(time: 30, unit: 'MINUTES')
        
        // Deshabilitar ejecuciones concurrentes
        disableConcurrentBuilds()
        
        // Timestamps en logs
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "🔍 Clonando repositorio..."
                    checkout scm
                    
                    // Obtener información del commit
                    env.GIT_COMMIT_MSG = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()
                    
                    echo "📝 Commit: ${env.GIT_COMMIT_MSG}"
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "🐳 Construyendo imagen Docker..."
                    
                    // Build de la imagen
                    docker.build(
                        "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}",
                        "--build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') " +
                        "--build-arg VCS_REF=${env.GIT_COMMIT} " +
                        "--label org.opencontainers.image.created=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') " +
                        "--label org.opencontainers.image.revision=${env.GIT_COMMIT} " +
                        "."
                    )
                    
                    echo "✅ Imagen construida: ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    echo "🔒 Escaneando imagen por vulnerabilidades..."
                    
                    // Escaneo con Trivy
                    sh """
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            aquasec/trivy:latest image \
                            --severity HIGH,CRITICAL \
                            --exit-code 0 \
                            ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                // Solo push en branches específicos
                anyOf {
                    branch 'main'
                    branch 'develop'
                    branch 'staging'
                }
            }
            steps {
                script {
                    echo "📤 Publicando imagen a registry..."
                    
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'dockerhub-credentials') {
                        // Push con tag específico
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push()
                        
                        // Push con tag latest si es main
                        if (env.BRANCH_NAME == 'main') {
                            docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push('latest')
                        }
                        
                        // Push con tag de branch
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push(env.BRANCH_NAME)
                    }
                    
                    echo "✅ Imagen publicada exitosamente"
                }
            }
        }
        
        stage('Update Kubernetes Manifests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    echo "📝 Actualizando manifests de Kubernetes..."
                    
                    // Actualizar tag de imagen en deployment.yaml
                    sh """
                        sed -i 's|image: .*|image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}|' \
                            k8s/${K8S_NAMESPACE}/deployment.yaml
                    """
                    
                    // Commit y push de cambios (GitOps)
                    sh """
                        git config user.email "jenkins@retailtech.com"
                        git config user.name "Jenkins CD"
                        git add k8s/${K8S_NAMESPACE}/deployment.yaml
                        git commit -m "CD: Update image to ${IMAGE_TAG} [skip ci]" || true
                        git push origin HEAD:${env.BRANCH_NAME} || true
                    """
                    
                    echo "✅ Manifests actualizados (ArgoCD sincronizará automáticamente)"
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            when {
                // Deployment manual solo para staging
                branch 'develop'
            }
            steps {
                script {
                    echo "🚀 Desplegando a Kubernetes (${K8S_NAMESPACE})..."
                    
                    // Deploy usando kubectl
                    sh """
                        export KUBECONFIG=${KUBECONFIG}
                        kubectl set image deployment/product-service \
                            product-service=${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
                            -n ${K8S_NAMESPACE}
                        
                        kubectl rollout status deployment/product-service \
                            -n ${K8S_NAMESPACE} \
                            --timeout=5m
                    """
                    
                    echo "✅ Deployment exitoso en ${K8S_NAMESPACE}"
                }
            }
        }
        
        stage('Smoke Tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    echo "🧪 Ejecutando smoke tests..."
                    
                    // Health check del servicio desplegado
                    sh """
                        export KUBECONFIG=${KUBECONFIG}
                        
                        # Obtener URL del servicio
                        SERVICE_URL=\$(kubectl get svc product-service \
                            -n ${K8S_NAMESPACE} \
                            -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                        
                        # Health check
                        curl -f http://\${SERVICE_URL}/health || exit 1
                        
                        echo "✅ Smoke tests passed"
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline completado exitosamente!"
            // Aquí se puede agregar notificación a Slack, email, etc.
        }
        
        failure {
            echo "❌ Pipeline falló!"
            // Notificación de error
        }
        
        always {
            // Limpieza
            cleanWs()
            
            // Limpiar imágenes Docker no usadas
            sh 'docker image prune -f || true'
        }
    }
}
