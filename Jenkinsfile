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
     post {
        success {
            slackSend (message: "$BUILD_TAG has moved onto the 'test' stage")
        }
        failure {
            slackSend (message: "$BUILD_TAG has failed the 'build' stage")
        }
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
       success {
            slackSend (message: "$BUILD_TAG has moved onto the 'init' stage")
        }
        failure {
            slackSend (message: "$BUILD_TAG has failed the 'test' stage")
        }
      }
    }
   
     stage('Init') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                         string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform init' 
                            }
         }
    }
    post {
        success {
            slackSend (message: "$BUILD_TAG has moved onto the 'plan' stage")
        }
        failure {
            slackSend (message: "$BUILD_TAG has failed the 'Init' stage")
        }
    }
   }
      stage('Plan') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"' 
                            }
         }
    }
    post {
        success {
            slackSend (message: "$BUILD_TAG has moved onto the 'Apply' stage")
        }
        failure {
            slackSend (message: "$BUILD_TAG has failed the 'Plan' stage")
        }
    }
   }
      stage('Apply') {
       steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
                            dir('intTerraform') {
                              sh 'terraform apply plan.tfplan' 
                            }
         }
    }
    post {
        success {
            slackSend (message: "$BUILD_TAG has completed the 'Apply' stage")
        }
        failure {
            slackSend (message: "$BUILD_TAG has failed the 'Apply' stage")
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
 
