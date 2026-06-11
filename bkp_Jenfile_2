//you'll get: something like - vprofile-33-20260611-113522.war in nexus repo.
pipeline {
    agent any

    tools {
        maven "MAVEN3.9.9"
        jdk "JDK17"
    }

    environment {
        // JVM Memory
        SONAR_SCANNER_OPTS = "-Xmx512m"
        MAVEN_OPTS = "-Xmx1024m"

        // Nexus
        NEXUSIP = '172.31.95.139'
        NEXUSPORT = '8081'
        NEXUS_REPO = 'vprofile-release'
        SNAP_REPO = 'vprofile-snapshot'

        // Jenkins Credentials
        NEXUS_LOGIN = 'nexuslogin'

        // SonarQube
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

        stage('Build + Package') {
            steps {
                sh '''
                    mvn clean package -s settings.xml
                '''
            }

            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war',
                                     fingerprint: true
                }
            }
        }

        stage('Test') {
            steps {
                sh '''
                    mvn test -s settings.xml
                '''
            }
        }

        stage('Checkstyle') {
            steps {
                sh '''
                    mvn checkstyle:checkstyle -s settings.xml
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARSERVER}") {

                    sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.sourceEncoding=UTF-8 \
                        -Dsonar.java.binaries=target/classes \
                        -Dsonar.exclusions=**/*.js,**/*.ts,**/*.css,**/target/** \
                        -Dsonar.javascript.enabled=false \
                        -Dsonar.typescript.enabled=false \
                        -s settings.xml
                    '''
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

                script {

                    def artifactVersion =
                        "${env.BUILD_NUMBER}-${new Date().format('yyyyMMdd-HHmmss')}"

                    sh """
                        WAR_FILE=\$(find target -name "*.war" | head -1)

                        echo "====================================="
                        echo "Artifact Deployment Starting"
                        echo "WAR File : \$WAR_FILE"
                        echo "Version  : ${artifactVersion}"
                        echo "====================================="

                        mvn deploy:deploy-file \
                        -DgroupId=com.visualpathit \
                        -DartifactId=vprofile \
                        -Dversion=${artifactVersion} \
                        -Dpackaging=war \
                        -Dfile=\$WAR_FILE \
                        -DrepositoryId=vprofile-release \
                        -Durl=http://${NEXUSIP}:${NEXUSPORT}/repository/vprofile-release/ \
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

        always {
            cleanWs(
                deleteDirs: true,
                disableDeferredWipeout: true
            )
        }
    }
}