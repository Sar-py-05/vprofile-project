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
