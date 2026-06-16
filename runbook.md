# Operations Runbook

## Jenkins Health Check

Verify:

sudo systemctl status jenkins

Access:

http://<jenkins-ip>:8080

## SonarQube Health Check

Verify:

sudo systemctl status sonar

Access:

http://<sonarqube-ip>:9000

## Nexus Health Check

Verify:

sudo systemctl status nexus

Access:

http://<nexus-ip>:8081

## Docker Validation

docker ps

docker images

## ECR Validation

aws ecr describe-repositories

## ECS Validation

aws ecs list-clusters

aws ecs list-services --cluster <cluster-name>

## Restart Jenkins

sudo systemctl restart jenkins

## Restart Docker

sudo systemctl restart docker

## Disk Usage

df -h

## Memory Usage

free -h

## Jenkins Logs

sudo journalctl -u jenkins -f

## Docker Logs

docker logs <container-id>

## ECS Service Redeployment

aws ecs update-service 
--cluster <cluster-name> 
--service <service-name> 
--force-new-deployment

## Emergency Rollback

Deploy previously validated ECR image tag.
