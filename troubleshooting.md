# Troubleshooting Guide

This document contains issues encountered while implementing the VProfile CI Pipeline using GitHub, Jenkins, Maven, SonarQube, Nexus Repository Manager, and AWS EC2.

---

# Issue 1

### ERROR

No tool named SONARSCANNER found

### CAUSE

SonarScanner tool was not configured in Jenkins Global Tool Configuration.

### FIX

Navigate to:

Manage Jenkins

→ Global Tool Configuration

→ SonarQube Scanner

Create scanner installation:

Name: SONARSCANNER

Enable automatic installation.

---

# Issue 2

### ERROR

Disk space is below threshold of 1.00 GiB

### CAUSE

Jenkins workspace, Maven cache, Sonar cache, and build artifacts consumed available disk space.

### FIX

Check disk usage:

```bash
df -h

du -sh /var/lib/jenkins/*
```

Clean workspace:

```bash
sudo rm -rf /var/lib/jenkins/workspace/*
```

Remove Maven cache:

```bash
sudo rm -rf /var/lib/jenkins/.m2/repository/*
```

Restart Jenkins:

```bash
sudo systemctl restart jenkins
```

---

# Issue 3

### ERROR

Node offline

### CAUSE

Jenkins automatically marked the node offline because available disk space dropped below configured threshold.

### FIX

Free disk space.

Reconnect node from:

Manage Jenkins

→ Nodes

→ Built-In Node

→ Mark Online

---

# Issue 4

### ERROR

Permission denied

inside:

```bash
/var/lib/jenkins/.sonar/
```

### CAUSE

Files were created by another user.

### FIX

Correct ownership:

```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins/.sonar
```

---

# Issue 5

### ERROR

No such DSL method 'stages'

### CAUSE

Pipeline syntax error.

Stage block placed outside Declarative Pipeline structure.

### FIX

Ensure pipeline structure follows:

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
            }
        }
    }
}
```

---

# Issue 6

### ERROR

Undefined section "stage"

### CAUSE

A stage block was declared outside the stages section.

### FIX

Move the stage definition inside:

```groovy
stages {
}
```

---

# Issue 7

### ERROR

Still waiting to schedule task

Waiting for next available executor

### CAUSE

Jenkins executor unavailable.

Possible reasons:

* Node offline
* Jenkins overloaded
* Executor disabled

### FIX

Verify node status.

Verify available executors.

Verify disk space.

Restart Jenkins if necessary.

---

# Issue 8

### ERROR

status code 401 Unauthorized

### CAUSE

Nexus authentication failure.

Repository ID mismatch or incorrect credentials.

### FIX

Verify settings.xml:

```xml
<server>
    <id>vprofile-release</id>
    <username>admin</username>
    <password>********</password>
</server>
```

Verify Jenkins deployment configuration uses the same repository ID.

---

# Issue 9

### ERROR

Failed to deploy artifacts

status code 400

cannot be updated

### CAUSE

Artifact version already exists.

Nexus Release repositories are immutable.

### FIX

Use dynamic versioning.

Example:

```text
41-20260611-120112-f405721
```

Avoid hardcoded versions such as:

```text
1.0
1.0.1
```

---

# Issue 10

### ERROR

PluginResolutionException

### CAUSE

Incorrect Maven mirror configuration.

Maven attempted to download dependencies from Release Repository instead of Group Repository.

### FIX

Use Nexus Group Repository:

```xml
<mirror>
    <id>vpro-maven-group</id>
    <mirrorOf>*</mirrorOf>
    <url>http://NEXUS-IP:8081/repository/vpro-maven-group/</url>
