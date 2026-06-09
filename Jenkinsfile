pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {

        // Nexus
        NEXUSIP = '172.31.95.139'
        NEXUSPORT = '8081'
        NEXUS_REPO = 'vprofile-release'
        SNAP_REPO = 'vprofile-snapshot'

        NEXUS_LOGIN = 'nexuslogin'

        // SonarQube (Jenkins config name)
        SONARSERVER = 'sonarserver'

        // Jenkins Tool Name (MUST match UI exactly)
        SONARSCANNER = 'SONARSCANNER'

        // Project
        PROJECT_KEY = 'vprofile'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'jenkins-ci',
                url: 'https://github.com/Sar-py-05/vprofile-project.git'
            }
        }

        stage('Build (Single Maven Build)') {
            steps {
                sh "mvn clean install -DskipTests -s settings.xml"
            }

            post {
                success {
                    echo "Build successful → Archiving WAR"
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                }
            }
        }

        stage('Test') {
            steps {
                sh "mvn test -DskipTests -s settings.xml"
            }
        }

        stage('Checkstyle') {
            steps {
                sh "mvn checkstyle:checkstyle -DskipTests -s settings.xml"
            }
        }

        stage('SonarQube Analysis (Optimized)') {
            steps {
                script {

                    def scannerHome = tool name: "${SONARSCANNER}"

                    withSonarQubeEnv("${SONARSERVER}") {

                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=${PROJECT_KEY} \
                            -Dsonar.projectName=${PROJECT_KEY} \
                            -Dsonar.projectVersion=1.0 \
                            -Dsonar.sources=src/main/java \
                            -Dsonar.tests=src/test/java \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.junit.reportPaths=target/surefire-reports \
                            -Dsonar.coverage.jacoco.xmlReportPaths=target/jacoco.exec \
                            -Dsonar.exclusions=**/*.js,**/*.ts,**/*.css,**/target/** \
                            -Dsonar.sourceEncoding=UTF-8
                        """
                    }
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
                        -Dfile=target/*.war \
                        -DrepositoryId=${NEXUS_REPO} \
                        -Durl=http://${NEXUSIP}:${NEXUSPORT}/repository/${NEXUS_REPO}/ \
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