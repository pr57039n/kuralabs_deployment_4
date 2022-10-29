pipeline {
  agent any
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        python3 -m venv test3
        source test3/bin/activate
        pip install pip --upgrade
        pip install -r requirements.txt
        export FLASK_APP=application
        flask run &
        '''
     }
   }
    stage ('test') {
      steps {
        sh '''#!/bin/bash
        source test3/bin/activate
        py.test --verbose --junit-xml test-reports/results.xml
        ''' 
      }
    
      post{
        always {
          junit 'test-reports/results.xml'
        }
       
      }
    }
   
     stage('Init') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key'), 
                        string(credentialsId: 'name', variable: 'name'), 
                        string(credentialsID: 'vpc_cidr', variable: 'vpc_cidr')]) {
                            dir('intTerraform') {
                              sh 'terraform init' 
                            }
         }
    }
   }
      stage('Plan') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key'), 
                        string(credentialsId: 'name', variable: 'name'), 
                        string(credentialsID: 'vpc_cidr', variable: 'vpc_cidr')]) {
                            dir('intTerraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key" -var="vpc_cidr=$vpc_cidr" -var="name=$name"' 
                            }
         }
    }
   }
      stage('Apply') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key'), 
                        string(credentialsId: 'name', variable: 'name'), 
                        string(credentialsID: 'vpc_cidr', variable: 'vpc_cidr')]) {
                            dir('intTerraform') {
                              sh 'terraform apply plan.tfplan' 
                            }
         }
    }
   }
   stage('Notify') {
    steps {
      echo "Done"
    }
    post {
      always {
        emailext body: 'Terraform Apply complete', recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']], subject: 'Build status'
      }
    }
  }
   stage('Destroy') {
    steps {
    withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
        dir('intTerraform') {
            sh 'terraform destroy -auto-approve -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"'
            }
        }
    }
   }
   stage('Notify2') {
    steps {
      echo "Done"
    }
    post {
      always {
        emailext body: 'Terraform destroy complete', recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']], subject: 'Terraform destroy complete'
      }
    }
  }
  }
 }
