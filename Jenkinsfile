pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        SONAR_SCANNER_OPTS = "-Xmx512m"
        MAVEN_OPTS = "-Xmx1024m"
        // Nexus
        NEXUSIP = '172.31.95.139'
        NEXUSPORT = '8081'
        NEXUS_REPO = 'vprofile-release'
        SNAP_REPO = 'vprofile-snapshot'

        // Jenkins credentials
        NEXUS_LOGIN = 'nexuslogin'

        // Sonar
        SONARSERVER = 'sonarserver'
        PROJECT_KEY = 'vprofile'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'jenkins-ci',
                    url: 'https://github.com/Sar-py-05/vprofile-project.git'
            }
        }

        stage('Build + Test + Package') {
            steps {
                sh "mvn clean package -s settings.xml"
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
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
                withSonarQubeEnv("${SONARSERVER}") {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=${PROJECT_KEY} \
                        -Dsonar.projectName=${PROJECT_KEY} \
                        -Dsonar.sourceEncoding=UTF-8 \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.exclusions=**/*.js,**/*.ts,**/*.css,**/target/** \
                        -Dsonar.javascript.enabled=false \
                        -Dsonar.typescript.enabled=false \
                        -s settings.xml
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${NEXUS_LOGIN}",
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
                        -Durl=http://${NEXUSIP}:${NEXUSPORT}/repository/vprofile-release/ \
                        -DgeneratePom=true \
                        -s settings.xml
                    """
                }
            }
        }
    }
}