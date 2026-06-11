# Operations Runbook

## Daily Health Checks

### Jenkins

Check Service

sudo systemctl status jenkins

Restart

sudo systemctl restart jenkins

Logs

sudo journalctl -u jenkins -f

---

### SonarQube

Check Service

sudo systemctl status sonar

Restart

sudo systemctl restart sonar

Logs

tail -f /opt/sonarqube/logs/sonar.log

---

### Nexus

Check Service

sudo systemctl status nexus

Restart

sudo systemctl restart nexus

Logs

tail -f /opt/nexus/sonatype-work/nexus3/log/nexus.log

---

## Verify Disk Space

df -h

---

## Verify Memory

free -h

---

## Verify CPU

top

or

htop

---

## Verify Artifact Upload

Open:

http://<NEXUS_IP>:8081/repository/vprofile-release/

Verify latest artifact version exists.

---

## Verify Sonar Analysis

Open SonarQube Dashboard.

Check:

* Bugs
* Vulnerabilities
* Code Smells
* Coverage
* Quality Gate

# Maintenance Operations *****

## Jenkins Cleanup

### Workspace Cleanup

List large workspaces

du -sh /var/lib/jenkins/workspace/*

Remove old workspaces

sudo rm -rf /var/lib/jenkins/workspace/*

---

### Maven Cache Cleanup

Check cache size

du -sh /var/lib/jenkins/.m2

Delete cache

sudo rm -rf /var/lib/jenkins/.m2/repository/*

---

### Sonar Cache Cleanup

Check size

du -sh /var/lib/jenkins/.sonar

Delete cache

sudo rm -rf /var/lib/jenkins/.sonar/cache/*

---

### Build History Cleanup

Manage Jenkins
→ Build Discarders

Recommended:

Keep:

* Last 20 builds

Discard:

* Older builds

---

## Disk Space Monitoring

Check disk usage

df -h

Check large directories

sudo du -xh /var/lib/jenkins | sort -h | tail -20

---

## Memory Monitoring

free -h

---

## Jenkins Restart

sudo systemctl restart jenkins

Verify

sudo systemctl status jenkins

---

## SonarQube Restart

sudo systemctl restart sonar

Verify

sudo systemctl status sonar

---

## Nexus Restart

sudo systemctl restart nexus

Verify

sudo systemctl status nexus
