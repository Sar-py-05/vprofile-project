# Deployment Guide

## Infrastructure

### Jenkins Server

Instance Type:

* c7i-flex.large

Ports:

* 8080

Installed Components:

* Jenkins
* Maven
* JDK 17
* Git

### SonarQube Server

Ports:

* 9000

Installed Components:

* SonarQube
* PostgreSQL

### Nexus Server

Ports:

* 8081

Repositories:

* vprofile-release
* vprofile-snapshot
* vpro-maven-group

---

## Jenkins Configuration

### Global Tools

JDK:

* JDK17

Maven:

* MAVEN3.9.9

### SonarQube Configuration

Manage Jenkins
→ System
→ SonarQube Servers

Name:
sonarserver

Server URL:
http://<SONAR_IP>:9000

Authentication:
sonartoken

---

## Nexus Configuration

Create repositories:

* vprofile-release
* vprofile-snapshot

Create user:

jenkins

Grant:

nx-admin

or

Repository Upload Permissions

---

## GitHub Webhook

Payload URL:

http://<JENKINS_IP>:8080/github-webhook/

Content Type:

application/json

Event:

Push Event

---

## Pipeline Execution

Git Push
↓
Webhook Trigger
↓
Jenkins Build
↓
Quality Checks
↓
Artifact Upload
