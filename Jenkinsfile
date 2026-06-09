pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        NEXUS_IP = '172.31.95.139'
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin123'

        SONAR_SERVER = 'sonarserver'
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
                sh 'mvn clean install -s settings.xml -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test -s settings.xml'
            }
        }

        stage('Checkstyle') {
            steps {
                sh 'mvn checkstyle:checkstyle -s settings.xml'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh """
                        mvn clean verify sonar:sonar \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.host.url=\$SONAR_HOST_URL \
                        -Dsonar.login=\$SONAR_AUTH_TOKEN
                    """
                }
            }
        }

        stage('Deploy to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexuslogin',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS'
                )]) {

                    sh """
                        mvn deploy:deploy-file \
                        -DgroupId=com.vprofile \
                        -DartifactId=vprofile-app \
                        -Dversion=1.0.0 \
                        -Dpackaging=war \
                        -Dfile=target/*.war \
                        -DrepositoryId=vprofile-release \
                        -Durl=http://${NEXUS_IP}:8081/repository/vprofile-release/ \
                        -s settings.xml
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS 🎉"
        }
        failure {
            echo "Pipeline FAILED ❌"
        }
    }
}