</mirror>
```

---

# Issue 11

### ERROR

Could not find artifact

maven-clean-plugin

### CAUSE

settings.xml pointed to Release Repository instead of Group Repository.

Release repositories do not proxy Maven Central.

### FIX

Use Nexus Group Repository in mirror configuration.

---

# Issue 12

### ERROR

target/*.war not found

### CAUSE

WAR file name mismatch.

Pipeline expected a fixed filename.

### FIX

Use dynamic artifact detection:

```bash
WAR_FILE=$(find target -name "*.war" | head -1)
```

---

# Issue 13

### ERROR

WebSocket connection closed abnormally

### CAUSE

SonarQube JavaScript analyzer crashed due to insufficient resources.

### FIX

Increase Jenkins server resources.

Exclude JavaScript and TypeScript analysis:

```bash
-Dsonar.exclusions=**/*.js,**/*.ts
```

---

# Issue 14

### ERROR

Pipeline hangs at:

```text
WebSocket client connected on
```

### CAUSE

SonarQube JavaScript analyzer consumed excessive CPU and memory.

### FIX

Exclude JS and TS files:

```bash
-Dsonar.exclusions=**/*.js,**/*.ts,**/*.css
```

Increase Jenkins instance size.

---

# Issue 15

### ERROR

SSH connection to Jenkins server unavailable

### CAUSE

Server resource exhaustion.

High CPU or memory utilization caused the instance to become unresponsive.

### FIX

Verify:

```bash
top

free -h
```

Upgrade instance size.

Restart instance if required.

---

# Issue 16

### ERROR

Pipeline aborted during Sonar Analysis

### CAUSE

SonarQube server unreachable.

Network issue between Jenkins and SonarQube.

### FIX

Verify connectivity:

```bash
curl http://SONAR-IP:9000
```

Verify security groups.

Verify SonarQube service status.

---

# Issue 17

### ERROR

Quality Gate stage waits indefinitely

### CAUSE

SonarQube webhook not configured.

### FIX

Configure webhook:

```text
http://JENKINS-IP:8080/sonarqube-webhook/
```

SonarQube

→ Administration

→ Configuration

→ Webhooks

---

# Issue 18

### ERROR

No report-task.txt found

### CAUSE

Sonar Analysis failed before completion.

### FIX

Review SonarQube logs.

Review Jenkins console output for the first error.

Resolve analysis failure before Quality Gate stage.

---

# Issue 19

### ERROR

GitHub push does not trigger pipeline

### CAUSE

Webhook missing or misconfigured.

### FIX

Verify GitHub webhook:

```text
http://JENKINS-IP:8080/github-webhook/
```

Check webhook delivery logs.

---

# Issue 20

### ERROR

Build successful locally but fails in Jenkins

### CAUSE

Difference between local Maven settings and Jenkins Maven settings.

### FIX

Verify:

* Java version
* Maven version
* settings.xml
* Environment variables

Keep build environments consistent.

---

# Issue 21

### ERROR

Pipeline suddenly becomes slow

### CAUSE

Large Maven cache.

Large workspace.

Insufficient resources.

### FIX

Perform cleanup:

```bash
sudo rm -rf /var/lib/jenkins/workspace/*
sudo rm -rf /var/lib/jenkins/.m2/repository/*
```

Restart Jenkins.

---

# Issue 22

### ERROR

Jenkins becomes inaccessible during build

### CAUSE

Single EC2 instance running:

* Jenkins
* Maven Builds
* Sonar Analysis

Resource exhaustion.

### FIX

Increase instance size.

Recommended:

```text
Minimum: t3.medium

Preferred: c7i-flex.large
```

---

# Issue 23

### ERROR

Artifact successfully built but not uploaded

### CAUSE

Repository URL mismatch.

Repository ID mismatch.

Incorrect credentials.

### FIX

Verify:

* Nexus URL
* Repository name
* Repository ID
* Credentials

Test manually:

```bash
curl -u admin:password \
http://NEXUS-IP:8081/service/rest/v1/repositories
```

---

# Issue 24

### ERROR

SonarQube environment variables not available

### CAUSE

Incorrect SonarQube server name in Jenkinsfile.

### FIX

Verify:

```groovy
withSonarQubeEnv("sonarserver")
```

matches the configured SonarQube installation name.

---

# Issue 25

### ERROR

Pipeline fails after Jenkins restart

### CAUSE

Workspace corruption or incomplete build state.

### FIX

Clean workspace.

Trigger a fresh build.

Verify Jenkins plugins are healthy.

---

# Troubleshooting Checklist

Whenever a pipeline fails:

1. Verify Jenkins service status.
2. Verify EC2 instance health.
3. Verify disk utilization.
4. Verify memory utilization.
5. Verify SonarQube service.
6. Verify Nexus service.
7. Verify GitHub webhook delivery.
8. Verify settings.xml.
9. Verify repository IDs.
10. Verify artifact version uniqueness.
11. Verify Jenkins credentials.
12. Verify network connectivity.
13. Verify security groups.
14. Verify plugin health.
15. Review Jenkins console logs from the first error.

Following this checklist resolves the majority of CI/CD failures encountered in this project.
