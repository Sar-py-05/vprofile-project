# Deployment Guide

## Prerequisites

* AWS Account
* Jenkins Server
* SonarQube Server
* Nexus Repository
* Docker Installed
* ECR Repository Created
* ECS Cluster Created

## Jenkins Configuration

Configure:

* JDK17
* Maven 3.9.9
* SonarQube Server
* Nexus Credentials
* AWS Credentials

## Stage Deployment

Pipeline:

GitHub
→ Jenkins
→ SonarQube
→ Nexus
→ Docker
→ ECR
→ ECS Staging

Trigger:

Build Now

or

Git Push

## Production Deployment

Pipeline:

Jenkins
→ ECS Production

Trigger:

Build Now

## Verify Deployment

Check ECS Service:

aws ecs describe-services

Check Tasks:

aws ecs list-tasks

Verify Application URL

Confirm:

* Application loads successfully
* Database connectivity works
* Logs show no errors

## Rollback

Redeploy previous image tag from ECR.

Example:

vprofileappimg:25

Force ECS deployment using the previous image version.
