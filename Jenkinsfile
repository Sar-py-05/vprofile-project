
pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {

        // Nexus Config
        SNAP_REPO = 'vprofile-snapshot'
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '172.31.95.139'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'

        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin123'
        NEXUS_LOGIN = 'nexuslogin'

        // Sonar Config
        SONARSERVER = 'sonarserver'
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
                sh "mvn clean install -s settings.xml -DskipTests"
            }

            post {
                success {
                    echo "Archiving WAR file..."
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
            steps {
                withSonarQubeEnv("${SONARSERVER}") {

                    sh """
                        ${SONARSCANNER}/bin/sonar-scanner \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.junit.reportPaths=target/surefire-reports \
                        -Dsonar.jacoco.reportPaths=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
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