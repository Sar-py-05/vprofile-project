# Lessons Learned

## Jenkins

* Monitor disk space continuously.
* Workspace cleanup is essential.
* Archive artifacts for traceability.

## SonarQube

* Small EC2 instances may struggle during analysis.
* JavaScript analysis consumes significant memory.
* Quality Gate should block bad code.

## Nexus

* Release repositories are immutable.
* Always use unique versions.
* Group repositories simplify dependency management.

## Maven

* settings.xml is critical.
* Repository IDs must match between Jenkins and Nexus.
* Mirrors should point to group repositories.

## CI/CD Best Practices

* Never deploy using "latest".
* Use dynamic versioning.
* Include build number.
* Include timestamp.
* Include Git commit ID.

Recommended Format:

BUILD_NUMBER-TIMESTAMP-GIT_COMMIT

Example:

41-20260611-120112-f405721

Benefits:

* Traceability
* Auditability
* Easy rollback
* GitOps friendly
* Production ready

## Personal Takeaways

* Debugging infrastructure teaches more than successful builds.
* Document every failure and fix.
* Create reusable templates.
* Maintain runbooks for future projects.
* Treat documentation as part of the project, not an afterthought.


# Additional Lessons Learned

## Infrastructure Lessons

### Small EC2 Instances Create Hidden Problems

t3.small was insufficient for:

* Jenkins
* Maven Build
* SonarQube Analysis

Upgrading instance size improved stability.

---

### SonarQube Is Resource Intensive

Static analysis can consume:

* CPU
* Memory
* Disk

Plan infrastructure accordingly.

---

### Nexus Release Repositories Are Immutable

Never deploy fixed versions repeatedly.

Bad:

1.0.1

Good:

41-20260611-120112-f405721

---

### Dynamic Versioning Is Essential

Benefits:

* Traceability
* Rollback
* Auditability
* GitOps compatibility

---

### Documentation Saves Time

Every failure should be documented with:

* Error
* Root Cause
* Resolution
* Prevention

---

### CI/CD Is Mostly Troubleshooting

Most implementation time was spent on:

* Jenkins configuration
* SonarQube integration
* Nexus authentication
* Maven repository configuration
* Resource constraints

Not on writing pipeline code.

---

### Reusable Templates Accelerate Future Projects

Reusable assets created:

* Jenkins Pipeline Template
* settings.xml Template
* Nexus Deployment Template
* SonarQube Integration Template

These can be reused in:

* Docker Projects
* ECR Projects
* Kubernetes Projects
* Helm Projects
* ArgoCD Projects

---

### Runbooks Are Production Assets

A runbook is not documentation.

A runbook is an operational recovery guide.

If a server fails at 2 AM, the runbook should contain the exact commands needed to restore service.
