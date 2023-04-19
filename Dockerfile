# base
FROM ubuntu:22.04

# set the github runner version
ARG RUNNER_VERSION="2.303.0"

# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip git

ENV RUNNER_ALLOW_RUNASROOT="1"

# cd into the user directory, download and unzip the github actions runner
RUN mkdir /actions-runner
RUN cd actions-runner && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# copy over the start.sh script
RUN ./actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh
ENTRYPOINT ["/start.sh"]
