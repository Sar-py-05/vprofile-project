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
