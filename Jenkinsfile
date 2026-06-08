pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin123'
        NEXUS_IP = '172.31.95.139'
        SOARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
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
                withCredentials([usernamePassword(
                    credentialsId: 'nexuslogin',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS'
                )]) {
                    sh """
                        java -version
                        mvn clean install -s settings.xml -DskipTests
                    """
                }
            }
            post {
                success {
                    echo 'Build successful-archiving WAR'
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test') {
            steps {
                sh "mvn -s settings.xml test"
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh "mvn -s settings.xml checkstyle:checkstyle"
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool name: "${SONARSCANNER}"
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'sonarlogin',
                    usernameVariable: 'SONAR_USER',
                    passwordVariable: 'SONAR_PASS'
                )]) {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.junit.reportPaths=target/surefire-reports/ \
                        -Dsonar.jacoco.reportPaths=target/jacoco.exec \
                        -Dsonar.checkstyle.reportPaths=target/checkstyle-result.xml \                        
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
                        -Dfile=target/vprofile-app.war \
                        -DrepositoryId=nexus-releases \
                        -Durl=http://${NEXUS_IP}:8081/repository/maven-releases/ \
                        -s settings.xml
                    """
                }
            }
        }
    }
}