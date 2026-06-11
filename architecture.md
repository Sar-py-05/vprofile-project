# Architecture Document

## Project Name

VProfile CI/CD Pipeline

---

# 1. Purpose

This project implements a complete CI/CD pipeline for the VProfile application using Jenkins, SonarQube, Nexus Repository Manager, Docker, AWS, Kubernetes, Helm, and ArgoCD.

The objective is to automate:

* Source Code Checkout
* Build and Unit Testing
* Code Quality Analysis
* Artifact Storage
* Container Image Creation
* Container Registry Upload
* Kubernetes Deployment
* GitOps Continuous Delivery

---

# 2. High Level Architecture

```
Developer
    |
    |
    v
GitHub Repository
    |
    | Webhook
    v
Jenkins Pipeline
    |
    +--------------------+
    |                    |
    |                    v
    |              SonarQube
    |           Code Analysis
    |
    v
Maven Build
    |
    v
WAR Artifact
    |
    v
Nexus Repository
    |
    v
Docker Build
    |
    v
Amazon ECR
    |
    v
Helm Chart Update
    |
    v
GitOps Repository
    |
    v
ArgoCD
    |
    v
Amazon EKS
```

---

# 3. Infrastructure Components

## Jenkins Server

Purpose:

* CI/CD Orchestration
* Build Automation
* Pipeline Execution

Instance Type:

* c7i-flex.large

Ports:

* 8080

Dependencies:

* JDK17
* Maven 3.9.x
* Git
* Sonar Scanner Plugin
* Nexus Integration

---

## SonarQube Server

Purpose:

* Static Code Analysis
* Code Quality Gate Validation

Ports:

* 9000

Database:

* PostgreSQL

Dependencies:

* Java 17

---

## Nexus Repository Manager

Purpose:

* Artifact Repository
* Maven Artifact Storage

Repositories:

### Hosted

* vprofile-release
* vprofile-snapshot

### Proxy

* Maven Central Proxy

### Group

* vpro-maven-group

Port:

* 8081

---

## GitHub

Purpose:

* Source Code Management
* Webhook Triggering

Branches:

* main
* jenkins-ci

---

## AWS ECR

Purpose:

* Docker Image Registry

Stores:

* Application Images

---

## Amazon EKS

Purpose:

* Kubernetes Cluster

Components:

* Worker Nodes
* Control Plane
* Networking

---

## Helm

Purpose:

* Kubernetes Package Management

Stores:

* Templates
* Values
* Deployment Configurations

---

## ArgoCD

Purpose:

* GitOps Deployment

Responsibilities:

* Monitor Git Repository
* Detect Changes
* Sync Kubernetes Cluster

---

# 4. Build Flow

## Step 1

Developer pushes code.

```
git push origin jenkins-ci
```

---

## Step 2

GitHub Webhook triggers Jenkins.

---

## Step 3

Jenkins checks out source code.

```
git clone
```

---

## Step 4

Maven Build

```
mvn clean package
```

Output:

```
target/vprofile-v2.war
```

---

## Step 5

Execute Tests

```
mvn test
```

---

## Step 6

Checkstyle Validation

```
mvn checkstyle:checkstyle
```

---

## Step 7

SonarQube Analysis

```
mvn sonar:sonar
```

Quality Gate Validation:

```
waitForQualityGate
```

---

## Step 8

Artifact Upload

Artifact Version Format:

```
BUILD_NUMBER-TIMESTAMP-GIT_COMMIT
```

Example:

```
41-20260611-120112-f405721
```

Artifact Uploaded To:

```
Nexus Release Repository
```

---

## Step 9 (Future)

Docker Build

```
docker build
```

Image Tag:

```
41-20260611-120112-f405721
```

---

## Step 10 (Future)

Push to ECR

```
docker push
```

---

## Step 11 (Future)

Update Helm values

```
values.yaml
```

Update:

```
image:
  tag: 41-20260611-120112-f405721
```

---

## Step 12 (Future)

Commit Helm Changes

GitOps Repository updated.

---

## Step 13 (Future)

ArgoCD Sync

Deployment automatically updated.

---

# 5. Versioning Strategy

Current Strategy:

```
BUILD_NUMBER-TIMESTAMP-GIT_COMMIT
```

Example:

```
41-20260611-120112-f405721
```

Benefits:

* Unique
* Traceable
* Rollback Friendly
* CI/CD Compatible

Single version variable should be reused across:

* Nexus Artifact
* Docker Image Tag
* Helm Values
* Kubernetes Deployment
* ArgoCD Deployment

---

# 6. Network Architecture

## Jenkins

```
172.31.x.x
```

Communicates With:

* GitHub
* SonarQube
* Nexus
* ECR
* EKS

---

## SonarQube

```
172.31.x.x:9000
```

Communicates With:

* Jenkins

---

## Nexus

```
172.31.x.x:8081
```

Communicates With:

* Jenkins

---

## EKS

Communicates With:

* ArgoCD
* ECR

---

# 7. Security Architecture

Credentials Stored In:

Jenkins Credentials Store

Examples:

* GitHub Token
* Nexus Credentials
* Sonar Token
* AWS Credentials

Never store:

* Passwords in Jenkinsfile
* AWS Keys in GitHub
* Tokens in Source Code

---

# 8. Monitoring Points

## Jenkins

Monitor:

* Disk Space
* Executor Availability
* Build Duration
* JVM Usage

---

## SonarQube

Monitor:

* Compute Engine Queue
* Database Size
* Memory Usage

---

## Nexus

Monitor:

* Artifact Storage
* Repository Size
* Blob Store Usage

---

## EKS

Monitor:

* Node Utilization
* Pod Status
* Resource Consumption

---

# 9. Disaster Recovery

## Jenkins

Backup:

* /var/lib/jenkins

Includes:

* Jobs
* Credentials
* Plugins
* Pipelines

---

## SonarQube

Backup:

* PostgreSQL Database
* SonarQube Configuration

---

## Nexus

Backup:

* Blob Store
* Configuration

---

# 10. Future Architecture Enhancements

Planned Improvements:

* Dockerized Jenkins
* Jenkins Shared Libraries
* Terraform Infrastructure
* ECR Image Scanning
* Trivy Security Scan
* Helm Chart Repository
* ArgoCD Multi-Environment Setup
* Prometheus Monitoring
* Grafana Dashboards
* Blue-Green Deployments
* Canary Deployments

---

# Architecture Owner

Abhishek Roy

Last Updated:

2026-06-11
