# Lessons Learned

## Lesson 1

TOPIC:
Jenkins Tool Configuration

WHAT HAPPENED:

Pipeline failed with:

No tool named SONARSCANNER found

LEARNING:

A tool referenced inside Jenkinsfile must exist in Jenkins Global Tool Configuration.

ACTION TAKEN:

Configured SonarScanner under:

Manage Jenkins → Global Tool Configuration

FUTURE IMPROVEMENT:

Verify all tool names before referencing them in Jenkinsfiles.

---

## Lesson 2

TOPIC:
Jenkins Disk Space Management

WHAT HAPPENED:

Jenkins node went offline.

Error:

Disk space is below threshold.

LEARNING:

Small EC2 instances can quickly run out of storage because of:

* Maven cache
* Sonar cache
* Workspaces
* Build artifacts

ACTION TAKEN:

Cleaned:

* Jenkins workspace
* Maven cache
* Old build artifacts

FUTURE IMPROVEMENT:

Add regular cleanup procedures to Runbook.

---

## Lesson 3

TOPIC:
SonarQube Scanner Selection

WHAT HAPPENED:

Initially attempted to use SonarScanner CLI.

LEARNING:

Maven projects work better with:

mvn sonar:sonar

instead of standalone sonar-scanner.

ACTION TAKEN:

Migrated Sonar stage to Maven Sonar Plugin.

FUTURE IMPROVEMENT:

Use build-tool-native scanners whenever possible.

---

## Lesson 4

TOPIC:
Jenkins Pipeline Syntax

WHAT HAPPENED:

Pipeline failed with:

Undefined section "stage"

LEARNING:

Every stage must exist inside the stages block.

ACTION TAKEN:

Moved Quality Gate stage inside stages.

FUTURE IMPROVEMENT:

Validate Jenkinsfiles before committing.

---

## Lesson 5

TOPIC:
Quality Gate Integration

WHAT HAPPENED:

Quality Gate stage generated errors.

LEARNING:

waitForQualityGate requires:

* SonarQube Scanner plugin
* Sonar webhook configuration

ACTION TAKEN:

Configured Sonar webhook.

FUTURE IMPROVEMENT:

Verify webhook immediately after Sonar installation.

---

## Lesson 6

TOPIC:
Nexus Authentication

WHAT HAPPENED:

Deployment failed with:

401 Unauthorized

LEARNING:

Repository ID in Jenkinsfile must match server ID in settings.xml.

ACTION TAKEN:

Aligned:

repositoryId = vprofile-release

with:

<server>
  <id>vprofile-release</id>
</server>

FUTURE IMPROVEMENT:

Keep repository IDs standardized.

---

## Lesson 7

TOPIC:
Maven Settings Configuration

WHAT HAPPENED:

Build failed while downloading Maven plugins.

LEARNING:

Hosted repositories should never be configured as Maven mirrors.

ACTION TAKEN:

Changed mirror to:

vpro-maven-group

instead of:

vprofile-release

FUTURE IMPROVEMENT:

Use Nexus Group Repositories for dependency downloads.

---

## Lesson 8

TOPIC:
Release Repository Behavior

WHAT HAPPENED:

Deployment failed with:

400 Artifact cannot be updated

LEARNING:

Release repositories are immutable.

Existing versions cannot be overwritten.

ACTION TAKEN:

Introduced unique artifact versioning.

FUTURE IMPROVEMENT:

Never use hardcoded versions.

---

## Lesson 9

TOPIC:
Dynamic Artifact Versioning

WHAT HAPPENED:

Repeated deployments caused Nexus conflicts.

LEARNING:

Static versions eventually break CI pipelines.

ACTION TAKEN:

Introduced dynamic versions using:

BUILD_NUMBER

and

BUILD_TIMESTAMP

FUTURE IMPROVEMENT:

Adopt centralized artifactVersion variables.

---

## Lesson 10

TOPIC:
Artifact Discovery

WHAT HAPPENED:

Pipeline failed because WAR filename changed.

LEARNING:

Hardcoded artifact paths create maintenance problems.

ACTION TAKEN:

Used:

