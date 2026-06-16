# vProfile CI/CD Architecture

## Overview

This project implements a complete CI/CD pipeline for the vProfile application using Jenkins, SonarQube, Nexus, Docker, Amazon ECR, and Amazon ECS.

## Architecture Flow

GitHub
↓
Jenkins
↓
Build & Package (Maven)
↓
Unit Testing
↓
Checkstyle
↓
SonarQube Analysis
↓
Quality Gate
↓
Nexus Artifact Repository
↓
Docker Image Build
↓
Amazon ECR
↓
Amazon ECS Staging
↓
Production Promotion Pipeline
↓
Amazon ECS Production

## Components

### GitHub

Stores application source code and Jenkins pipeline definitions.

### Jenkins

Responsible for:

* Source code checkout
* Build automation
* Test execution
* SonarQube integration
* Nexus deployment
* Docker image creation
* ECR image upload
* ECS deployment

### SonarQube

Performs:

* Static code analysis
* Code quality checks
* Quality Gate enforcement

### Nexus

Stores versioned WAR artifacts.

Version format:

BUILD_NUMBER-TIMESTAMP-GIT_SHA

Example:

41-20260611-120112-f405721

### Docker

Packages the application into a container image.

### Amazon ECR

Stores Docker images.

### Amazon ECS

Runs application containers in:

* Staging Environment
* Production Environment

## Branch Strategy

main
├── jenkins-ci
├── jenkins-cicd
└── prod

## CI Pipeline

Triggered automatically from GitHub commits.

## Production Pipeline

Triggered manually after staging validation.

## Security

Jenkins Credentials Store manages:

* AWS Credentials
* Nexus Credentials
* SonarQube Tokens

Secrets are never hardcoded in pipeline definitions.
