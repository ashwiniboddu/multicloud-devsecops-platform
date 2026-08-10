pipeline {


    agent any

    options {
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timestamps()
    }

    environment {

        // =========================================
        // AWS CONFIGURATION
        // =========================================

        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '292139250753'

        SONAR_HOST_URL = 'k8s-sonarqub-sonarqub-f49b8c3dc8-1258490887.us-east-1.elb.amazonaws.com'

        SONAR_TOKEN = 'sonarqube-token'


        // =========================================
        // ECR CONFIGURATION
        // =========================================

        ECR_REPOSITORY = 'multicloud-devsecops-dev-app'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"


        // =========================================
        // DOCKER IMAGE CONFIGURATION
        // =========================================

        IMAGE_NAME = "${ECR_REGISTRY}/${ECR_REPOSITORY}"

        IMAGE_TAG = "${BUILD_NUMBER}"


        // =========================================
        // EKS CONFIGURATION
        // =========================================

        EKS_CLUSTER_NAME = 'multicloud-devsecops-dev-eks'


        // =========================================
        // KUBERNETES CONFIGURATION
        // =========================================

        K8S_NAMESPACE = 'application'

        K8S_DEPLOYMENT_NAME = 'application'

        K8S_CONTAINER_NAME = 'application'

        K8S_SERVICE_NAME = 'application-service'
    }


    stages {


        // =========================================
        // STAGE 1: CHECKOUT
        // =========================================
    
        stage('Checkout') {

            steps {

                echo '========================================='
                echo 'Checking out source code from GitHub'
                echo '========================================='

                git(
                    branch: 'main',
                    url: 'https://github.com/ashwiniboddu/multicloud-devsecops-platform.git'
                )
            }
        }


        // =========================================
        // STAGE 2: BUILD APPLICATION
        // =========================================

        stage('Build Application') {

            steps {

                echo '========================================='
                echo 'Building Maven Application'
                echo '========================================='

                dir('application') {

                    sh '''
                    set -e
    
                        mvn clean package -DskipTests
                '''
                }
            }

            post {

                success {

                    archiveArtifacts(
                        artifacts: 'application/target/*.war',
                        fingerprint: true
                    )
                }
            }
        }


        // =========================================
        // STAGE 3: UNIT TESTS
        // =========================================

        stage('Unit Tests') {

            steps {

                echo '========================================='
                echo 'Running Unit Tests'
                echo '========================================='

                dir('application') {

                    sh '''
                        set -e

                        mvn test -Djacoco.skip=true
                    '''
                }
            }
        }

        // =========================================
        // STAGE 4: OWASP DEPENDENCY CHECK
        // =========================================

        stage('OWASP Dependency Check') {
            steps {
                script {

                    dependencyCheck(
                        odcInstallation: 'dependency-checkk',
                        additionalArguments: '--scan application --format XML --format HTML --noupdate'
                    )

                }
            } 
        }

        stage('SonarQube Analysis') {

            steps {

            echo '========================================='
            echo 'Running SonarQube Analysis'
            echo '========================================='

            withCredentials([
                string(
                    credentialsId: 'sonarqube-token',
                    variable: 'SONAR_TOKEN'
                )
            ]) {

                dir('application') {

                    sh '''
                        set -e

                        sonar-scanner \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.token=${SONAR_TOKEN}
                    '''
                }
            }
        }
    }
        

        // =========================================
        // STAGE 4: TRIVY FILESYSTEM SCAN
        // =========================================

        stage('Trivy Filesystem Scan') {

            steps {

                echo '========================================='
                echo 'Running Trivy Filesystem Security Scan'
                echo '========================================='

                sh '''
                    set -e

                    trivy fs \
                        --scanners vuln,secret \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        .
                '''
            }
        }
        

        // =========================================
            // STAGE 5: DOCKER BUILD
        // =========================================

        stage('Docker Build') {

            steps {

                echo '========================================='
                echo 'Building Docker Image'
                echo '========================================='

                echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"

                dir('application') {
    
                    sh '''
                        set -e

                        echo "Building image:"
                        echo "${IMAGE_NAME}:${IMAGE_TAG}"

                        docker build \
                            -t ${IMAGE_NAME}:${IMAGE_TAG} \
                            -t ${IMAGE_NAME}:latest \
                            .

                        echo "Docker image build completed successfully."

                        echo "Verifying Docker images:"

                        docker images | grep "${ECR_REPOSITORY}"
                    '''
                }
            }
        }


        // =========================================
        // STAGE 6: TRIVY IMAGE SCAN
        // =========================================

        stage('Trivy Image Scan') {

            steps {

                echo '========================================='
                echo 'Running Trivy Docker Image Scan'
                echo '========================================='

                echo "Image being scanned: ${IMAGE_NAME}:${IMAGE_TAG}"

                sh '''
                    set -e

                    echo "Verifying image exists locally..."

                    docker image inspect ${IMAGE_NAME}:${IMAGE_TAG} > /dev/null

                    echo "Image found successfully."

                    echo "Starting Trivy image vulnerability scan..."

                    TRIVY_TMP="${WORKSPACE}/.trivy-tmp"
                    
                    mkdir -p "${TRIVY_TMP}"
                    
                    echo "Using Trivy temporary directory: ${TRIVY_TMP}"

                    TMPDIR="${TRIVY_TMP}" trivy image \
                        --scanners vuln \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                        
                    echo "Trivy image scan completed successfully."    
                '''
            }
        }


        // =========================================
        // STAGE 7: LOGIN TO ECR
        // =========================================

        stage('Login to Amazon ECR') {

            steps {

                echo '========================================='
                echo 'Logging in to Amazon ECR'
                echo '========================================='

                sh '''
                    set -e
    
                    aws ecr get-login-password \
                        --region ${AWS_REGION} \
                    | docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}
                '''
            }
        }


        // =========================================
        // STAGE 8: PUSH IMAGE TO ECR
        // =========================================

        stage('Push Image to ECR') {

            steps {

                echo '========================================='
                echo 'Pushing Docker Image to Amazon ECR'
                echo '========================================='

                sh '''
                    set -e

                    echo "Pushing versioned image:"
                    echo "${IMAGE_NAME}:${IMAGE_TAG}"

                    docker push ${IMAGE_NAME}:${IMAGE_TAG}

                    echo "Pushing latest image:"
                    echo "${IMAGE_NAME}:latest"

                    docker push ${IMAGE_NAME}:latest

                    echo "Docker images pushed successfully."
                '''
            }
        }


        // =========================================
        // STAGE 9: CONFIGURE EKS
        // =========================================

        stage('Configure EKS') {

            steps {

                echo '========================================='
                echo 'Configuring kubectl for Amazon EKS'
                echo '========================================='

                sh '''
                    set -e

                    aws eks update-kubeconfig \
                        --region ${AWS_REGION} \
                        --name ${EKS_CLUSTER_NAME}

                    echo "Verifying EKS cluster access..."

                    kubectl get nodes
                '''
            }
        }


        // =========================================
        // STAGE 10: CREATE KUBERNETES NAMESPACE
        // =========================================

        stage('Create Kubernetes Namespace') {

            steps {

                echo '========================================='
                echo 'Creating Kubernetes Namespace'
                echo '========================================='

                sh '''
                    set -e

                    kubectl apply \
                        -f kubernetes/namespace.yaml
                '''
            }
        }


        // =========================================
        // STAGE 11: DEPLOY CONFIGURATION
        // =========================================

        stage('Deploy Application Configuration') {

            steps {

                echo '========================================='
                echo 'Deploying ConfigMap and Secret'
                echo '========================================='

                sh '''
                    set -e

                    kubectl apply \
                    -f kubernetes/configmap.yaml

                    kubectl apply \
                    -f kubernetes/secret.yaml
                '''
            }
        }


        // =========================================
        // STAGE 12: DEPLOY APPLICATION
        // =========================================

        stage('Deploy Application to EKS') {

            steps {

                echo '========================================='
                echo 'Deploying Application to Amazon EKS'
                echo '========================================='

                sh '''
                    set -e

                    kubectl apply \
                    -f kubernetes/deployment.yaml

                    kubectl apply \
                    -f kubernetes/service.yaml
                '''
            }
        }


        // =========================================
        // STAGE 13: UPDATE IMAGE
        // =========================================

        stage('Update Application Image') {

            steps {

                echo '========================================='
                echo 'Updating Kubernetes Deployment Image'
                echo '========================================='

                echo "Updating deployment with image:"
                echo "${IMAGE_NAME}:${IMAGE_TAG}"

                sh '''
                    set -e

                    kubectl -n ${K8S_NAMESPACE} set image \
                        deployment/${K8S_DEPLOYMENT_NAME} \
                        ${K8S_CONTAINER_NAME}=${IMAGE_NAME}:${IMAGE_TAG}

                    kubectl -n ${K8S_NAMESPACE} rollout status \
                        deployment/${K8S_DEPLOYMENT_NAME} \
                        --timeout=180s
                '''
            }
        }


        // =========================================
        // STAGE 14: WAIT FOR ROLLOUT
        // =========================================

        stage('Wait for Deployment Rollout') {

            steps {

                echo '========================================='
                echo 'Waiting for Kubernetes Deployment Rollout'
                echo '========================================='

                sh '''
                    set -e

                    kubectl -n ${K8S_NAMESPACE} rollout status \
                        deployment/${K8S_DEPLOYMENT_NAME} \
                        --timeout=180s
                '''
            }
        }


        // =========================================
        // STAGE 15: VERIFY DEPLOYMENT
        // =========================================

        stage('Verify Deployment') {

            steps {

                echo '========================================='
                echo 'Verifying Kubernetes Deployment'
                echo '========================================='

                sh '''
                    set -e

                    echo "===== DEPLOYMENTS ====="

                    kubectl -n ${K8S_NAMESPACE} \
                    get deployments

                    echo "===== PODS ====="

                    kubectl -n ${K8S_NAMESPACE} \
                        get pods -o wide

                    echo "===== SERVICES ====="

                    kubectl -n ${K8S_NAMESPACE} \
                        get services
    
                    echo "===== DEPLOYMENT IMAGE ====="

                    kubectl -n ${K8S_NAMESPACE} \
                        get deployment ${K8S_DEPLOYMENT_NAME} \
                        -o jsonpath='{.spec.template.spec.containers[0].image}'

                    echo ""

                    echo "===== EXPECTED IMAGE ====="
    
                    echo "${IMAGE_NAME}:${IMAGE_TAG}"
                '''
            }
        }
    }


    // =========================================
    // POST ACTIONS
    // =========================================

    post {

        success {

            echo '=============================================='
            echo 'CI/CD PIPELINE COMPLETED SUCCESSFULLY'
            echo '=============================================='

            echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"

            echo "EKS Cluster: ${EKS_CLUSTER_NAME}"

            echo "Kubernetes Namespace: ${K8S_NAMESPACE}"

            echo "Kubernetes Deployment: ${K8S_DEPLOYMENT_NAME}"

            echo "Kubernetes Service: ${K8S_SERVICE_NAME}"
        }


        failure {

            echo '=============================================='
            echo 'CI/CD PIPELINE FAILED'
            echo '=============================================='

            echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"

            echo 'Please check the failed stage and Jenkins Console Output.'
        }


        always {

            echo '=============================================='
            echo 'Pipeline execution completed.'
            echo '=============================================='
        }
    }
}
