FROM jenkins/jenkins:lts

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml

USER root

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    git \
    docker.io \
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
