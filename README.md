<h1 align="center">kuralabs_deployment_4<h1> 
  
Performed by - Pat Reynolds

## Purpose:
To use Terraform to automate the deployment of an entire VPC; as well as an instance to then deploy a flask application into.

### Caveats
My pipeline is still not optimal at all; I can add a Pylint as mentioned before. I could add another form of integration testing as the current test just checks for a 200 success code from the application.
I could add a second availability zone + instance to the deployed VPC in order to increase availability and redundancy
Add a private subnet to improve security on that VPC instead of deploying and working solely in a public subnet.

#### Guide

1. Jenkins EC2 setup
This requires you to first install Java runtime environment. 
Add Jenkins to your package manager keyring and update it.
Install python3-pip as well as python3-venv for the build stage.
Install terraform

2.  Configuring Jenkins
In order for Terraform to actually get AWS variables; it is highly recommended to set up the AWS access/secret keys in Jenkins as secret text files. Alternatively you run the risk of exposing your credentials if you were to upload a tfvars file or declare them in your repository as plaintext. Add github personal access token. Add Keeprunning Plugin. Add extended email plugin. Add slack plugin

3. Create Multi-branch pipeline
Once the pipeline is added; and the Jenkinsfile in this repository is read it will do as follows.
Build - Create a virtual environment and activate it, install pip and upgrade itself before installing all libraries present in requirements.txt. It then sets the application for Flask as application.py then runs flask.
Test - Activates virtual environment and checks if the application returns a success code (200)
Init - Choosing the "InitTerraform" folder present in this repository, it attempts to initialize that directory through the shell.
Plan - Still using the "InitTerraform" folder; it now is pulling the CredentialsID for the aws secret,and access key from Jenkins and setting them as the terraform variables and attempts to do a terraform plan with all the resources and modules declared in that directory.
Apply - Assuming no errors; Terraform now will create all the outlined resources. In instance for main.tf - a userdata flag is set to run the dployment script for the flask application.
