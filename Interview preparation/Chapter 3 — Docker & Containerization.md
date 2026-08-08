Q1. Why was Docker introduced into this project, and what problem does it solve?

Answer:
Docker provides a consistent runtime environment for the application across development, CI, staging, and production.

Without Docker, the application depends directly on the host OS, Java version, installed libraries, configuration, and system dependencies. This can create the classic "works on my machine" problem.

In this project, Docker fits naturally after the application build stage:

Developer Code
      |
      v
   Jenkins
      |
      v
 Maven Build
      |
      v
   WAR File
      |
      v
 Docker Image
      |
      v
 Container
      |
      v
 Deployment Environment

The major benefits are:

1. Environment consistency.
2. Reproducible deployments.
3. Isolation between applications.
4. Easier application packaging.
5. Faster deployment and rollback.
6. Better integration with CI/CD.
7. Easier movement between environments.

At a senior level, I would say Docker is not simply being used to "run the application in a container"; it is being used as a packaging and deployment abstraction that makes the application environment reproducible.


Q2. What is the difference between a Docker image and a Docker container?

Answer:
A Docker image is an immutable template containing the application, runtime, libraries, dependencies, and filesystem required to run the application.

A container is a running instance of that image.

The relationship is:

Dockerfile
    |
    v
Docker Image
    |
    +----> Container 1
    |
    +----> Container 2
    |
    +----> Container 3

For example, one vprofile application image could be used to create multiple application containers.

Important distinction:

Image:
- Immutable
- Packaged artifact
- Stored locally or in a registry
- Used to create containers

Container:
- Runtime instance of an image
- Has its own writable layer
- Has a lifecycle
- Can be started, stopped, restarted, and removed

A FAANG-level answer should also mention that containers are ephemeral by design. Persistent application data should therefore not depend on the container's writable layer.


Q3. How does Docker differ from a virtual machine?

Answer:
A virtual machine virtualizes hardware, while Docker containers primarily isolate processes while sharing the host operating system kernel.

Typical VM architecture:

Hardware
   |
Hypervisor
   |
+---------+---------+
| VM      | VM      |
| Guest OS| Guest OS|
| App     | App     |
+---------+---------+

Docker architecture:

Hardware
   |
Host OS
   |
Docker Engine
   |
+---------+---------+
|Container|Container|
| App     | App     |
+---------+---------+

Containers generally have lower startup time and lower resource overhead because they do not require a separate guest operating system for every application.

However, containers are not automatically a replacement for VMs. VMs provide stronger OS-level isolation and are appropriate when separate operating systems or stronger isolation boundaries are required.


Q4. Explain the lifecycle of a Docker container.

Answer:
A typical container lifecycle is:

Image
  |
  v
docker create
  |
  v
Created
  |
  v
docker start
  |
  v
Running
  |
  +------> docker stop ------> Stopped
  |
  +------> docker restart ----> Running
  |
  +------> docker kill -------> Stopped
  |
  +------> docker rm ----------> Removed

A container can also be started directly with:

docker run

which effectively creates and starts the container.

The important concept is that stopping a container does not automatically mean its image is deleted.

Similarly, removing a container does not remove the underlying image unless explicitly requested or cleaned up.


Q5. What is a Dockerfile?

Answer:
A Dockerfile is a declarative text file containing instructions used to build a Docker image.

A simplified example is:

FROM tomcat:9

COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

The Docker build process reads these instructions and creates image layers.

The Dockerfile defines:

1. Base image.
2. Application dependencies.
3. Files copied into the image.
4. Commands executed during image creation.
5. Runtime configuration.
6. Default startup behavior.

The important architectural point is that the Dockerfile becomes part of the application's deployment definition and should therefore be version-controlled alongside the source code.


Q6. What is the purpose of the FROM instruction in a Dockerfile?

Answer:
FROM defines the base image from which the new image is constructed.

For example:

FROM tomcat:9

means that the resulting application image starts with the specified Tomcat image.

The base image provides the underlying runtime environment.

A good production practice is to:

1. Use a trusted base image.
2. Pin versions where reproducibility matters.
3. Avoid unnecessarily large images.
4. Regularly scan the base image for vulnerabilities.
5. Keep the base image updated.

Using:

FROM tomcat:latest

may appear convenient, but it can introduce unexpected changes because "latest" can point to a different image over time.

For reproducible builds, an explicitly versioned image is generally preferable.


Q7. What is the difference between RUN, CMD, and ENTRYPOINT?

Answer:
These instructions have different purposes.

RUN:
Executes a command while building the image.

Example:

RUN apt-get update

The result becomes part of the image.

CMD:
Defines the default command or arguments used when a container starts.

Example:

CMD ["catalina.sh", "run"]

ENTRYPOINT:
Defines the primary executable for the container.

Example:

ENTRYPOINT ["catalina.sh"]

A useful distinction is:

RUN = build time

CMD = default runtime command

ENTRYPOINT = main runtime executable

For example:

FROM ubuntu

RUN apt-get update

ENTRYPOINT ["java"]

CMD ["-version"]

The container effectively executes:

java -version

CMD can be overridden at runtime, whereas ENTRYPOINT is generally intended to define the container's primary executable.


Q8. What is the difference between CMD and ENTRYPOINT?

Answer:
Both influence container startup, but they are designed differently.

CMD generally provides default arguments or a default command.

ENTRYPOINT defines the main executable.

For example:

ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]

Running the container results in:

java -jar app.jar

If we provide different arguments:

docker run image -version

the effective command becomes:

java -version

This combination is useful when the container represents a specific executable.

A common senior-level consideration is that an application should normally run as the foreground process so that Docker can correctly track the application's lifecycle and receive termination signals.


Q9. What is a Docker image layer?

Answer:
Docker images are constructed from layers.

For example:

FROM ubuntu
RUN apt-get update
COPY application.jar /app/
RUN chmod +x /app/application.jar

Each filesystem-changing instruction can contribute to an image layer.

Conceptually:

Layer 4 -> application
Layer 3 -> package changes
Layer 2 -> OS configuration
Layer 1 -> base image

Layers provide:

1. Reusability.
2. Build caching.
3. Reduced storage requirements.
4. Faster image builds.
5. Efficient distribution.

If two images use the same base layers, Docker can reuse those layers instead of downloading or storing duplicates.

This is one reason Docker builds can become significantly faster after the initial build.


Q10. How does Docker build cache work?

Answer:
Docker can reuse previously generated layers when the corresponding Dockerfile instruction and relevant build context have not changed.

For example:

FROM tomcat:9

COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

If the base image has not changed, Docker can reuse that layer.

However, if the application WAR changes, the COPY layer must be rebuilt.

This means Dockerfile instruction ordering matters.

A good strategy is to place relatively stable operations earlier and frequently changing operations later.

For example:

FROM base-image

RUN install stable dependencies

COPY configuration files

COPY application artifact

This minimizes unnecessary rebuilding.

At scale, efficient layer design directly affects CI/CD build time and infrastructure cost.


Q11. What is the difference between COPY and ADD?

Answer:
Both can copy files into an image.

COPY is simpler and generally preferred when we simply need to copy files.

Example:

COPY target/vprofile-v2.war /app/

ADD has additional behavior, including handling certain archive extraction scenarios and remote-source behavior in older Docker usage patterns.

For predictable Dockerfiles, COPY is usually preferred unless ADD's specific functionality is required.

A senior engineer should avoid using ADD merely because it is shorter. Explicit behavior improves maintainability and security.


Q12. What is a Docker registry?

Answer:
A Docker registry is a repository used to store and distribute Docker images.

The architecture is:

Developer
   |
   v
Docker Build
   |
   v
Docker Image
   |
   v
Docker Registry
   |
   +------> Staging
   |
   +------> Production

Examples include:

