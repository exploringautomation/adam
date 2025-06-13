pipeline {
    agent any

    environment {
        REGION = 'ap-south-1'
        EFS_ID = 'fs-0a3017c2f0b966a8b'
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
                        sh '''
                            echo "🚀 Building AMI..."
                            packer build \
                              -var "aws_access_key=$AWS_ACCESS_KEY_ID" \
                              -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
                              -var "efsid=$EFS_ID" \
                              -var "region=$REGION" \
                              -var "subnet_id=$SUBNET_ID" \
                              -var "ami_timestamp=$AMI_TIMESTAMP" \
                              aws-ami.json
                        '''
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
                        trivy image --input-ami $AMI_ID --format table --severity HIGH,CRITICAL || true
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

