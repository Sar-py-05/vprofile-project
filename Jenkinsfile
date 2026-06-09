pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        NEXUS_IP = '172.31.95.139'
        NEXUS_REPO = 'vprofile-release'
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
                sh "mvn clean package -DskipTests -s settings.xml"
            }
        }

        stage('Test') {
            steps {
                sh "mvn test -s settings.xml"
            }
        }

        stage('Checkstyle') {
            steps {
                sh "mvn checkstyle:checkstyle -s settings.xml"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh "mvn sonar:sonar -s settings.xml"
                }
            }
        }

        stage('Archive WAR') {
            steps {
                archiveArtifacts artifacts: 'target/*.war', fingerprint: true
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
                        -DgroupId=com.visualpathit \
                        -DartifactId=vprofile \
                        -Dversion=1.0 \
                        -Dpackaging=war \
                        -Dfile=target/vprofile-v2.war \
                        -DrepositoryId=${NEXUS_REPO} \
                        -Durl=http://${NEXUS_IP}:8081/repository/${NEXUS_REPO}/ \
                        -DgeneratePom=true \
                        -s settings.xml
                    """
                }
            }
        }
    }

    post {
        success {
            echo "PIPELINE SUCCESS ✅"
        }

        failure {
            echo "PIPELINE FAILED ❌"
        }
    }
}