#!/bin/bash

ORGANIZATION=$ORGANIZATION
GITHUB_TOKEN=$GITHUB_TOKEN

REG_TOKEN=$(curl -sX POST -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/$ORGANIZATION/actions/runners/registration-token | jq .token --raw-output)

echo "$REG_TOKEN"

cleanup() {
    echo "Removing runner..."
    REG_TOKEN=$(curl -sX POST -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/$ORGANIZATION/actions/runners/registration-token | jq .token --raw-output)
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

if [ "$REG_TOKEN" == "null" ];
then
	echo "Something went wrong pulling registration token..."
	cleanup
	exit -1
fi

cd /actions-runner
out=$(./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN})
echo $out

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
