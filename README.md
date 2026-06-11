# Prerequisites
#
- JDK 17 or 21
- Maven 3.9
# VProfile CI Pipeline Documentation

## Overview

This project implements a Continuous Integration (CI) pipeline using:

* Jenkins
* Maven
* SonarQube
* Nexus Repository Manager
* GitHub Webhooks

The pipeline performs:

1. Source Code Checkout
2. Build and Packaging
3. Unit Testing
4. Checkstyle Analysis
5. SonarQube Static Code Analysis
6. Quality Gate Validation
7. Artifact Upload to Nexus

## Architecture

GitHub
↓
Webhook
↓
Jenkins
↓
Maven Build
↓
Checkstyle
↓
SonarQube
↓
Quality Gate
↓
Nexus Repository

## Technology Stack

* Jenkins
* Maven 3.9.9
* OpenJDK 17
* SonarQube Community Edition
* Nexus Repository 3
* GitHub

## Pipeline Features

* Dynamic artifact versioning
* Build number tracking
* Timestamp tracking
* Git commit traceability
* Quality Gate enforcement
* Artifact repository integration

## Artifact Version Format

BUILD_NUMBER-TIMESTAMP-GIT_COMMIT

Example:

41-20260611-120112-f405721

This enables complete traceability between:

Deployment → Artifact → Jenkins Build → Git Commit
