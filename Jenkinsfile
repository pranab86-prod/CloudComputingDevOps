pipeline {
    agent any

    parameters {
        string(name: 'AWS_ACCESS_KEY_ID', defaultValue: '', description: 'AWS Access Key')
        password(name: 'AWS_SECRET_ACCESS_KEY', defaultValue: '', description: 'AWS Secret Key')
    }

    environment {
        GIT_REPO = 'https://github.com/pranab86-prod/CloudComputingDevOps.git'
        GIT_BRANCH = 'main'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo "🧹 Cleaning Jenkins workspace..."
                deleteDir()
            }
        }

        stage('Clone Repository') {
            steps {
                echo "📦 Cloning GitHub repository..."
                // Replace '67633823-ff86-4cf5-867f-255882b74d63' with your actual Jenkins credentials ID
                git branch: "${env.GIT_BRANCH}",
                    credentialsId: '67633823-ff86-4cf5-867f-255882b74d63',
                    url: "${env.GIT_REPO}"
            }
        }

        stage('Terraform Apply') {
            steps {
                withEnv([
                    "AWS_ACCESS_KEY_ID=${params.AWS_ACCESS_KEY_ID}",
                    "AWS_SECRET_ACCESS_KEY=${params.AWS_SECRET_ACCESS_KEY}"
                ]) {
                    sh '''
                        cd Terraform/ec2-details
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up workspace after build..."
            deleteDir()
        }
    }
}
