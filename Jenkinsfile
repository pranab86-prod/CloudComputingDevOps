pipeline {
    agent any

    parameters {
        string(name: 'AWS_ACCESS_KEY_ID', defaultValue: '', description: 'AWS Access Key')
        password(name: 'AWS_SECRET_ACCESS_KEY', defaultValue: '', description: 'AWS Secret Key')
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo "Cleaning Jenkins workspace before build..."
                deleteDir()   // <-- Deletes everything in the workspace
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
}