find target -name "*.war"

to dynamically locate WAR files.

FUTURE IMPROVEMENT:

Avoid hardcoded build outputs.

---

## Lesson 11

TOPIC:
Resource Constraints

WHAT HAPPENED:

SonarQube analysis stalled repeatedly.

LEARNING:

Sonar analysis is resource intensive.

ACTION TAKEN:

Upgraded Jenkins instance.

FUTURE IMPROVEMENT:

Size infrastructure according to workload.

---

## Lesson 12

TOPIC:
Instance Sizing

WHAT HAPPENED:

t3.small became unstable under CI load.

LEARNING:

Build servers require sufficient CPU and memory.

ACTION TAKEN:

Migrated to larger EC2 instance.

FUTURE IMPROVEMENT:

Perform capacity planning before implementation.

---

## Lesson 13

TOPIC:
Jenkins Cache Management

WHAT HAPPENED:

Disk usage increased continuously.

LEARNING:

Build tools generate large caches.

Examples:

* .m2
* .sonar
* workspaces

ACTION TAKEN:

Added cleanup procedures.

FUTURE IMPROVEMENT:

Automate cleanup tasks.

---

## Lesson 14

TOPIC:
Sonar JavaScript Analysis

WHAT HAPPENED:

SonarQube hung during JS analysis.

LEARNING:

Frontend analysis may consume significant resources.

ACTION TAKEN:

Excluded unnecessary JS/TS scanning.

FUTURE IMPROVEMENT:

Analyze only required source code.

---

## Lesson 15

TOPIC:
Pipeline Reliability

WHAT HAPPENED:

Failures required manual investigation.

LEARNING:

Structured logging significantly reduces troubleshooting time.

ACTION TAKEN:

Added:

echo statements

and stage-level visibility.

FUTURE IMPROVEMENT:

Standardize logging across pipelines.

---

## Lesson 16

TOPIC:
Documentation

WHAT HAPPENED:

Repeated issues required remembering old fixes.

LEARNING:

Documenting failures is as valuable as documenting success.

ACTION TAKEN:

Created:

* README.md
* architecture.md
* deployment-guide.md
* runbook.md
* troubleshooting.md
* lessons-learned.md

FUTURE IMPROVEMENT:

Apply the same documentation framework to every project.

---

## Lesson 17

TOPIC:
CI/CD Design

WHAT HAPPENED:

Pipeline evolved significantly during implementation.

LEARNING:

A production-style pipeline should include:

* Checkout
* Build
* Test
* Static Analysis
* Quality Gate
* Artifact Repository
* Cleanup

ACTION TAKEN:

Implemented complete CI workflow.

FUTURE IMPROVEMENT:

Extend pipeline toward:

* Docker
* ECR
* Kubernetes
* Helm
* ArgoCD

---

## Lesson 18

TOPIC:
Version Standardization

WHAT HAPPENED:

Different components required artifact versions.

LEARNING:

A single version variable should drive:

* Nexus artifacts
* Docker tags
* Helm charts
* Kubernetes deployments
* GitOps releases

ACTION TAKEN:

Designed centralized artifactVersion approach.

Example:

41-20260611-120112-f405721

FUTURE IMPROVEMENT:

Reuse the same version throughout the entire software delivery lifecycle.

---

## Lesson 19

TOPIC:
Infrastructure as Documentation

WHAT HAPPENED:

Troubleshooting consumed significant effort.

LEARNING:

Good documentation becomes an operational asset.

ACTION TAKEN:

Documented architecture, deployments, failures, and resolutions.

FUTURE IMPROVEMENT:

Maintain documentation alongside source code.

---

## Lesson 20

TOPIC:
Professional Growth

WHAT HAPPENED:

The project required learning unfamiliar DevOps concepts.

LEARNING:

Real-world debugging teaches more than tutorials.

ACTION TAKEN:

Resolved issues involving:

* Jenkins
* SonarQube
* Nexus
* Maven
* GitHub Webhooks
* EC2
* Linux Administration

FUTURE IMPROVEMENT:

Continue building complete end-to-end DevOps and MLOps projects using the same engineering practices.
