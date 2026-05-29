pipeline {
    agent any

    environment {
        // ── Change these to your Docker Hub username ──
        DOCKERHUB_USER  = 'eshwarvenkat'
        DEV_IMAGE       = "${DOCKERHUB_USER}/project3-dev:latest"
        PROD_IMAGE      = "${DOCKERHUB_USER}/project3-prod:latest"

        // ── SSH credential IDs (add these in Jenkins > Credentials) ──
        DEV_SSH_CRED    = 'dev-ec2-ssh'
        PROD_SSH_CRED   = 'prod-ec2-ssh'

        // ── EC2 IPs (or hostnames) ──
        DEV_EC2_IP      = '3.111.38.98'    // replace with your dev EC2 IP
        PROD_EC2_IP     = '13.201.230.204'    // replace with your prod EC2 IP
    }

    stages {

        // ── 1. Clone the repo ──────────────────────────────
        stage('Clone') {
            steps {
                checkout scm
                echo "Cloned branch: ${env.BRANCH_NAME}"
            }
        }

        // ── 2. Build & push to dev Docker Hub repo ────────
        stage('Build & Push — Dev') {
            when {
                branch 'dev'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        chmod +x build.sh
                        ./build.sh ${DEV_IMAGE}
                    '''
                }
            }
        }

        // ── 3. Deploy to Dev EC2 ───────────────────────────
        stage('Deploy — Dev EC2') {
            when {
                branch 'dev'
            }
            steps {
                sshagent(credentials: ["${DEV_SSH_CRED}"]) {
                    sh '''
                        # Copy deploy files to dev EC2
                        scp -o StrictHostKeyChecking=no deploy.sh docker-compose.yml ec2-user@${DEV_EC2_IP}:~/

                        # Run deploy on dev EC2
                        ssh -o StrictHostKeyChecking=no ec2-user@${DEV_EC2_IP} "
                            chmod +x ~/deploy.sh
                            ~/deploy.sh ${DEV_IMAGE}
                        "
                    '''
                }
            }
        }

        // ── 4. Build & push to prod Docker Hub repo ───────
        stage('Build & Push — Prod') {
            when {
                branch 'master'
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        chmod +x build.sh
                        ./build.sh ${PROD_IMAGE}
                    '''
                }
            }
        }

        // ── 5. Deploy to Prod EC2 ──────────────────────────
        stage('Deploy — Prod EC2') {
            when {
                branch 'main'
            }
            steps {
                sshagent(credentials: ["${PROD_SSH_CRED}"]) {
                    sh '''
                        # Copy deploy files to prod EC2
                        scp -o StrictHostKeyChecking=no deploy.sh docker-compose.yml ec2-user@${PROD_EC2_IP}:~/

                        # Run deploy on prod EC2
                        ssh -o StrictHostKeyChecking=no ec2-user@${PROD_EC2_IP} "
                            chmod +x ~/deploy.sh
                            ~/deploy.sh ${PROD_IMAGE}
                        "
                    '''
                }
            }
        }
    }

    // ── Result notifications ───────────────────────────────
    post {
        success {
            echo "Pipeline SUCCESS on branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "Pipeline FAILED on branch: ${env.BRANCH_NAME}"
        }
    }
}

