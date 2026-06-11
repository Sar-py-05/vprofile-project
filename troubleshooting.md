# Troubleshooting Guide

## Issue 1

ERROR:
No tool named SONARSCANNER found

CAUSE:
SonarScanner tool not configured.

FIX:

Manage Jenkins
→ Global Tool Configuration

Configure SonarScanner installation.

OR

Use:

mvn sonar:sonar

instead of standalone scanner.

---

## Issue 2

ERROR:
Disk space below threshold

CAUSE:
Jenkins volume exhausted.

FIX:

Clean workspace

sudo rm -rf /var/lib/jenkins/workspace/*

Clear Maven cache

sudo rm -rf /var/lib/jenkins/.m2/repository/*

Clear Sonar cache

sudo rm -rf /var/lib/jenkins/.sonar/cache/*

---

## Issue 3

ERROR:
401 Unauthorized

CAUSE:
Repository credentials mismatch.

FIX:

Verify settings.xml

Verify repositoryId

Verify Nexus user permissions.

---

## Issue 4

ERROR:
400 Artifact cannot be updated

CAUSE:
Release repository does not allow overwriting.

FIX:

Use unique artifact versions.

Example:

41-20260611-120112-f405721

---

## Issue 5

ERROR:
WebSocket client connected on...

Pipeline hangs.

CAUSE:
Low memory on Jenkins server.

FIX:

Increase instance size.

Move from t3.small to c7i-flex.large.

Reduce Sonar workload:

-Dsonar.exclusions=**/*.js,**/*.ts

---

## Issue 6

ERROR:
PluginResolutionException

CAUSE:
Incorrect Maven mirror configuration.

FIX:

Use Nexus Group Repository.

Example:

vpro-maven-group

instead of release repository as mirror.


# Additional Issues

## Issue 7

ERROR:

No tool named SONARSCANNER found

CAUSE:

Jenkins Global Tool Configuration missing.

FIX:

Use Maven Sonar plugin or configure SonarScanner tool.

---

## Issue 8

ERROR:

report-task.txt not found

CAUSE:

Sonar analysis failed before completion.

FIX:

Review Sonar stage logs.

Verify Sonar server connectivity.

---

## Issue 9

ERROR:

Node offline

CAUSE:

Disk threshold exceeded.

FIX:

Clean workspace.

Clean Maven cache.

Increase EC2 size if necessary.

---

## Issue 10

ERROR:

Permission denied

/var/lib/jenkins/.sonar

CAUSE:

Files owned by root.

FIX:

sudo chown -R jenkins:jenkins /var/lib/jenkins/.sonar

---

## Issue 11

ERROR:

WebSocket client connected on ...

Pipeline hangs

CAUSE:

Insufficient CPU/RAM during Sonar analysis.

FIX:

Increase instance size.

Exclude JS/TS analysis.

---

## Issue 12

ERROR:

PluginResolutionException

CAUSE:

Mirror pointing to release repository.

FIX:

Point Maven mirror to group repository.

Example:

vpro-maven-group

---

## Issue 13

ERROR:

*.war not found

CAUSE:

Incorrect artifact path.

FIX:

Verify actual WAR file name.

find target -name "*.war"

---

## Issue 14

ERROR:

401 Unauthorized

CAUSE:

Repository ID mismatch.

FIX:

Repository ID in pipeline must match settings.xml.

---

## Issue 15

ERROR:

400 Artifact cannot be updated

CAUSE:

Release repository is immutable.

FIX:

Use unique artifact version.

Example:

41-20260611-120112-f405721

---

## Issue 16

ERROR:

Undefined section stage

CAUSE:

Stage declared outside stages block.

FIX:

Ensure Quality Gate stage remains inside stages {}.

---

## Issue 17

ERROR:

No such DSL method stages

CAUSE:

Pipeline syntax corruption.

FIX:

Validate Jenkinsfile structure and braces.