- Docker Hub
- Amazon ECR
- GitHub Container Registry
- GitLab Container Registry
- Private enterprise registries

In a CI/CD environment, Jenkins can build an image and push it to a registry.

Deployment systems then pull the image from the registry.

This separates image creation from image execution.


Q13. Why should Docker images be stored in a registry instead of building them directly on production servers?

Answer:
Building images directly on production servers creates several problems:

1. Production becomes responsible for building software.
2. Builds may not be reproducible.
3. Source code and build tools must exist in production.
4. Deployment becomes slower.
5. Security exposure increases.
6. Rollbacks become difficult.
7. Different servers may produce different images.

A better model is:

Source Code
    |
    v
CI Pipeline
    |
    v
Build + Test
    |
    v
Docker Image
    |
    v
Registry
    |
    v
Production

Production should normally consume a tested immutable artifact rather than build the artifact itself.


Q14. How would Docker integrate with the Jenkins pipeline in this project?

Answer:
A typical integration would be:

GitHub
   |
   v
Jenkins
   |
   +--> Maven Build
   |
   +--> Unit Tests
   |
   +--> Checkstyle
   |
   +--> Sonar Analysis
   |
   +--> Package WAR
   |
   +--> Docker Build
   |
   +--> Docker Image
   |
   +--> Push to Registry
   |
   v
Deployment

For example:

docker build -t vprofile:${BUILD_ID} .

docker push registry/vprofile:${BUILD_ID}

The important principle is that Jenkins creates a versioned artifact that downstream deployment stages can consume.


Q15. Why should Docker images be tagged with a build number or immutable version rather than using latest?

Answer:
Using latest creates ambiguity.

For example:

vprofile:latest

does not tell us which source revision produced the image.

Instead:

vprofile:14

or preferably:

vprofile:git-3c9c04a

provides traceability.

A deployment can then be mapped to:

Git commit
    |
    v
Jenkins build
    |
    v
Docker image tag
    |
    v
Deployment

This makes rollback much easier.

For example:

Production
currently running:
vprofile:125

Previous stable:
vprofile:124

If build 125 has a problem, deployment can be rolled back to 124.

In production systems, immutable versioning is much safer than mutable tags.


Q16. What is the purpose of EXPOSE in a Dockerfile?

Answer:
EXPOSE documents the port on which the application expects to listen.

For example:

EXPOSE 8080

It does not itself publish the port to the host.

Publishing happens through runtime configuration, such as:

docker run -p 8080:8080 image

The distinction is:

EXPOSE:
Documentation/metadata about the intended container port.

-p:
Actually maps a host port to the container port.

This is a common interview trap.


Q17. Explain Docker port mapping.

Answer:
Suppose Tomcat inside the container listens on port 8080.

We can run:

docker run -p 8080:8080 vprofile

The format is:

host-port:container-port

Therefore:

Host 8080
    |
    v
Container 8080
    |
    v
Tomcat

A different host port can also be used:

docker run -p 9090:8080 vprofile

Now:

Client
  |
  v
Host:9090
  |
  v
Container:8080
  |
  v
Tomcat

This allows multiple containers to expose the same internal port while using different host ports.


Q18. What is the difference between Docker networking and exposing a port?

Answer:
Docker networking controls how containers communicate with each other and external systems.

EXPOSE simply documents the intended container port.

For example:

Application container
       |
       | Docker network
       v
Database container

The application can communicate with the database using the database container/service name and its internal port.

External access is a separate concern.

A production architecture often looks like:

Internet
   |
Load Balancer
   |
Application containers
   |
Private network
   |
Database

The database does not need to expose its port publicly just because the application needs to communicate with it.


Q19. What are Docker volumes, and why are they important?

Answer:
Containers are ephemeral. Data stored only inside a container's writable filesystem can disappear when the container is removed.

Volumes provide persistent storage independent of the container lifecycle.

Conceptually:

Container
   |
   v
Docker Volume
   |
   v
Persistent Data

For example, a database container should not depend on the container filesystem for critical database data.

Instead:

Database Container
       |
       v
Persistent Volume

If the container is deleted:

Container -> deleted

Volume -> remains

This allows a replacement container to attach to the same data.

For stateless application containers, external persistent storage is usually preferred for application state.


Q20. Why should application containers generally be stateless?

Answer:
A stateless container does not depend on local container state to function correctly.

This allows:

Container 1
Container 2
Container 3

to all serve the same application workload.

If Container 2 fails:

Container 2
    X

the platform can create:

Container 4

without losing application state.

State should instead be stored in appropriate external systems such as:

- Database
- Object storage
- Persistent volumes
- Distributed cache

This design enables horizontal scaling and easier recovery.


Q21. What happens when a Docker container crashes?

Answer:
A crashed container exits.

Docker or an orchestration platform can restart it depending on the configured restart policy or workload controller.

For example:

Application
    |
    X
Container exits
    |
    v
Restart policy
    |
    v
New container process

In production, the more important question is why the application crashed.

We would investigate:

1. Container logs.
2. Exit code.
3. Application logs.
4. Memory usage.
5. CPU usage.
6. Health checks.
7. Environment variables.
8. Dependency connectivity.
9. Resource limits.
10. Recent deployment changes.

A senior engineer should not simply configure automatic restart and consider the problem solved. Restarting a failing application can hide an underlying defect.


Q22. How would you troubleshoot a Docker container that immediately exits?

Answer:
I would follow a systematic approach.

First:

docker ps -a

This shows stopped containers and their exit codes.

Then:

docker logs <container>

to inspect application output.

Next:

docker inspect <container>

to inspect configuration, environment variables, mounts, networking, and startup configuration.

I would also check:

docker image inspect <image>

and verify the ENTRYPOINT/CMD.

If necessary, I would run an interactive shell:

docker run -it --entrypoint /bin/sh <image>

Then I would verify:

1. Application files exist.
2. Startup command exists.
3. Required environment variables exist.
4. Required ports are correct.
5. Permissions are correct.
6. Runtime dependencies are available.

The key is to distinguish an application failure from a container configuration failure.


Q23. What is a Docker health check, and why is it important?

Answer:
A health check determines whether an application inside a container is actually functioning.

A container can technically be "running" while the application is unavailable.

For example:

Container status: RUNNING
Application status: UNHEALTHY

A health check might verify:

HTTP GET /health

or another application-specific endpoint.

Conceptually:

Container started
      |
      v
Health check
      |
 +----+----+
 |         |
Healthy   Unhealthy
 |         |
Traffic   Recovery
allowed   action

Health checks are particularly important when using orchestration systems because the platform needs to distinguish between a running process and a functioning application.


Q24. What Docker security practices would you apply in this project?

Answer:
I would apply several layers of security.

1. Use trusted base images.

2. Keep base images patched.

3. Scan images for vulnerabilities.

4. Avoid running applications as root.

5. Do not hard-code passwords or tokens in Dockerfiles.

6. Use secrets management for sensitive credentials.

7. Minimize installed packages.

8. Use small, purpose-built images where practical.

9. Pin important dependency versions.

10. Avoid unnecessary exposed ports.

11. Restrict container privileges.

12. Use read-only filesystems where practical.

13. Sign or otherwise verify trusted images where the organization supports it.

14. Control access to the container registry.

15. Audit image provenance.

The most important principle is that a container is not automatically secure simply because it is isolated.


Q25. Design the complete Docker-based CI/CD flow for this project. What would you implement?

