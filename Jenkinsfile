pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'Admin@1234'
        NEXUS_IP = '172.31.95.139'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'jenkins-ci',
                url: 'https://github.com/Sar-py-05/vprofile-project.git'
            }
        }

        stage('Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexuslogin',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS')]) {

                    sh """
                    mvn clean install -s settings.xml -DskipTests
                    """
                }
            }
        }
    }
}