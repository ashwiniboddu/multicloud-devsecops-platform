pipeline {

    agent any


    // =========================================================
    // PARAMETERS
    // =========================================================

    parameters {

        string(
            name: 'IMAGE_TAG',
            defaultValue: '',
            description: 'Docker image tag. Leave empty to use Jenkins BUILD_NUMBER.'
        )

        choice(
            name: 'ENVIRONMENT',
            choices: [
                'dev'
            ],
            description: 'Deployment environment'
        )

    }


    // =========================================================
    // ENVIRONMENT VARIABLES
    // =========================================================

    environment {

        AWS_REGION = 'us-east-1'

        AWS_ACCOUNT_ID = ''

        ECR_REGISTRY = ''

        ECR_REPOSITORY = 'multicloud-devsecops-app'

        EKS_CLUSTER_NAME = 'multicloud-devsecops-dev-eks'

        KUBERNETES_NAMESPACE = 'application'

        HELM_RELEASE_NAME = 'multicloud-devsecops'

        HELM_CHART_PATH = 'helm/multicloud-devsecops'

        IMAGE_TAG = "${params.IMAGE_TAG ?: env.BUILD_NUMBER}"

        DOCKER_IMAGE = ''

        NOTIFICATION_EMAIL = 'ashwiniboddu04@gmail.com'

    }


    // =========================================================
    // PIPELINE STAGES
    // =========================================================

    stages {


        // =====================================================
        // 1. CHECKOUT
        // =====================================================

        stage('Checkout') {

            steps {

                echo 'Checking out source code from GitHub...'

                checkout scm

            }

        }


        // =====================================================
        // 2. INITIALIZE BUILD VARIABLES
        // =====================================================

        stage('Initialize Build') {

            steps {

                script {

                    env.AWS_ACCOUNT_ID = sh(
                        script: '''
                            aws sts get-caller-identity \
                            --query Account \
                            --output text
                        ''',
                        returnStdout: true
                    ).trim()


                    env.ECR_REGISTRY =
                        "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"


                    env.DOCKER_IMAGE =
                        "${env.ECR_REGISTRY}/${env.ECR_REPOSITORY}:${env.IMAGE_TAG}"


                    echo "AWS Account ID: ${env.AWS_ACCOUNT_ID}"

                    echo "ECR Registry: ${env.ECR_REGISTRY}"

                    echo "Docker Image: ${env.DOCKER_IMAGE}"

                }

            }

        }


        // =====================================================
        // 3. RUN UNIT TESTS
        // =====================================================

        stage('Run Unit Tests') {

            steps {

                dir('application') {

                    sh '''
                        mvn clean test
                    '''

                }

            }

            post {

                always {

                    junit(
                        testResults: 'application/target/surefire-reports/*.xml',
                        allowEmptyResults: true
                    )

                }

            }

        }


        // =====================================================
        // 4. BUILD APPLICATION
        // =====================================================

        stage('Build Application') {

            steps {

                dir('application') {

                    sh '''
                        mvn clean package -DskipTests
                    '''

                }

            }

        }


        // =====================================================
        // 5. SONARQUBE ANALYSIS
        // =====================================================

        stage('SonarQube Analysis') {

            steps {

                dir('application') {

                    withSonarQubeEnv('SonarQube') {

                        sh '''
                            mvn sonar:sonar \
                            -Dsonar.projectKey=multicloud-devsecops \
                            -Dsonar.projectName=multicloud-devsecops
                        '''

                    }

                }

            }

        }


        // =====================================================
        // 6. SONARQUBE QUALITY GATE
        // =====================================================

        stage('Quality Gate') {

            steps {

                timeout(
                    time: 5,
                    unit: 'MINUTES'
                ) {

                    waitForQualityGate(
                        abortPipeline: true
                    )

                }

            }

        }


        // =====================================================
        // 7. TRIVY FILESYSTEM SCAN
        // =====================================================

        stage('Trivy Filesystem Scan') {

            steps {

                dir('application') {

                    sh '''
                        trivy fs \
                        --exit-code 1 \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        .
                    '''

                }

            }

        }


        // =====================================================
        // 8. DOCKER BUILD
        // =====================================================

        stage('Build Docker Image') {

            steps {

                dir('application') {

                    sh """
                        docker build \
                        -t ${DOCKER_IMAGE} \
                        .
                    """

                }

            }

        }


        // =====================================================
        // 9. TRIVY DOCKER IMAGE SCAN
        // =====================================================

        stage('Trivy Image Scan') {

            steps {

                sh """
                    trivy image \
                    --exit-code 1 \
                    --severity HIGH,CRITICAL \
                    --ignore-unfixed \
                    ${DOCKER_IMAGE}
                """

            }

        }


        // =====================================================
        // 10. LOGIN TO AMAZON ECR
        // =====================================================

        stage('Login to ECR') {

            steps {

                sh """
                    aws ecr get-login-password \
                    --region ${AWS_REGION} | \
                    docker login \
                    --username AWS \
                    --password-stdin \
                    ${ECR_REGISTRY}
                """

            }

        }


        // =====================================================
        // 11. PUSH IMAGE TO ECR
        // =====================================================

        stage('Push Image to ECR') {

            steps {

                sh """

                    docker push \
                    ${DOCKER_IMAGE}

                """

            }

        }


        // =====================================================
        // 12. UPDATE EKS KUBECONFIG
        // =====================================================

        stage('Configure EKS Access') {

            steps {

                sh """

                    aws eks update-kubeconfig \
                    --region ${AWS_REGION} \
                    --name ${EKS_CLUSTER_NAME}

                """

            }

        }


        // =====================================================
        // 13. HELM LINT
        // =====================================================

        stage('Helm Lint') {

            steps {

                sh """

                    helm lint \
                    ${HELM_CHART_PATH}

                """

            }

        }


        // =====================================================
        // 14. HELM DEPLOYMENT
        // =====================================================

        stage('Deploy Application') {

            steps {

                sh """

                    helm upgrade --install \
                    ${HELM_RELEASE_NAME} \
                    ${HELM_CHART_PATH} \
                    --namespace ${KUBERNETES_NAMESPACE} \
                    --create-namespace \
                    --set image.repository=${ECR_REGISTRY}/${ECR_REPOSITORY} \
                    --set image.tag=${IMAGE_TAG} \
                    --atomic \
                    --timeout 5m

                """

            }

        }


        // =====================================================
        // 15. VERIFY DEPLOYMENT
        // =====================================================

        stage('Verify Deployment') {

            steps {

                sh """

                    kubectl rollout status \
                    deployment/${HELM_RELEASE_NAME} \
                    --namespace ${KUBERNETES_NAMESPACE} \
                    --timeout=5m

                """

            }

        }

    }


    // =========================================================
    // POST ACTIONS
    // =========================================================

    post {

    success {

        echo '''
        ==========================================
        PIPELINE SUCCESSFUL
        ==========================================
        Application successfully built,
        scanned, pushed to ECR and deployed
        to Amazon EKS.
        ==========================================
        '''

        emailext(
            subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Hello,

The Jenkins pipeline completed successfully.

Project:
${env.JOB_NAME}

Build Number:
${env.BUILD_NUMBER}

Build URL:
${env.BUILD_URL}

Environment:
${params.ENVIRONMENT}

Docker Image:
${env.DOCKER_IMAGE}

Status:
SUCCESS

The application was successfully built,
security scanned, pushed to Amazon ECR,
and deployed to Amazon EKS.

Regards,
Jenkins
            """,
            to: "${NOTIFICATION_EMAIL}"
        )

    }


    failure {

        echo '''
        ==========================================
        PIPELINE FAILED
        ==========================================
        Please review the Jenkins console output.
        ==========================================
        '''

        emailext(
            subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Hello,

The Jenkins pipeline has failed.

Project:
${env.JOB_NAME}

Build Number:
${env.BUILD_NUMBER}

Build URL:
${env.BUILD_URL}

Environment:
${params.ENVIRONMENT}

Status:
FAILED

Please review the Jenkins console output
to identify the failed stage.

Regards,
Jenkins
            """,
            to: "${NOTIFICATION_EMAIL}"
        )

    }


    unstable {

        emailext(
            subject: "UNSTABLE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Hello,

The Jenkins pipeline completed with an unstable status.

Project:
${env.JOB_NAME}

Build Number:
${env.BUILD_NUMBER}

Build URL:
${env.BUILD_URL}

Please review the Jenkins console output.

Regards,
Jenkins
            """,
            to: "${NOTIFICATION_EMAIL}"
        )

    }


    aborted {

        emailext(
            subject: "ABORTED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
Hello,

The Jenkins pipeline was aborted.

Project:
${env.JOB_NAME}

Build Number:
${env.BUILD_NUMBER}

Build URL:
${env.BUILD_URL}

Regards,
Jenkins
            """,
            to: "${NOTIFICATION_EMAIL}"
        )

    }


    always {

        echo "Build Number: ${BUILD_NUMBER}"

        echo "Build Result: ${currentBuild.currentResult}"

    }

}