Answer:
I would design the pipeline as follows:

                     +----------------+
                     |    GitHub      |
                     +-------+--------+
                             |
                             v
                     +---------------+
                     |    Jenkins    |
                     +-------+-------+
                             |
                 +-----------+-----------+
                 |                       |
                 v                       v
           Maven Build              Unit Tests
                 |                       |
                 +-----------+-----------+
                             |
                             v
                       Checkstyle
                             |
                             v
                         Sonar
                             |
                             v
                       Quality Gate
                             |
                             v
                     Build Application
                             |
                             v
                       Build Docker
                          Image
                             |
                             v
                  Tag with Build/Commit
                             |
                             v
                     Container Registry
                             |
                             v
                    Deployment Pipeline
                             |
                  +----------+----------+
                  |                     |
                  v                     v
               Staging              Production
                  |                     |
                  v                     v
             Validation             Approval
                                        |
                                        v
                                   Production

For the Docker portion, I would avoid building directly on the production server.

The CI pipeline should produce an immutable image such as:

vprofile:<git-commit>

or:

vprofile:<build-number>

That image is pushed to the registry.

Staging deploys exactly that image.

After validation and approval, production deploys the same image.

This is important because otherwise we can end up testing one artifact in staging and deploying a different artifact to production.

The complete artifact promotion model should therefore be:

Source Code
    |
    v
Build
    |
    v
Test
    |
    v
Docker Image
    |
    v
Registry
    |
    v
Staging
    |
    v
Validation
    |
    v
Production

This provides reproducibility, traceability, consistent environments, easier rollback, and a clean separation between build and deployment responsibilities.

Q26. Walk me through what happens internally when you run "docker build".

Answer:
When I execute:

docker build -t vprofile:1.0 .

Docker performs several major operations.

1. Docker reads the Dockerfile.
2. It processes the build context represented by ".".
3. Each Dockerfile instruction is evaluated sequentially.
4. Docker checks whether an existing cached layer can be reused.
5. New filesystem changes create new image layers.
6. The final layers are combined into the resulting image.
7. The image receives the specified repository and tag.

Conceptually:

Dockerfile
    |
    v
Build Context
    |
    v
Instruction Processing
    |
    v
Layer Creation / Cache
    |
    v
Final Image
    |
    v
vprofile:1.0

In a CI/CD environment, I would also pay attention to the size of the build context because unnecessarily large contexts increase build time and resource consumption.

A .dockerignore file is therefore important.


Q27. What is the Docker build context, and why does it matter?

Answer:
The build context is the set of files Docker makes available to the Docker build process.

For example:

docker build -t vprofile:1.0 .

The "." means the current directory is the build context.

Docker can then access files within that context through instructions such as:

COPY target/vprofile-v2.war /app/

The build context matters because Docker may transfer/process everything included in that directory.

If the project contains:

.git/
target/
logs/
node_modules/
large files/

and they are unnecessarily included, builds can become slower.

A .dockerignore file should therefore exclude unnecessary content.

For example:

