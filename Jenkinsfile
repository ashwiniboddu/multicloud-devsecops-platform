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
        AWS_ACCOUNT_ID = '554074174392'

        SONAR_HOST_URL = 'http://k8s-sonarqub-sonarqub-f49b8c3dc8-37370543.us-east-1.elb.amazonaws.com'

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

        // =========================================
        // HELM CONFIGURATION
        // =========================================

        HELM_RELEASE_NAME = 'application'

        HELM_CHART_PATH = 'helm/application'

        HELM_NAMESPACE = 'application'

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
                dependencyCheck(
                    odcInstallation: 'dependency-checkk',
                    nvdCredentialsId: 'nvd-api-key',
                    additionalArguments: '''
                        --scan application
                        --disableYarnAudit
                        --disableNodeAudit
                        '''
                )
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
        // STAGE 10: HELM VALIDATION
        // =========================================

        stage('Validate Helm Chart') {
        
            steps {

            echo '========================================='
            echo 'Validating Helm Chart'
            echo '========================================='

            sh '''
                set -e 

                echo "Helm version"
                helm version

                echo "Running Helm lint..."

                helm lint ${HELM_CHART_PATH}

                echo "Helm chart validation successful."
              ''' 
            }
        }


        // =========================================
        // STAGE 11: HELM DEPLOY APPLICATION
        // =========================================

        stage('Deploy Application with Helm') {

            steps {

                echo '========================================='
                echo 'Deploying Application using Helm'
                echo '========================================='

                echo "Helm Release: ${HELM_RELEASE_NAME}"
                echo "Helm Chart: ${HELM_CHART_PATH}"
                echo "Namespace: ${HELM_NAMESPACE}"
                echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"

                sh '''
                    set -e
                                                                           
                    helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_PATH} \
                        --namespace ${HELM_NAMESPACE} \
                        --create-namespace \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG} \
                       
                    echo "Helm deployment completed."
                '''
            }
        }


        // =========================================
        // STAGE 12: VERIFY HELM ROLLOUT
        // =========================================

        stage('Verify Helm Rollout') {

            steps {

                echo '========================================='
                echo 'Verifying Kubernetes Deployment Rollout'
                echo '========================================='

                sh '''
                    set -e

                    kubectl -n ${HELM_NAMESPACE} rollout status \
                        deployment/${K8S_DEPLOYMENT_NAME} \
                        --timeout=180s

                    echo "Deployment rollout completed successfully."
                '''
            }
        }


        // =========================================
        // STAGE 13: VERIFY APPLICATION
        // =========================================

        stage('Verify Application') {

            steps {

                echo '========================================='
                echo 'Verifying Application Deployment'
                echo '========================================='

                sh '''
                    set -e

                    echo "===== HELM RELEASE ====="

                    helm list \
                        --namespace ${HELM_NAMESPACE}

                    echo ""

                    echo "===== DEPLOYMENTS ====="

                    kubectl -n ${HELM_NAMESPACE} \
                        get deployments

                    echo ""

                    echo "===== PODS ====="

                    kubectl -n ${HELM_NAMESPACE} \
                        get pods -o wide

                    echo ""

                    echo "===== SERVICES ====="

                    kubectl -n ${HELM_NAMESPACE} \
                        get services

                    echo ""

                    echo "===== INGRESS ====="

                    kubectl -n ${HELM_NAMESPACE} \
                        get ingress

                    echo ""

                    echo "===== DEPLOYED IMAGE ====="

                    DEPLOYED_IMAGE=$(kubectl -n ${HELM_NAMESPACE} \
                        get deployment ${K8S_DEPLOYMENT_NAME} \
                        -o jsonpath='{.spec.template.spec.containers[0].image}')


                    echo "Deployed image:"
                    echo "${DEPLOYED_IMAGE}"

                    echo ""

                    echo "===== EXPECTED IMAGE ====="

                    EXPECTED_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"
                    
                    echo "Expected image:"
                    echo "${EXPECTED_IMAGE}"

                    echo ""
                   
                    echo "===== IMAGE VERIFICATION ====="
                    
                    if [ "${DEPLOYED_IMAGE}" != "${EXPECTED_IMAGE}" ]; then
                        echo "ERROR: Deployed image does not match expected image."
                        exit 1
                    fi

                    echo "SUCCESS: Deployed image matches expected image."

                    echo ""

                    echo "===== POD READINESS ====="
                    
                    kubectl -n ${HELM_NAMESPACE} \
                        wait \
                        --for=condition=Ready \
                        pods \
                        --all \
                        --timeout=120s
                    
                    echo "SUCCESS: All application pods are Ready."

                    echo ""

                    echo "Application deployment verification completed successfully."
                '''
            }
        }

        // =========================================
        // STAGE: CREATE MONITORING NAMESPACE
        // =========================================

        stage('Create Monitoring Namespace') {

            steps {

                echo '========================================='
                echo 'Creating Monitoring Namespace'
                echo '========================================='

                sh '''
                    set -e

                    kubectl apply \
                        -f monitoring/namespace.yaml
                '''
            }
        }

        // =========================================
        // STAGE: CONFIGURE MONITORING HELM REPOSITORY
        // =========================================

        stage('Configure Monitoring Helm Repository') {

            steps {

                echo '========================================='
                echo 'Configuring Prometheus Community Helm Repository'
                echo '========================================='

                sh '''
                    set -e

                    helm repo add prometheus-community \
                        https://prometheus-community.github.io/helm-charts \
                        --force-update

                    helm repo update

                    echo "Prometheus Community Helm repository configured successfully."
                '''
            }
        }

        // =========================================
        // STAGE: VALIDATE MONITORING HELM
        // =========================================

        stage('Validate Monitoring Helm') {

            steps {

               echo '========================================='
               echo 'Validating Monitoring Helm Configuration'
               echo '========================================='

                sh ''' 
                    set -e

                    helm template monitoring prometheus-community/kube-prometheus-stack \
                        --namespace monitoring \
                        -f monitoring/prometheus/values.yaml \
                        > /tmp/monitoring-rendered.yaml
                        
                    echo "Monitoring Helm validation successful."

                    echo "Rendered resources:"
                    grep '^kind:' /tmp/monitoring-rendered.yaml | sort | uniq -c
                '''
            } 
        }   

        // =========================================
        // STAGE: DEPLOY PROMETHEUS AND GRAFANA
        // =========================================

        stage('Deploy Monitoring Stack') {  

            steps {

                echo '========================================='
                echo 'Deploying Prometheus and Grafana'
                echo '========================================='

                sh '''
                    set -e

                    helm upgrade --install kube-prometheus-stack \
                        prometheus-community/kube-prometheus-stack \
                        --namespace monitoring \
                        --create-namespace \
                        -f monitoring/prometheus/values.yaml \
                        -f monitoring/grafana/values.yaml \
                        --wait \
                        --timeout 10m

                    echo "Prometheus and Grafana deployment completed."
                '''
            }
        }  

        // =========================================
        // STAGE: DEPLOY GRAFANA DASHBOARDS
        // =========================================

        stage('Deploy Grafana Dashboards') {

            steps {

                echo '========================================='
                echo 'Deploying Grafana Dashboards'
                echo '========================================='

                sh '''
                    set -e

                    kubectl create configmap grafana-dashboards \
                        --from-file=monitoring/grafana/dashboards/ \
                        --namespace monitoring \
                        --dry-run=client \
                        -o yaml \
                        | kubectl label --local -f - \
                            grafana_dashboard=1 \
                            -o yaml \
                        | kubectl apply -f -

                    echo "Grafana dashboards deployed successfully."
                '''
            }
        }

        // =========================================
        // STAGE: DEPLOY MONITORING INGRESS
        // =========================================

        stage('Deploy Monitoring Ingress') {       

            steps {

                echo '========================================='
                echo 'Deploying Monitoring Ingress'
                echo '========================================='

                sh '''    
                     
                    set -e

                    kubectl apply \
                        -f monitoring/ingress.yaml

                    echo "Monitoring ingress deployed successfully."
                '''
            }
        }

        // =========================================
        // STAGE: WAIT FOR MONITORING
        // =========================================

        stage('Wait for Monitoring') {

            steps {     

                echo '========================================='
                echo 'Waiting for Monitoring Components'
                echo '========================================='

                sh '''
                    set -e

                    kubectl wait \
                        --for=condition=Ready \
                        pods \
                        --all \
                        -n monitoring \
                        --timeout=600s

                    echo "All monitoring pods are ready."
                '''
            }    
        }

        // =========================================
        // STAGE: VERIFY MONITORING
        // =========================================

        stage('Verify Monitoring') {

            steps {

                echo '========================================='
                echo 'Verifying Monitoring Stack'
                echo '========================================='

                sh '''
                    
                    set -e

                    echo "===== HELM RELEASE ====="

                    helm list \
                        --namespace monitoring

                    echo ""

                    echo "===== MONITORING PODS ====="

                    kubectl get pods \
                        -n monitoring \
                        -o wide

                    echo ""

                    echo "===== SERVICES ====="

                    kubectl get services \
                        -n monitoring

                    echo ""

                    echo "===== PROMETHEUS ====="

                    kubectl get prometheus \
                        -n monitoring

                    echo ""

                    echo "===== GRAFANA DASHBOARDS ====="

                    kubectl get configmaps \
                        -n monitoring \
                        -l grafana_dashboard=1

                    echo ""

                    echo "===== MONITORING INGRESS ====="

                    kubectl get ingress \
                        -n monitoring

                    echo ""

                    echo "Monitoring verification completed successfully."
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
