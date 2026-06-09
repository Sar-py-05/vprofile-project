pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        NEXUS_IP = '172.31.95.139'
        SONAR_LOGIN = 'sonarlogin'
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
        }

        stage('Test') {
            steps {
                sh "mvn -s settings.xml test"
            }
        }

        stage('Checkstyle') {
            steps {
                sh "mvn -s settings.xml checkstyle:checkstyle"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarserver') {
                    sh "mvn -s settings.xml clean verify sonar:sonar"
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                withSonarQubeEnv('sonarserver') {
                sh "mvn -s settings.xml clean verify sonar:sonar"
                }
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
                        -DgroupId=com.vprofile \
                        -DartifactId=vprofile-app \
                        -Dversion=1.0.0 \
                        -Dpackaging=war \
                        -Dfile=target/*.war \
                        -DrepositoryId=nexus-releases \
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