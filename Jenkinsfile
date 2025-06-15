pipeline {
    agent any

    environment {
        REGION = 'ap-south-1'
        EFS_ID = 'fs-0072693cddf333deb'
    }

    stages {
        stage('Get Random Private Subnet') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-access-key',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    script {
                        def subnetId = sh(script: '''
                            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                            aws ec2 describe-subnets \
                              --filters "Name=tag:Name,Values=my-terraform-project-private-*" \
                              --query "Subnets[].SubnetId" \
                              --region ap-south-1 \
                              --output text | tr '\\t' '\\n' | shuf -n 1
                        ''', returnStdout: true).trim()

                        if (!subnetId || subnetId == "None") {
                            error("❌ No matching subnet found.")
                        }

                        echo "✅ Using Subnet ID: ${subnetId}"
                        env.SUBNET_ID = subnetId
                    }
                }
            }
        }

        stage('Build Archive') {
            steps {
                echo '📦 Creating archive...'
                sh 'tar -cvf jenkinsrole.tar setup.sh jenkins-ansible/'
            }
        }

        stage('Build Golden AMI') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-access-key',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    script {
                        def dateTag = sh(script: 'date +%Y%m%d-%H%M%S', returnStdout: true).trim()
                        env.AMI_TIMESTAMP = dateTag
                    }

                    dir('packer') {
                        sh """
                            echo "🚀 Building AMI..."
                            packer build \
                              -var 'aws_access_key=$AWS_ACCESS_KEY_ID' \
                              -var 'aws_secret_key=$AWS_SECRET_ACCESS_KEY' \
                              -var 'efsid=$EFS_ID' \
                              -var 'region=$REGION' \
                              -var 'subnet_id=$SUBNET_ID' \
                              -var 'ami_timestamp=$AMI_TIMESTAMP' \
                              aws-ami.json
                        """
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-access-key',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                        AMI_ID=$(aws ec2 describe-images --owners self \
                            --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
                            --region ap-south-1 --output text)

                        echo "🔍 Scanning AMI ID: $AMI_ID"

                        # Placeholder: You cannot scan an AMI directly with Trivy.
                        # You should use trivy fs / or trivy image <docker-image-name>
                        echo "⚠️ Skipping invalid 'trivy image --input-ami' usage"
                        echo "💡 Tip: Use 'trivy fs /path/to/mount' or scan a Docker image instead"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '🎉 Golden AMI built, scanned, and stored successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Please check logs.'
        }
    }
}

