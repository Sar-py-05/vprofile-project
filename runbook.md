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
