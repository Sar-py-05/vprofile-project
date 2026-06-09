pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        NEXUS_IP = '172.31.95.139'
        MAVEN_OPTS = '-Xms256m -Xmx512m'
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
                sh "mvn clean package -DskipTests -T 1C -s settings.xml"
            }
        }

        stage('Test') {
            steps {
                sh "mvn test -T 1C -s settings.xml"
            }
        }

        stage('Checkstyle') {
            steps {
                sh "mvn checkstyle:checkstyle -T 1C -s settings.xml"
            }
        }

        stage('SonarQube') {
            steps {
                withSonarQubeEnv('sonarserver') {
                    sh """
                        mvn sonar:sonar -T 1C -s settings.xml \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.sources=src/main/java \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.exclusions=**/*.js,**/*.ts,**/*.css \
                        -Dsonar.javascript.enabled=false \
                        -Dsonar.sourceEncoding=UTF-8
                    """
                }
            }
        }

        stage('Archive WAR') {
            steps {
                archiveArtifacts artifacts: '**/*.war'
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
                        -Dfile=target/vprofile-v2.war \
                        -DgroupId=com.visualpathit \
                        -DartifactId=vprofile \
                        -Dversion=1.0 \
                        -Dpackaging=war \
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
            echo "SUCCESS"
        }
        failure {
            echo "FAILED"
        }
    }
}