pipeline {

    agent any

    parameters {

        choice(
            name: 'CLOUD_PROVIDER',
            choices: ['AWS', 'GCP'],
            description: 'Select the cloud provider to deploy to'
        )
    }

    options {
        disableConcurrentBuilds()
        skipDefaultCheckout(true)
        timestamps()
    }

    environment {

        // =========================================================
        // COMMON CONFIGURATION
        // =========================================================

        GITHUB_REPO = 'https://github.com/ashwiniboddu/multicloud-devsecops-platform.git'

        K8S_NAMESPACE = 'application'
        K8S_DEPLOYMENT_NAME = 'application'
        K8S_CONTAINER_NAME = 'application'
        K8S_SERVICE_NAME = 'application-service'

        HELM_RELEASE_NAME = 'application'
        HELM_CHART_PATH = 'helm/application'
        HELM_NAMESPACE = 'application'

        MONITORING_NAMESPACE = 'monitoring'
        PROMETHEUS_RELEASE = 'kube-prometheus-stack'

        APP_NAME = 'multicloud-devsecops'
        APP_NAMESPACE = 'application'


        // =========================================================
        // AWS CONFIGURATION
        // =========================================================

        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '934639816492'

        AWS_ECR_REPOSITORY = 'multicloud-devsecops-dev-app'

        AWS_ECR_REGISTRY =
            "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        AWS_IMAGE_NAME =
            "${AWS_ECR_REGISTRY}/${AWS_ECR_REPOSITORY}"

        AWS_EKS_CLUSTER_NAME =
            'multicloud-devsecops-dev-eks'


        // =========================================================
        // GCP CONFIGURATION
        // =========================================================

        GCP_REGION = 'us-east1'

        GCP_PROJECT_ID =
            'playground-s-11-bfa7194e'

        GCP_SERVICE_ACCOUNT =
            'multicloud-devsecops-jenkins@playground-s-11-bfa7194e.iam.gserviceaccount.com'

        GCP_ARTIFACT_REGISTRY_REPOSITORY =
            'multicloud-devsecops'

        GCP_ARTIFACT_REGISTRY =
            "${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}"

        GCP_IMAGE_NAME =
            "${GCP_ARTIFACT_REGISTRY}/${GCP_ARTIFACT_REGISTRY_REPOSITORY}/multicloud-devsecops"

        GCP_GKE_CLUSTER_NAME =
            'multicloud-devsecops-gke'


        // =========================================================
        // SONARQUBE
        // =========================================================

        AWS_SONAR_HOST_URL =
            'http://k8s-sonarqub-sonarqub-212bae675f-1549854921.us-east-1.elb.amazonaws.com'

        GCP_SONAR_HOST_URL =
            'http://34.120.58.247'


        // =========================================================
        // BUILD IMAGE
        // =========================================================

        IMAGE_TAG = "${BUILD_NUMBER}"
    }


    stages {


        // =========================================================
        // 1. CHECKOUT
        // =========================================================

        stage('Checkout') {

            steps {

                echo '========================================='
                echo 'Checking out source code'
                echo '========================================='

                git(
                    branch: 'main',
                    url: "${GITHUB_REPO}"
                )
            }
        }


        // =========================================================
        // 2. SET CLOUD IMAGE
        // =========================================================

        stage('Configure Cloud Variables') {

            steps {

                script {

                    if (params.CLOUD_PROVIDER == 'AWS') {

                        env.IMAGE_NAME =
                            env.AWS_IMAGE_NAME

                        env.SONAR_HOST_URL =
                            env.AWS_SONAR_HOST_URL

                        echo "Selected Cloud Provider: AWS"
                        echo "Image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"

                    } else {

                        env.IMAGE_NAME =
                            env.GCP_IMAGE_NAME

                        env.SONAR_HOST_URL =
                            env.GCP_SONAR_HOST_URL

                        echo "Selected Cloud Provider: GCP"
                        echo "Image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                    }
                }
            }
        }


        // =========================================================
        // 3. MAVEN BUILD
        // =========================================================

        stage('Maven Build') {

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


        // =========================================================
        // 4. UNIT TESTS
        // =========================================================

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


        // =========================================================
        // 5. OWASP DEPENDENCY CHECK
        // =========================================================

        stage('OWASP Dependency Check') {

            steps {

                echo '========================================='
                echo 'OWASP Dependency Check'
                echo '========================================='

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


        // =========================================================
        // 6. SONARQUBE
        // =========================================================

        stage('SonarQube Analysis') {

            steps {

                echo '========================================='
                echo 'SonarQube Analysis'
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


        // =========================================================
        // 7. TRIVY FILESYSTEM SCAN
        // =========================================================

        stage('Trivy Filesystem Scan') {

            steps {

                echo '========================================='
                echo 'Trivy Filesystem Scan'
                echo '========================================='

                sh '''
                    set -e

                    trivy fs \
                        --scanners vuln,secret \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        --no-progress \
                        .
                '''
            }
        }


        // =========================================================
        // 8. DOCKER BUILD
        // =========================================================

        stage('Docker Build') {

            steps {

                echo '========================================='
                echo 'Docker Build'
                echo '========================================='

                dir('application') {

                    sh '''
                        set -e

                        echo "Building:"
                        echo "${IMAGE_NAME}:${IMAGE_TAG}"

                        docker build \
                            -t ${IMAGE_NAME}:${IMAGE_TAG} \
                            .
                    '''
                }
            }
        }


        // =========================================================
        // 9. TRIVY IMAGE SCAN
        // =========================================================

        stage('Trivy Image Scan') {

            steps {

                echo '========================================='
                echo 'Trivy Docker Image Scan'
                echo '========================================='

                sh '''
                    set -e

                    docker image inspect \
                        ${IMAGE_NAME}:${IMAGE_TAG} \
                        > /dev/null

                    trivy image \
                        --scanners vuln \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        --no-progress \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }


        // =========================================================
        // ======================== AWS ============================
        // =========================================================


        // =========================================================
        // 10A. AWS ECR LOGIN
        // =========================================================

        stage('AWS - Login to ECR') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'AWS'
                }
            }

            steps {

                sh '''
                    set -e

                    aws ecr get-login-password \
                        --region ${AWS_REGION} |
                    docker login \
                        --username AWS \
                        --password-stdin ${AWS_ECR_REGISTRY}
                '''
            }
        }


        // =========================================================
        // 11A. AWS PUSH IMAGE
        // =========================================================

        stage('AWS - Push Image') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'AWS'
                }
            }

            steps {

                sh '''
                    set -e

                    docker push \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }


        // =========================================================
        // 12A. AWS CONFIGURE EKS
        // =========================================================

        stage('AWS - Configure EKS') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'AWS'
                }
            }

            steps {

                sh '''
                    set -e

                    aws eks update-kubeconfig \
                        --region ${AWS_REGION} \
                        --name ${AWS_EKS_CLUSTER_NAME}

                    kubectl get nodes
                '''
            }
        }


        // =========================================================
        // 13A. AWS DEPLOY APPLICATION
        // =========================================================

        stage('AWS - Deploy Application') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'AWS'
                }
            }

            steps {

                sh '''
                    set -e

                    helm upgrade --install \
                        ${HELM_RELEASE_NAME} \
                        ${HELM_CHART_PATH} \
                        --namespace ${HELM_NAMESPACE} \
                        --create-namespace \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG} \
                        --wait \
                        --timeout 10m
                '''
            }
        }


        // =========================================================
        // 14A. AWS VERIFY APPLICATION
        // =========================================================

        stage('AWS - Verify Application') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'AWS'
                }
            }

            steps {

                sh '''
                    set -e

                    kubectl -n ${HELM_NAMESPACE} \
                        rollout status \
                        deployment/${K8S_DEPLOYMENT_NAME} \
                        --timeout=180s

                    kubectl -n ${HELM_NAMESPACE} \
                        get pods -o wide

                    DEPLOYED_IMAGE=$(kubectl \
                        -n ${HELM_NAMESPACE} \
                        get deployment ${K8S_DEPLOYMENT_NAME} \
                        -o jsonpath='{.spec.template.spec.containers[0].image}')

                    EXPECTED_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

                    echo "Deployed: ${DEPLOYED_IMAGE}"
                    echo "Expected: ${EXPECTED_IMAGE}"

                    if [ "${DEPLOYED_IMAGE}" != "${EXPECTED_IMAGE}" ]; then
                        echo "ERROR: Image mismatch"
                        exit 1
                    fi

                    kubectl -n ${HELM_NAMESPACE} \
                        wait \
                        --for=condition=Ready \
                        pods \
                        --all \
                        --timeout=120s
                '''
            }
        }


        // =========================================================
        // ======================== GCP ============================
        // =========================================================


        // =========================================================
        // 10B. GCP AUTHENTICATION
        // =========================================================

        stage('GCP - Authentication') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'GCP'
                }
            }

            steps {

                sh '''
                    set -e

                    gcloud config set project ${GCP_PROJECT_ID}

                    gcloud config set account \
                        ${GCP_SERVICE_ACCOUNT}

                    gcloud config get-value project

                    gcloud auth list
                '''
            }
        }


        // =========================================================
        // 11B. GCP ARTIFACT REGISTRY LOGIN
        // =========================================================

        stage('GCP - Login to Artifact Registry') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'GCP'
                }
            }

            steps {

                sh '''
                    set -e

                    gcloud auth print-access-token |
                    docker login \
                        -u oauth2accesstoken \
                        --password-stdin \
                        ${GCP_REGION}-docker.pkg.dev
                '''
            }
        }


        // =========================================================
        // 12B. GCP PUSH IMAGE
        // =========================================================

        stage('GCP - Push Image') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'GCP'
                }
            }

            steps {

                sh '''
                    set -e

                    docker push \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }


        // =========================================================
        // 13B. GCP CONFIGURE GKE
        // =========================================================

        stage('GCP - Configure GKE') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'GCP'
                }
            }

            steps {

                sh '''
                    set -e

                    kubectl get nodes
                '''
            }
        }


        // =========================================================
        // 14B. GCP DEPLOY APPLICATION
        // =========================================================

        stage('GCP - Deploy Application') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'GCP'
                }
            }

            steps {

                sh '''
                    set -e

                    helm upgrade --install \
                        ${HELM_RELEASE_NAME} \
                        ${HELM_CHART_PATH} \
                        --namespace ${HELM_NAMESPACE} \
                        --create-namespace \
                        -f ${HELM_CHART_PATH}/values-gcp.yaml \
                        --set image.repository=${IMAGE_NAME} \
                        --set image.tag=${IMAGE_TAG} \
                        --wait \
                        --timeout 10m
                '''
            }
        }


        // =========================================================
        // 15B. GCP VERIFY APPLICATION
        // =========================================================

        stage('GCP - Verify Application') {

            when {

                expression {
                    params.CLOUD_PROVIDER == 'GCP'
                }
            }

            steps {

                sh '''
                    set -e

                    kubectl -n ${HELM_NAMESPACE} \
                        rollout status \
                        deployment/${K8S_DEPLOYMENT_NAME} \
                        --timeout=180s

                    kubectl -n ${HELM_NAMESPACE} \
                        get pods -o wide

                    DEPLOYED_IMAGE=$(kubectl \
                        -n ${HELM_NAMESPACE} \
                        get deployment ${K8S_DEPLOYMENT_NAME} \
                        -o jsonpath='{.spec.template.spec.containers[0].image}')

                    EXPECTED_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

                    echo "Deployed: ${DEPLOYED_IMAGE}"
                    echo "Expected: ${EXPECTED_IMAGE}"

                    if [ "${DEPLOYED_IMAGE}" != "${EXPECTED_IMAGE}" ]; then
                        echo "ERROR: Image mismatch"
                        exit 1
                    fi

                    kubectl -n ${HELM_NAMESPACE} \
                        wait \
                        --for=condition=Ready \
                        pods \
                        --all \
                        --timeout=120s
                '''
            }
        }


        // =========================================================
        // 16. CREATE MONITORING NAMESPACE
        // =========================================================

        stage('Create Monitoring Namespace') {

            steps {

                sh '''
                    set -e

                    kubectl apply \
                        -f monitoring/namespace.yaml

                    echo "Monitoring namespace ready."
                '''
            }
        }


        // =========================================================
        // 17. MONITORING HELM REPOSITORY
        // =========================================================

        stage('Configure Monitoring Helm Repository') {

            steps {

                sh '''
                    set -e

                    helm repo add prometheus-community \
                        https://prometheus-community.github.io/helm-charts \
                        --force-update

                    helm repo update
                '''
            }
        }


        // =========================================================
        // 18. VALIDATE MONITORING
        // =========================================================

        stage('Validate Monitoring Helm') {

            steps {

                sh '''
                    set -e

                    if [ "${CLOUD_PROVIDER}" = "AWS" ]; then

                        helm template \
                            ${PROMETHEUS_RELEASE} \
                            prometheus-community/kube-prometheus-stack \
                            --namespace ${MONITORING_NAMESPACE} \
                            -f monitoring/prometheus/values.yaml \
                            -f monitoring/grafana/values.yaml \
                            > /tmp/monitoring-rendered.yaml

                    else

                        helm template \
                            ${PROMETHEUS_RELEASE} \
                            prometheus-community/kube-prometheus-stack \
                            --namespace ${MONITORING_NAMESPACE} \
                            -f monitoring/prometheus/values.yaml \
                            -f monitoring/grafana/values-gcp.yaml \
                            > /tmp/monitoring-rendered.yaml

                    fi

                    test -s /tmp/monitoring-rendered.yaml

                    echo "Monitoring Helm validation successful."
                '''
            }
        }


        // =========================================================
        // 19. DEPLOY MONITORING STACK
        // =========================================================

        stage('Deploy Monitoring Stack') {

            steps {

                sh '''
                    set -e

                    if [ "${CLOUD_PROVIDER}" = "AWS" ]; then

                        helm upgrade --install \
                            ${PROMETHEUS_RELEASE} \
                            prometheus-community/kube-prometheus-stack \
                            --namespace ${MONITORING_NAMESPACE} \
                            --create-namespace \
                            -f monitoring/prometheus/values.yaml \
                            -f monitoring/grafana/values.yaml \
                            --wait \
                            --timeout 15m

                    else

                        helm upgrade --install \
                            ${PROMETHEUS_RELEASE} \
                            prometheus-community/kube-prometheus-stack \
                            --namespace ${MONITORING_NAMESPACE} \
                            --create-namespace \
                            -f monitoring/prometheus/values.yaml \
                            -f monitoring/grafana/values-gcp.yaml \
                            --wait \
                            --timeout 15m

                    fi
                '''
            }
        }


        // =========================================================
        // 20. DEPLOY GRAFANA DASHBOARDS
        // =========================================================

        stage('Deploy Grafana Dashboards') {

            steps {

                sh '''
                    set -e

                    echo "Deploying Grafana dashboards..."

                    kubectl apply \
                        -f monitoring/grafana/dashboards-configmap.yaml

                    echo "Grafana dashboard ConfigMap:"

                    kubectl get configmap \
                        grafana-dashboards \
                        -n ${MONITORING_NAMESPACE}

                    echo "Grafana dashboards deployed successfully."
                '''
            }
        }


        // =========================================================
        // 21. MONITORING INGRESS
        // =========================================================

        stage('Deploy Monitoring Ingress') {

            steps {

                sh '''
                    set -e

                    if [ "${CLOUD_PROVIDER}" = "AWS" ]; then

                        kubectl apply \
                            -f monitoring/ingress.yaml

                    else

                        helm template \
                            monitoring-ingress \
                            monitoring \
                            --namespace ${MONITORING_NAMESPACE} \
                            -f monitoring/values-gcp.yaml \
                            --show-only templates/ingress.yaml |
                        kubectl apply -f -

                    fi
                '''
            }
        }


        // =========================================================
        // 22. WAIT FOR MONITORING
        // =========================================================

        stage('Wait for Monitoring') {

            steps {

                sh '''
                    set -e

                    kubectl wait \
                        --for=condition=Ready \
                        pod \
                        -l app.kubernetes.io/name=grafana \
                        -n ${MONITORING_NAMESPACE} \
                        --timeout=10m

                    kubectl get pods \
                        -n ${MONITORING_NAMESPACE}
                '''
            }
        }


        // =========================================================
        // 23. VERIFY MONITORING
        // =========================================================

        stage('Verify Monitoring') {

            steps {

                sh '''
                    set -e

                    echo "===== MONITORING PODS ====="

                    kubectl get pods \
                        -n ${MONITORING_NAMESPACE} \
                        -o wide

                    echo ""

                    echo "===== MONITORING SERVICES ====="

                    kubectl get services \
                        -n ${MONITORING_NAMESPACE}

                    echo ""

                    echo "===== GRAFANA ====="

                    kubectl get pods \
                        -n ${MONITORING_NAMESPACE} \
                        -l app.kubernetes.io/name=grafana

                    echo ""

                    echo "===== PROMETHEUS ====="

                    kubectl get pods \
                        -n ${MONITORING_NAMESPACE} \
                        -l app.kubernetes.io/name=prometheus

                    echo ""

                    echo "===== DASHBOARDS ====="

                    kubectl get configmaps \
                        -n ${MONITORING_NAMESPACE} \
                        -l grafana_dashboard=1

                    echo ""

                    echo "===== INGRESS ====="

                    kubectl get ingress \
                        -n ${MONITORING_NAMESPACE}
                '''
            }
        }
    }


    // =============================================================
    // POST ACTIONS
    // =============================================================

    post {

        success {

            echo """
=========================================================
CI/CD PIPELINE SUCCESSFUL
=========================================================

Cloud Provider:
${CLOUD_PROVIDER}

Application:
${APP_NAME}

Namespace:
${APP_NAMESPACE}

Docker Image:
${IMAGE_NAME}:${IMAGE_TAG}

Monitoring:
${MONITORING_NAMESPACE}

=========================================================
"""
        }

        failure {

            echo """
=========================================================
CI/CD PIPELINE FAILED
=========================================================

Cloud Provider:
${CLOUD_PROVIDER}

Check the failed stage and Jenkins console output.

=========================================================
"""
        }

        always {

            echo 'Pipeline execution completed.'

            sh '''
                docker image prune -f || true
            '''
        }
    }
}