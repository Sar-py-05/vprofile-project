pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        NEXUS_IP = '172.31.95.139'
        NEXUS_REPO = 'vprofile-release'
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
                sh "mvn clean install -s settings.xml -DskipTests"
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
                withSonarQubeEnv('sonarserver') {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/main/java \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.exclusions=**/*.js,**/*.css,**/*.ts
                    """
                }
            }
        }

        stage('Archive WAR') {
            steps {
                archiveArtifacts artifacts: '**/*.war', fingerprint: true
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
            echo "Pipeline SUCCESS ✅"
        }
        failure {
            echo "Pipeline FAILED ❌"
        }
    }
}