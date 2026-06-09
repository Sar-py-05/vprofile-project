pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        // Nexus Config
        NEXUSIP = '172.31.95.139'
        NEXUSPORT = '8081'
        NEXUS_REPO = 'vprofile-release'
        SNAP_REPO = 'vprofile-snapshot'
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin123'

        // Jenkins Credentials
        NEXUS_LOGIN = 'nexuslogin'

        // Sonar Config
        SONARSERVER = 'sonarserver'
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

        stage('Build (Single Maven Run)') {
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
                sh "mvn test -s settings.xml -DskipTests"
            }
        }

        stage('Checkstyle') {
            steps {
                sh "mvn checkstyle:checkstyle -s settings.xml"
            }
        }

        stage('SonarQube Analysis (Optimized)') {
            steps {
                withSonarQubeEnv("${SONARSERVER}") {

                    script {
                        def scannerHome = tool "${SONARSCANNER}"

                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=${PROJECT_KEY} \
                            -Dsonar.projectName=${PROJECT_KEY} \
                            -Dsonar.sources=src/main/java \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.tests=src/test/java \
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
                        -Dfile=target/vprofile-v2.war \
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