.git
target/*.log
node_modules
*.tmp

The principle is:

Smaller build context
        =
Faster and cleaner builds


Q28. What is the purpose of .dockerignore?

Answer:
.dockerignore prevents unnecessary files from being included in the Docker build context.

For example:

.git
.gitignore
README.md
*.log
target/test-results
node_modules

Depending on the build strategy, we may also exclude files that are not required by the Dockerfile.

Benefits include:

1. Smaller build context.
2. Faster builds.
3. Reduced network transfer.
4. Better security.
5. Reduced chance of accidentally copying secrets.
6. Better build reproducibility.

A particularly important security point is that credentials, SSH keys, local configuration files, and other sensitive material should never be unnecessarily included in the Docker build context.


Q29. What is the difference between an image tag and an image digest?

Answer:
A tag is a human-readable mutable reference.

Example:

vprofile:latest

or:

vprofile:1.0

A digest identifies a specific image content using a cryptographic hash.

Example conceptually:

vprofile@sha256:<digest>

Tags can move.

For example:

vprofile:latest
        |
        v
Image A

Later:

vprofile:latest
        |
        v
Image B

The digest remains tied to the exact image content.

For highly controlled production deployments, immutable references such as digests provide stronger guarantees that the exact image tested in staging is the image deployed to production.


Q30. Why is using "latest" dangerous in production?

Answer:
"latest" is a mutable tag.

Suppose staging deploys:

vprofile:latest

Today it points to image A.

Later CI pushes another image:

vprofile:latest

Now it points to image B.

If production pulls latest afterward, production may receive image B even though staging previously tested image A.

This creates an artifact promotion problem.

A safer model is:

Build
  |
  v
vprofile:build-101
  |
  v
Staging
  |
  v
Validation
  |
  v
Production

The exact same immutable artifact is promoted through environments.

Even better, production deployment can use an image digest to guarantee exact content.


Q31. What makes a Docker image reproducible?

Answer:
A reproducible image should be generated consistently from the same source inputs.

Important factors include:

1. Versioned base images.
2. Pinned application dependencies.
3. Version-controlled Dockerfiles.
4. Deterministic build processes.
5. Controlled build environment.
6. Immutable artifact references.
7. Avoiding "latest" dependencies.
8. Recording the source commit.
9. Controlling build-time configuration.

For example:

FROM tomcat:9.0.x

is generally more predictable than:

FROM tomcat:latest

The objective is that:

Same source
   +
Same Dockerfile
   +
Same dependency versions
   +
Same build process
   =
Same application artifact

In practice, complete bit-for-bit reproducibility can be more complicated, but deterministic inputs significantly improve reliability.


Q32. How would you reduce the size of a Docker image?

Answer:
I would approach image optimization systematically.

1. Use a smaller appropriate base image.
2. Remove unnecessary packages.
3. Use multi-stage builds where applicable.
4. Avoid copying unnecessary files.
5. Use .dockerignore.
6. Combine related package installation and cleanup operations when appropriate.
7. Remove package caches.
8. Avoid embedding build tools in the runtime image.
9. Copy only required application artifacts.
10. Regularly inspect image layers.

For example, instead of putting:

JDK
Maven
source code
build tools
application

into the production image, I can use:

Build Image
    |
    | compile/package
    v
Application Artifact
    |
    v
Small Runtime Image
    |
    v
Production Container

This reduces image size and attack surface.


Q33. What is a multi-stage Docker build?

Answer:
A multi-stage Docker build uses multiple FROM instructions in a single Dockerfile.

For example:

FROM maven:3.9 AS builder

COPY pom.xml .
COPY src ./src

RUN mvn package

FROM tomcat:9

COPY --from=builder target/vprofile.war /usr/local/tomcat/webapps/ROOT.war

The first stage contains build tools.

The second stage contains only what is required to run the application.

Conceptually:

Source
   |
   v
Builder Image
(Maven + JDK)
   |
   v
WAR
   |
   v
Runtime Image
(Tomcat)
   |
   v
Production

This is valuable because Maven, source code, and compiler tooling do not need to exist in the final runtime image.


Q34. Why is multi-stage Docker build better from a security perspective?

Answer:
The build environment often contains many tools:

- Maven
- JDK
- compilers
- package managers
- source code
- debugging utilities

Those tools are unnecessary at runtime.

If they remain in the production image, the attack surface becomes larger.

Multi-stage builds allow us to separate:

Build environment

from:

Runtime environment

Therefore:

Build Image
    |
    | contains tools
    v
Artifact
    |
    v
Runtime Image
    |
    | contains only required runtime
    v
Production

This follows the principle of least privilege and minimizes unnecessary components.


Q35. How would you decide whether to use a JDK image or a JRE/runtime image?

Answer:
It depends on what the container does.

A build container needs development tools such as:

- Compiler
- Maven/Gradle
- JDK

A runtime container generally needs only the runtime required by the application.

Therefore:

Build:
JDK + Maven

Runtime:
Java runtime + application

If the application only executes a packaged WAR, there is generally no reason to include Maven and the full build toolchain in the runtime image.

This distinction becomes especially important when optimizing production images.


Q36. What happens when you run "docker run"?

Answer:
At a high level, Docker performs several operations.

For:

docker run -p 8080:8080 vprofile:1.0

Docker:

1. Finds the image locally.
2. Pulls it from a registry if necessary.
3. Creates a new container from the image.
4. Adds the container's writable layer.
5. Configures networking.
6. Configures port mapping.
7. Applies environment variables and mounts.
8. Configures the container's startup command.
9. Starts the container process.

Conceptually:

Image
  |
  v
Container creation
  |
  +--> Filesystem
  +--> Network
  +--> Volumes
  +--> Environment
  +--> Process
  |
  v
Running Container


Q37. What is the container writable layer?

Answer:
A running container has a writable layer on top of the read-only image layers.

Conceptually:

Container writable layer
------------------------
Image layer
Image layer
Image layer
Base image

When the application modifies a file, the modification occurs in the container's writable layer.

However, this layer is ephemeral.

If the container is removed, the writable data is normally lost.

Therefore persistent application data should use external storage such as:

- Docker volumes
- Database
- Object storage
- Persistent storage provided by an orchestration platform


Q38. What is copy-on-write in Docker?

Answer:
Docker uses a layered filesystem model where image layers can be shared.

When a container modifies a file originating from a read-only image layer, Docker can create a writable copy for the container.

Conceptually:

Shared Image
     |
     +-------- Container A
     |
     +-------- Container B

Both containers can share the same underlying image data.

If Container A modifies a file:

Container A
    |
    +--> private writable copy

Container B continues using its own view.

This reduces duplication and improves storage efficiency.


Q39. How can multiple containers use the same Docker image?

Answer:
A single immutable image can be used as the template for multiple containers.

For example:

vprofile:1.0
     |
     +----> Container 1
     |
     +----> Container 2
     |
     +----> Container 3

Each container has its own runtime state and writable layer while sharing the underlying image layers.

This is one of the fundamental reasons containers are useful for horizontal scaling.

If application traffic increases:

1 container
    |
    v
2 containers
    |
    v
5 containers
    |
    v
10 containers

All can run the same application image.


Q40. How would you pass configuration to a Docker container?

Answer:
I would separate application configuration from the image wherever possible.

Common mechanisms include:

1. Environment variables.
2. Configuration files mounted at runtime.
3. Secrets management.
4. Orchestration platform configuration objects.
5. External configuration services.

For example:

docker run \
  -e DB_HOST=db.internal \
  -e DB_PORT=3306 \
  vprofile:1.0

The application image remains unchanged while configuration changes between environments.

This is important because:

Same image
   |
   +----> Staging configuration
   |
   +----> Production configuration

We should avoid creating separate application images merely because environment-specific configuration differs.


Q41. Why should secrets not be hard-coded in a Dockerfile?

Answer:
If a secret is placed in a Dockerfile:

ENV DB_PASSWORD=secret

or:

RUN echo "password" > config

the secret may become part of image metadata or image layers.

Even if the line is later removed, the secret can potentially remain in an earlier layer.

This creates a security risk.

Instead, secrets should be supplied through an appropriate secret-management mechanism.

Examples include:

- Jenkins credentials
- AWS Secrets Manager
- Kubernetes Secrets
- Vault
- Cloud-native secret stores

The principle is:

Application image
      |
      | no secret
      v
Runtime configuration
      |
      v
Secret injection


Q42. What is the difference between environment variables and Docker secrets?

Answer:
Environment variables are convenient for configuration but are not inherently a secure secret-management mechanism.

For example:

DB_HOST=db.internal

is normal configuration.

But:

DB_PASSWORD=secret

should be handled carefully.

Secrets mechanisms provide better control over sensitive values, including access, lifecycle, auditing, and injection.

Therefore I would classify configuration into:

Non-sensitive configuration:
Environment variables/config files.

Sensitive configuration:
Dedicated secrets-management mechanism.

A senior design should avoid treating every configuration value as a secret while also avoiding the opposite mistake of exposing credentials as ordinary environment configuration without considering the security implications.


Q43. How would you troubleshoot a Docker image that works locally but fails in Jenkins?

Answer:
I would compare the environments systematically.

First, verify:

1. Docker version.
2. Base image.
3. Build arguments.
4. Environment variables.
5. Build context.
6. Dockerfile version.
7. Source commit.
8. Network access.
9. Registry credentials.
10. File permissions.
11. CPU/memory constraints.

I would also compare the exact image build command.

For example:

Local:
docker build -t vprofile:test .

Jenkins:
docker build -t vprofile:${BUILD_ID} .

Then inspect the build logs and generated image.

If the image builds successfully but fails at runtime, I would compare:

docker inspect <container>

and:

docker logs <container>

The goal is to determine whether the difference is:

Build-time
Runtime
Infrastructure
Configuration
Dependency


Q44. What is the difference between docker stop and docker kill?

Answer:
docker stop attempts a graceful shutdown.

It sends a termination signal to the container's main process and gives it an opportunity to shut down cleanly.

docker kill sends a stronger termination signal by default.

Conceptually:

docker stop
    |
    v
Graceful shutdown
    |
    v
Application cleanup

docker kill
    |
    v
Immediate termination

For production applications, graceful shutdown is preferred because the application may need to:

- Finish active requests.
- Close database connections.
- Flush buffers.
- Commit state.
- Release resources.

This becomes particularly important for applications behind load balancers or orchestration platforms.


Q45. Why is PID 1 important inside a Docker container?

Answer:
The main process inside a container generally becomes PID 1.

PID 1 has special responsibilities around process management and signal handling.

For example:

Container
   |
   v
PID 1
   |
   +--> Application process
   |
   +--> Child processes

If the application is not properly handling termination signals, graceful shutdown may not work as expected.

This is one reason containers should normally run the actual application process as the main process rather than wrapping it unnecessarily in shell scripts.

For production systems, correct signal handling is important for:

- Graceful shutdown.
- Deployment.
- Scaling.
- Rolling updates.
- Failure recovery.


Q46. How do you inspect a running Docker container?

Answer:
I would use several Docker commands.

List running containers:

docker ps

Inspect configuration:

docker inspect <container>

View logs:

docker logs <container>

Open a shell:

docker exec -it <container> /bin/sh

View resource usage:

docker stats

Inspect processes:

docker top <container>

These commands answer different questions.

For example:

docker ps
    -> Is it running?

docker logs
    -> What is the application saying?

docker inspect
    -> How is it configured?

docker exec
    -> What is happening inside?

docker stats
    -> Is it consuming excessive resources?


Q47. What is the difference between docker exec and docker run?

Answer:
docker run creates and starts a new container from an image.

Example:

docker run -it ubuntu /bin/bash

docker exec executes a command inside an already-running container.

Example:

docker exec -it myapp /bin/sh

Therefore:

docker run
    |
    v
New container

docker exec
    |
    v
Existing container

This distinction is important during troubleshooting.

If the application container is already running and I want to inspect it, I use docker exec rather than creating another container.


Q48. How would you troubleshoot a container that cannot connect to another container?

Answer:
I would troubleshoot networking layer by layer.

First:

docker network ls

Then inspect the network:

docker network inspect <network>

I would verify:

1. Both containers are connected to the expected network.
2. The target container is running.
3. The target service is listening on the expected port.
4. The application is using the correct hostname.
5. Firewall/security rules are not blocking communication.
6. DNS/service discovery works.
7. The application is binding to the expected interface.

For example:

Application
    |
    | db:3306
    v
Database

The application should normally use the service/container name rather than depending on dynamically changing container IP addresses.

The troubleshooting principle is:

Network
  |
DNS
  |
Port
  |
Application
  |
Authentication


Q49. Why should containers communicate using service names instead of hard-coded IP addresses?

Answer:
Container IP addresses can change when containers are recreated.

For example:

Database container:
10.0.0.5

After recreation:

Database container:
10.0.0.9

If the application uses:

DB_HOST=10.0.0.5

the connection breaks.

Using a stable service/container DNS name is better:

DB_HOST=db

Then:

Application
    |
    | db
    v
Service discovery
    |
    v
Current database container

This principle becomes even more important in orchestration platforms where workloads are routinely rescheduled.


Q50. A Docker image has grown from 500 MB to 2.5 GB. How would you investigate and fix it?

Answer:
I would first identify where the size increase occurred rather than blindly optimizing the Dockerfile.

Step 1:
Inspect image history:

docker history <image>

Step 2:
Identify unusually large layers.

Step 3:
Review the Dockerfile for:

- Large COPY operations.
- Build artifacts.
- Source code.
- Dependency caches.
- Package manager caches.
- Logs.
- Unnecessary tools.

Step 4:
Review the build context and .dockerignore.

Step 5:
Determine whether build dependencies are being included in the runtime image.

If so, introduce a multi-stage build:

Stage 1:
Maven/JDK
    |
    v
WAR

Stage 2:
Tomcat/runtime
    |
    v
WAR only

Step 6:
Use an appropriately sized base image.

Step 7:
Rebuild and compare:

Before:
2.5 GB

After:
optimized runtime image

I would also ensure that the optimization does not sacrifice security, compatibility, observability, or operational requirements merely to achieve a smaller image.

The goal is not "smallest possible image"; the goal is an appropriately minimal, secure, maintainable production image.

*** Docker, Containerization & Container CI/CD — Advanced Interview Questions ****
Q51. Why should containers be treated as immutable infrastructure?

Answer:
A container should ideally be created from a known image and then replaced rather than modified manually after deployment.

In this project, the CI pipeline builds the application artifact and the container/deployment process should consume that known artifact.

The immutable approach provides:

1. Reproducibility.
2. Consistent environments.
3. Easier rollback.
4. Reduced configuration drift.
5. Easier debugging.
6. Better scalability.

If engineers manually modify a running container, the running environment can diverge from the image stored in the registry.

A production deployment should therefore follow:

Source Code → Build → Test → Package → Image → Registry → Deployment

rather than:

Source Code → Running Container → Manual Changes.

A strong interview statement:

"I prefer immutable containers because the image is the deployment artifact. If the application needs to change, I build and deploy a new version instead of modifying the running container."


Q52. What is the difference between a Docker image and a Docker container?

Answer:
A Docker image is an immutable template containing the application, runtime, libraries, configuration defaults and filesystem layers required to create a container.

A container is a running instance of that image.

For example:

Image:
vprofile:14

Container:
vprofile-container-14

The image can be stored in a registry such as Amazon ECR, while the container runs on a host or container orchestration platform.

The relationship is:

Dockerfile
   ↓
Docker Image
   ↓
Container

Multiple containers can be created from the same image.


Q53. Why should application source code and build artifacts not be treated as the same thing?

Answer:
Source code is the input to the build process, while the artifact is the output.

For this project, Maven produces:

target/vprofile-v2.war

That WAR is the deployable application artifact.

A good CI/CD pipeline separates:

Source → Build → Artifact → Deployment

This separation is important because the same tested artifact should be promoted across environments.

For example:

Build:
vprofile-v2.war

QA/Staging:
Deploy the same artifact.

Production:
Deploy the same artifact.

Rebuilding the application independently for production can produce a different binary, which weakens release reproducibility.


Q54. Why is artifact versioning important in CI/CD?

Answer:
Artifact versioning allows every deployment to be uniquely identified.

In this project, the artifact upload path was changed to use BUILD_ID:

QA/vproapp/${BUILD_ID}/vproapp-${BUILD_ID}.war

For example:

QA/vproapp/14/vproapp-14.war

This provides traceability.

If production is running version 14, we can identify:

1. Which Jenkins build produced it.
2. Which source commit triggered the build.
3. Which artifact was deployed.
4. Which deployment pipeline promoted it.

Without versioning, teams can accidentally overwrite artifacts and lose deployment history.


Q55. What problem does a Dockerfile solve?

Answer:
A Dockerfile defines how an application image should be constructed.

It converts image creation from a manual process into a repeatable process.

A Dockerfile can define:

1. Base operating system/runtime.
2. Application dependencies.
3. Environment variables.
4. Working directory.
5. Files copied into the image.
6. Ports.
7. Startup command.

Example conceptual flow:

FROM Java runtime
COPY application.war
EXPOSE 8080
CMD ["..."]

The important architectural principle is that the Dockerfile becomes infrastructure-as-code for the application runtime.


Q56. Why should Docker images be built inside CI rather than manually on a developer machine?

Answer:
Manual image builds create environment inconsistencies.

A developer may have:

- Different Docker version.
- Different base image.
- Different build dependencies.
- Uncommitted local changes.
- Different environment variables.

CI provides a controlled and repeatable environment.

A production-oriented flow is:

Git commit
   ↓
Jenkins
   ↓
Build/Test
   ↓
Docker build
   ↓
Security/quality checks
   ↓
Registry
   ↓
Deployment

This makes the image traceable to a source-control revision and CI build.


Q57. Why should Docker images be tagged with immutable versions rather than only "latest"?

Answer:
The "latest" tag is mutable.

For example:

vprofile:latest

could point to version A today and version B tomorrow.

That creates ambiguity.

A better approach is:

vprofile:14
vprofile:15
vprofile:<git-sha>

Now deployment systems know exactly which image should run.

Immutable tags make:

1. Rollback easier.
2. Auditing easier.
3. Debugging easier.
4. Reproducibility stronger.
5. Promotion between environments safer.

In production, I would prefer Git SHA or release-version-based tagging over relying exclusively on latest.


Q58. What is the difference between Docker image layers and a container's writable layer?

Answer:
Docker images are composed of read-only filesystem layers.

Each Dockerfile instruction can create a layer.

When a container starts, Docker adds a writable container layer on top of those read-only image layers.

Conceptually:

Writable Container Layer
------------------------
Image Layer 3
Image Layer 2
Image Layer 1
Base Image

Changes made inside the running container normally go into the writable layer.

When the container is deleted, those changes disappear unless persistent storage is used.

This is another reason containers should not be used as persistent storage.


Q59. How does Docker layer caching improve CI performance?

Answer:
Docker can reuse unchanged layers from previous builds.

Suppose a Dockerfile contains:

FROM Java
COPY dependency files
RUN install dependencies
COPY application
RUN build

If only the application source changes, Docker may reuse the earlier dependency layers.

This reduces build time.

However, poorly structured Dockerfiles can invalidate the cache unnecessarily.

A good strategy is to place relatively stable instructions earlier and frequently changing content later.

This becomes especially important when Jenkins builds images frequently.


Q60. What is a multi-stage Docker build and why would you use it?

Answer:
A multi-stage build uses multiple FROM statements to separate build-time dependencies from runtime dependencies.

Example:

Stage 1:
Build application.

Stage 2:
Copy only the compiled artifact into a smaller runtime image.

Conceptually:

Builder Image
    ↓
Compile
    ↓
WAR/JAR
    ↓
Runtime Image

Benefits:

1. Smaller final image.
2. Fewer unnecessary packages.
3. Reduced attack surface.
4. Faster deployment.
5. Cleaner production runtime.

For a Java application, Maven and the JDK may only be needed during the build stage, while the production container may require only the runtime.


Q61. Why is a smaller Docker image generally better for production?

Answer:
Smaller images provide several benefits:

1. Faster image download.
2. Faster container startup.
3. Lower storage requirements.
4. Lower network consumption.
5. Smaller security attack surface.
6. Faster deployments.

However, image size should not be optimized blindly.

The runtime image must still contain everything required by the application.

The objective is:

"Minimum required runtime dependencies."


Q62. What is the difference between CMD and ENTRYPOINT?

Answer:
ENTRYPOINT defines the primary executable of a container.

CMD provides default arguments or a default command.

For example:

ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]

The resulting execution is conceptually:

java -jar app.jar

ENTRYPOINT is useful when the container represents a specific executable.

CMD is useful when providing defaults that can be overridden.

In production container design, understanding this distinction is important because Kubernetes and Docker may override commands and arguments.


Q63. Why should containers normally run one primary process?

Answer:
Containers are generally designed around a single primary responsibility.

For example:

Application container → application process.

Database container → database process.

This provides:

1. Independent scaling.
2. Independent lifecycle management.
3. Easier monitoring.
4. Easier failure recovery.
5. Clear ownership.

If multiple unrelated services are placed into one container, scaling and troubleshooting become more difficult.

For example, if the application and Nginx are bundled into one container, scaling the application automatically also scales Nginx, which may be unnecessary.


Q64. How should configuration be managed in containerized applications?

Answer:
Configuration should generally be externalized from the image.

Examples include:

1. Environment variables.
2. Configuration files mounted at runtime.
3. Secrets managers.
4. Kubernetes ConfigMaps.
5. Kubernetes Secrets.
6. AWS Systems Manager Parameter Store.
7. AWS Secrets Manager.

The image should remain environment-independent.

For example:

Same image:

vprofile:14

can run in:

Staging
Production

with different configuration values.

This supports the principle:

"Build once, configure per environment."


Q65. Why should secrets not be baked into Docker images?

Answer:
If credentials are included in a Dockerfile or image layer, they can potentially remain inside the image history even after the visible file is removed.

That creates a security risk.

Secrets such as:

- Database passwords.
- AWS credentials.
- Nexus credentials.
- API tokens.

should be injected at runtime.

For this Jenkins project, credentials are already being handled through Jenkins credentials in several places.

The same principle should be extended to container runtime configuration.


Q66. What happens if a container crashes?

Answer:
The behavior depends on the container runtime and orchestration platform.

With plain Docker, restart policies can restart the container.

With Kubernetes, the controller responsible for the workload detects the failed container/pod and attempts to restore the desired state.

For example:

Deployment:

Desired replicas = 3

If one container crashes:

Running replicas = 2

Kubernetes attempts to restore:

Running replicas = 3

This is one of the fundamental advantages of container orchestration.


Q67. Why is Kubernetes generally preferred over manually managing Docker containers at scale?

Answer:
Docker provides container execution, but Kubernetes provides orchestration.

Kubernetes manages:

1. Scheduling.
2. Service discovery.
3. Scaling.
4. Rolling deployments.
5. Self-healing.
6. Desired state.
7. Networking.
8. Configuration.
9. Secrets.
10. Health checks.

For a small system, Docker alone may be sufficient.

For a production platform with multiple services and replicas, Kubernetes provides the control plane required to manage the desired state.


Q68. What is the role of a container registry in CI/CD?

Answer:
A container registry stores versioned container images.

The CI pipeline builds the image and pushes it to the registry.

Deployment systems then pull the image from the registry.

Flow:

Git
 ↓
Jenkins
 ↓
Build
 ↓
Docker Image
 ↓
Registry
 ↓
Deployment

Examples of registries include:

Amazon ECR
Docker Hub
Nexus Repository
GitHub Container Registry

The registry therefore acts as the distribution point for container artifacts.


Q69. Why should the container registry be considered part of the release pipeline?

Answer:
The registry is not merely storage.

It provides the bridge between CI and deployment.

For example:

Jenkins builds:

vprofile:15

Then pushes:

Registry/vprofile:15

The deployment platform consumes:

Registry/vprofile:15

Therefore, the registry participates in artifact promotion and release management.

It also provides version history, access control and artifact retention.


Q70. What is the difference between building an application artifact and building a container image?

Answer:
An application artifact is the compiled application package.

For this project:

Maven → vprofile-v2.war

A container image packages the application artifact together with the runtime environment.

Conceptually:

Source Code
   ↓
Maven
   ↓
WAR
   ↓
Docker Build
   ↓
Container Image

The WAR and container image serve different purposes.

WAR = application artifact.

Container image = deployable runtime package.


Q71. If the WAR artifact is correct but the container fails, where would you investigate?

Answer:
I would separate the problem into application-level and container-level troubleshooting.

First verify:

1. WAR integrity.
2. Application startup locally.
3. Java version.
4. Container base image.
5. Dockerfile.
6. ENTRYPOINT/CMD.
7. Environment variables.
8. Ports.
9. File permissions.
10. Runtime dependencies.
11. Container logs.

A useful debugging flow is:

WAR works outside container
        ↓
Check Dockerfile
        ↓
Check runtime image
        ↓
Check startup command
        ↓
Check environment
        ↓
Check container logs

This prevents randomly changing application code when the actual issue is container configuration.


Q72. A Docker image works locally but fails in Jenkins. What would you check?

Answer:
I would compare the environments systematically.

I would check:

1. Docker version.
2. Base image availability.
3. Network access.
4. Registry access.
5. Build context.
6. File paths.
7. Environment variables.
8. Credentials.
9. Disk space.
10. Memory.
11. CPU.
12. Docker daemon status.
13. Workspace permissions.

I would also run:

docker version
docker info
df -h
free -m
docker images
docker ps

Then reproduce the exact CI Docker build command manually on the Jenkins node.

The key principle is:

"Reproduce the CI environment rather than debugging only from the developer workstation."


Q73. How would you troubleshoot a Docker build that suddenly becomes extremely slow in Jenkins?

Answer:
I would investigate both Docker and Jenkins resources.

First:

df -h

to check disk space.

Then:

docker system df

to inspect Docker storage.

I would also check:

docker system prune

carefully, because pruning removes unused Docker resources.

Then inspect:

free -m
top
docker info

I would also determine whether Docker layer caching is being invalidated.

Other possibilities include:

1. Large build context.
2. Unnecessary files being copied.
3. Missing .dockerignore.
4. Slow registry.
5. Large base image.
6. Dependency downloads.
7. Disk I/O bottleneck.

A strong troubleshooting approach is to identify whether the bottleneck is:

CPU
Memory
Disk
Network
Docker cache
Registry
Build context


Q74. What is the purpose of .dockerignore?

Answer:
.dockerignore prevents unnecessary files from being sent to the Docker build context.

For example:

.git/
target/
node_modules/
*.log

This reduces:

1. Build context size.
2. Network transfer.
3. Build time.
4. Accidental inclusion of sensitive files.

It is especially important in CI because Jenkins workspaces can contain build outputs, Git metadata and temporary files.

A large build context can significantly slow Docker builds.


Q75. Design an ideal CI/CD pipeline for this project using containers.

Answer:
I would design the pipeline as:

Developer
   |
   v
GitHub
   |
   v
Jenkins
   |
   +---- Build
   |
   +---- Unit Tests
   |
   +---- Checkstyle
   |
   +---- Sonar Analysis
   |
   +---- Quality Gate
   |
   +---- Maven Artifact
   |
   +---- Docker Build
   |
   +---- Image Security Scan
   |
   +---- Push Image
   |         |
   |         v
   |      Container Registry
   |
   +---- Deploy Staging
   |
   +---- Integration Tests
   |
   +---- Approval
   |
   +---- Deploy Production

The important architectural principles are:

1. Build once.
2. Test before deployment.
3. Produce immutable artifacts.
4. Tag container images uniquely.
5. Store artifacts in a registry.
6. Promote the same artifact between environments.
7. Keep secrets outside source code.
8. Use automated quality gates.
9. Support rollback to a known artifact/image.
10. Keep deployment reproducible.

For this specific project, the existing Jenkins + Maven + Nexus + Ansible architecture already demonstrates several of these principles. The natural evolution would be to introduce container image creation and a container registry while preserving the existing CI/CD controls.

Docker, Containerization & Production Troubleshooting — FAANG-Level Interview Questions
Q76. Your Docker container starts successfully but exits immediately. How would you troubleshoot it?

Answer:
I would first determine whether the main container process is terminating.

I would run:

docker ps -a

Then inspect:

docker logs <container>

and:

docker inspect <container>

I would verify:

1. ENTRYPOINT.
2. CMD.
3. Application startup command.
4. Application exit code.
5. Environment variables.
6. Required configuration files.
7. Port configuration.
8. File permissions.
9. Java/runtime version.
10. Dependency availability.

For example, if the container runs:

java -jar app.jar

and the Java process exits because the application failed during startup, Docker will normally stop the container because its primary process has exited.

The important principle is:

"Do not troubleshoot the container first. Find out why the primary process exited."


Q77. A container is running, but the application is not reachable. What would you check?

Answer:
I would troubleshoot from the application layer outward.

First:

docker ps

Then:

docker logs <container>

Then verify the process is listening:

docker exec <container> ss -lntp

I would verify:

1. Application is listening on the expected port.
2. Docker port mapping is correct.
3. Security group allows the port.
4. Host firewall allows the traffic.
5. Application is bound to the correct interface.
6. Container network configuration is correct.
7. Reverse proxy/load balancer configuration is correct.

For example:

Application:
8080

Docker mapping:

-p 8080:8080

If the application is listening only on localhost inside the container, external access may still fail depending on the application configuration.

I would therefore verify the complete network path rather than assuming Docker itself is broken.


Q78. What is the difference between EXPOSE and publishing a Docker port?

Answer:
EXPOSE documents the port that the application uses inside the container.

For example:

EXPOSE 8080

does not automatically make port 8080 accessible from outside the host.

Publishing the port explicitly maps a host port to the container port:

docker run -p 8080:8080 image

Conceptually:

Host:8080
     |
     v
Container:8080

Therefore:

EXPOSE = documentation/metadata.

-p = actual port publishing.


Q79. How would you troubleshoot a container that cannot connect to another container?

Answer:
I would verify the Docker network first.

Commands:

docker network ls

docker network inspect <network>

Then verify:

1. Both containers are attached to the same network.
2. Correct hostname/service name is being used.
3. Correct port is being used.
4. Target application is actually listening.
5. Firewall/security rules are not blocking communication.
6. DNS resolution works.
7. Credentials/configuration are correct.

For example, if an application container needs MySQL, it should normally connect using the service/container DNS name rather than hardcoding an ephemeral container IP.

The principle is:

"Use service discovery rather than relying on container IP addresses."


Q80. Why should container IP addresses generally not be hardcoded?

Answer:
Container IP addresses are ephemeral.

Containers can be:

1. Restarted.
2. Recreated.
3. Rescheduled.
4. Scaled horizontally.

A new container may receive a different IP.

Hardcoding:

172.x.x.x

therefore creates fragile infrastructure.

Instead, service discovery should be used.

For example:

mysql:3306

or, in Kubernetes:

mysql-service:3306

This allows the underlying container instances to change without requiring application configuration changes.


Q81. What is container health checking and why is it important?

Answer:
A health check determines whether an application is actually functioning rather than merely having a running process.

A container can be:

Running = YES

but:

Application healthy = NO

For example, a Java process may remain alive while the application cannot access its database.

A health check can verify an endpoint such as:

/health

or:

/actuator/health

Health checks allow orchestration platforms to make better decisions about:

1. Traffic routing.
2. Restarting unhealthy workloads.
3. Deployment readiness.
4. Rolling updates.

This is especially important in production environments.


Q82. What is the difference between liveness and readiness?

Answer:
Liveness answers:

"Should this application process be restarted?"

Readiness answers:

"Is this application ready to receive traffic?"

For example:

Application process is alive but database initialization has not completed.

Liveness:
PASS

Readiness:
FAIL

The load balancer should not send traffic to the application until readiness passes.

This distinction prevents unnecessary restarts during normal startup conditions.


Q83. What is the difference between a container restart and a container replacement?

Answer:
A restart attempts to restart the existing container.

A replacement creates a new container instance.

Replacement is particularly important in orchestration platforms.

For example, Kubernetes may detect that a pod is unhealthy and create a replacement according to the desired state.

The broader principle is:

"Treat workloads as replaceable rather than depending on the identity of an individual container."


Q84. How would you design rollback for a containerized application?

Answer:
I would ensure every deployment points to an immutable image version.

For example:

vprofile:101
vprofile:102
vprofile:103

Suppose version 103 has a production issue.

Rollback:

vprofile:103
      ↓
vprofile:102

The rollback should not rebuild the application.

It should redeploy the previously validated image.

This is much safer because the exact previously tested artifact already exists.

A strong production strategy is:

Build once → Test → Store → Promote → Roll back by version.


Q85. Why is rebuilding an image during rollback a bad practice?

Answer:
Rebuilding may produce a different image.

Even if the source code is unchanged, external dependencies or base images may have changed.

For example:

Build 1:
Java base image version A

Rebuild later:
Java base image version B

The resulting image may differ.

A proper rollback should therefore use the previously built immutable image.

For example:

registry/vprofile:102

rather than:

"Run the build again."


Q86. How would you secure a Docker image used in production?

Answer:
I would use multiple layers of security.

1. Use trusted minimal base images.
2. Keep packages updated.
3. Scan images for vulnerabilities.
4. Remove unnecessary packages.
5. Do not store secrets in images.
6. Run as a non-root user.
7. Use immutable image tags.
8. Restrict registry access.
9. Sign/verify images where appropriate.
10. Monitor runtime behavior.

Security should happen throughout the pipeline:

Source
 ↓
Dependency scanning
 ↓
Build
 ↓
Image scanning
 ↓
Registry
 ↓
Deployment
 ↓
Runtime monitoring


Q87. Why should containers preferably run as a non-root user?

Answer:
If an application inside a container is compromised and it runs as root, the impact can potentially be greater.

Running as a non-root user follows the principle of least privilege.

For example:

USER 1000

can be used instead of running the application as root.

This reduces the privileges available to the application process.

Container isolation is not a replacement for operating-system security, so reducing privileges is an important defense-in-depth measure.


Q88. What is the difference between a container and a virtual machine?

Answer:
A virtual machine virtualizes hardware and normally contains its own operating system kernel.

A container shares the host operating system kernel while isolating the application environment.

Conceptually:

Virtual Machines:

Hardware
 ↓
Hypervisor
 ↓
VM
 ├── OS
 └── Application

Containers:

Hardware
 ↓
Host OS
 ↓
Container Runtime
 ↓
Containers
 ├── Application
 ├── Application
 └── Application

Containers are generally lighter and start faster, while VMs provide stronger hardware/OS-level isolation.

Modern production platforms frequently use both technologies together.


Q89. Why can containers start faster than virtual machines?

Answer:
Containers generally do not need to boot a complete guest operating system kernel.

They start the application process using the host kernel.

A VM normally needs to initialize:

1. Virtual hardware.
2. Guest kernel.
3. Operating-system services.
4. Application.

Therefore containers can usually start much faster.

This makes containers particularly useful for:

1. Horizontal scaling.
2. Microservices.
3. Short-lived workloads.
4. CI/CD environments.


Q90. What happens when Docker runs out of disk space?

Answer:
Docker can fail to:

1. Pull images.
2. Build images.
3. Start containers.
4. Write container logs.
5. Create new layers.

I would first check:

df -h

Then:

docker system df

Then identify:

1. Unused images.
2. Stopped containers.
3. Build cache.
4. Volumes.
5. Container logs.

I would clean resources carefully rather than blindly running destructive commands.

For example:

docker system prune

can remove unused Docker resources, but it should be executed with an understanding of what will be deleted.

In CI environments, disk monitoring and retention policies are preferable to waiting until the disk becomes full.


Q91. Why can Docker logs consume significant disk space?

Answer:
Containerized applications can continuously write logs.

If log rotation is not configured, logs may grow indefinitely.

Eventually:

Disk usage ↑
        ↓
Available disk ↓
        ↓
Docker operations fail

Production systems should therefore implement:

1. Log rotation.
2. Centralized logging.
3. Retention policies.
4. Monitoring.
5. Appropriate log levels.

For Kubernetes environments, logs are typically collected by a centralized logging system rather than retained indefinitely on individual nodes.


Q92. What is the purpose of Docker volumes?

Answer:
Containers are ephemeral by design.

Data written to the container's writable layer may disappear when the container is removed.

Volumes provide persistent storage outside the container lifecycle.

For example:

Container
   |
   v
Volume
   |
   v
Persistent Data

Volumes are appropriate for state that must survive container replacement.

However, production architectures often use managed storage services or cloud-native persistent volumes rather than relying solely on local Docker volumes.


Q93. Should a database normally be packaged inside the same container as the application?

Answer:
Generally, no.

Application and database workloads have different lifecycle and scaling requirements.

For example:

Application:
Scale to 10 replicas.

Database:
Usually remains a separate stateful service.

Separating them allows:

1. Independent scaling.
2. Independent upgrades.
3. Independent backup strategy.
4. Independent failure handling.
5. Better resource allocation.

In cloud production environments, a managed database such as Amazon RDS is often preferable to running the database inside an application container.


Q94. How would you investigate a memory leak in a containerized Java application?

Answer:
I would investigate both the Java process and container limits.

First:

docker stats

Then inspect:

1. Container memory usage.
2. JVM heap settings.
3. GC behavior.
4. Heap dumps.
5. Application metrics.
6. Thread counts.
7. Native memory.
8. Container memory limits.

For Java, I might use tools such as:

jcmd
jmap
jstack
jstat

depending on the environment.

The key distinction is:

Container memory usage != Java heap usage

because the process may also consume:

1. Metaspace.
2. Thread stacks.
3. Direct buffers.
4. Native memory.


Q95. What happens if a container exceeds its configured memory limit?

Answer:
Depending on the runtime and configuration, the process/container can be terminated by the operating system through an out-of-memory mechanism.

In Kubernetes, this can appear as:

OOMKilled

I would investigate:

1. Memory limits.
2. JVM heap configuration.
3. Application memory leak.
4. Traffic increase.
5. Native memory.
6. Garbage collection.
7. Container resource requests/limits.

For Java applications, setting the JVM heap too close to the container memory limit can be dangerous because the JVM also needs memory outside the heap.


Q96. How would you troubleshoot a Java container that is repeatedly being OOMKilled?

Answer:
I would follow a structured process.

Step 1:
Check container events/status.

Step 2:
Check memory usage:

docker stats

or Kubernetes metrics.

Step 3:
Inspect JVM configuration.

Step 4:
Compare:

Container memory limit
vs
JVM heap maximum

Step 5:
Investigate GC behavior.

Step 6:
Look for memory leaks.

Step 7:
Inspect thread counts and native allocations.

Step 8:
Determine whether the workload has genuinely exceeded its resource requirements.

I would not simply increase memory immediately.

First I would determine whether the application has a leak or whether the resource limit is incorrectly sized.


Q97. Your CI pipeline builds Docker images successfully, but deployment pulls an older image. What could cause this?

Answer:
Several things could cause this.

1. Reusing the same mutable tag such as latest.
2. Image pull policy preventing a fresh pull.
3. Registry caching.
4. Deployment manifest referencing an older tag.
5. Wrong registry/repository.
6. Wrong environment.
7. CI pushed to one registry while deployment pulls from another.
8. Deployment configuration was not updated.

I would verify:

Image tag built by Jenkins
        ↓
Image tag pushed to registry
        ↓
Image tag referenced by deployment
        ↓
Image actually running

Immutable version tags greatly reduce this class of problem.


Q98. How would you design zero-downtime deployment for a containerized application?

Answer:
I would use a rolling deployment strategy.

Suppose:

Current:
v1 × 3 replicas

New:
v2 × 3 replicas

The orchestrator gradually replaces v1 instances with v2 instances.

Before routing traffic to a new instance, it should pass readiness checks.

Conceptually:

v1 v1 v1
 ↓
v2 v1 v1
 ↓
v2 v2 v1
 ↓
v2 v2 v2

Important requirements include:

1. Multiple replicas.
2. Readiness checks.
3. Graceful shutdown.
4. Load balancing.
5. Backward-compatible changes.
6. Proper rollback strategy.

Without these controls, simply replacing containers can cause downtime.


Q99. During deployment, version 2 starts successfully but users experience errors while version 1 is still running. How would you investigate?

Answer:
I would consider compatibility between old and new versions.

Possible causes include:

1. Database schema incompatibility.
2. API contract changes.
3. Configuration mismatch.
4. Shared cache incompatibility.
5. Session incompatibility.
6. Environment variable changes.
7. Dependency changes.
8. Network configuration.
9. Load balancer behavior.

This is a classic rolling-deployment problem.

For example:

v1 → expects database schema A
v2 → expects database schema B

If both versions run simultaneously, one version may fail.

The solution may involve backward-compatible database migrations or a deployment strategy such as:

Expand
→ Deploy
→ Migrate
→ Contract

rather than making destructive schema changes first.


Q100. Design a production-grade container CI/CD architecture for the VProfile project and explain how you would evolve the current Jenkins + Maven + Nexus + Ansible system.

Answer:
I would evolve the existing architecture incrementally rather than replacing everything at once.

Current architecture:

Developer
   |
   v
GitHub
   |
   v
Jenkins
   |
   +--> Maven Build
   |
   +--> Unit Tests
   |
   +--> Checkstyle
   |
   +--> Sonar
   |
   +--> Nexus WAR Artifact
   |
   +--> Ansible
          |
          v
       Staging/Prod


Target architecture:

Developer
   |
   v
GitHub
   |
   v
Jenkins
   |
   +--> Checkout
   |
   +--> Maven Build
   |
   +--> Unit Tests
   |
   +--> Checkstyle
   |
   +--> Sonar Analysis
   |
   +--> Quality Gate
   |
   +--> Build Docker Image
   |
   +--> Security Scan
   |
   +--> Tag with Git SHA/Build ID
   |
   +--> Push Image
   |        |
   |        v
   |    Container Registry
   |
   +--> Deploy Staging
   |
   +--> Integration Tests
   |
   +--> Approval
   |
   +--> Deploy Production
   |
   +--> Monitoring
   |
   +--> Rollback


I would make the following improvements:

1. Keep GitHub as the source of truth.
2. Keep Jenkins responsible for CI orchestration initially.
3. Keep Maven for Java compilation and testing.
4. Keep Nexus for Maven artifacts if required.
5. Introduce a container registry for Docker images.
6. Build immutable images.
7. Tag images using Git SHA or build ID.
8. Scan images before deployment.
9. Externalize secrets.
10. Introduce health checks.
11. Use rolling deployments.
12. Implement automated rollback.
13. Centralize application logs.
14. Add infrastructure and application monitoring.
15. Separate staging and production credentials.
16. Add deployment approvals for production.
17. Promote the same tested image instead of rebuilding.
18. Maintain complete traceability from Git commit → Jenkins build → image → deployment.

The most important architectural principle is:

"Build once, test once, promote the same immutable artifact through environments."

That gives us:

Git Commit
    ↓
Jenkins Build #101
    ↓
vprofile:git-sha-abc123
    ↓
Security/Quality Checks
    ↓
Staging
    ↓
Production

If production fails:

Production
    ↓
Rollback
    ↓
Previously validated image
    ↓
vprofile:previous-sha

This architecture provides reproducibility, traceability, scalability, security and reliable rollback while building naturally on the Jenkins/Maven/Nexus/Ansible project already implemented.
