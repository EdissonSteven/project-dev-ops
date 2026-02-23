FROM jenkins/jenkins:lts

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml

USER root

# Instalar dependencias del sistema + Node.js 18 + Docker Compose plugin
RUN apt-get update && apt-get install -y \
    curl \
    git \
    docker.io \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -SL "https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-x86_64" \
       -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose \
    && rm -rf /var/lib/apt/lists/*

USER jenkins

# Instalar plugins necesarios para el pipeline
RUN jenkins-plugin-cli --plugins \
    configuration-as-code \
    job-dsl \
    git \
    github \
    github-branch-source \
    workflow-aggregator \
    pipeline-stage-view \
    pipeline-utility-steps \
    docker-workflow \
    docker-plugin \
    nodejs \
    sonar \
    timestamper \
    ws-cleanup \
    build-timeout \
    credentials-binding \
    blueocean
