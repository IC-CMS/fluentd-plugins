#!/bin/bash
# Docker buildcycle Script
# Build and automate cleanup - good to use on dev box where this is the only project

#WORKING_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
WORKING_DIR=/tmp/fluentd
DIR_NAME=${WORKING_DIR##*/}
VERSION='v1.0'
CONTAINER_NAME='fluentd-plugins'
USERNAME=`whoami`
REPO_AND_IMAGE="sredna/$CONTAINER_NAME"
IMAGE_STRING=""
DOCKER_FILE="."
# In-docker environment variables


# Build flags
CACHE=false
DEPLOY=false
TESTRUN=false
INTERACTIVE=false

function prepTmp {
   echo "Preparing temp space [ $WORKING_DIR ]"
   set -e
   mkdir -p $WORKING_DIR/log
   mkdir -p $WORKING_DIR/etc
   chmod -R ugo+rwx $WORKING_DIR
   chcon -Rt svirt_sandbox_file_t $WORKING_DIR
   set +e
}


function testrun {
  echo "testrun"
  prepTmp
  sudo docker run \
    -it \
    --rm \
    -p 24224:24224 \
    -p 8080:8080 \
    -v $WORKING_DIR/log/:/fluentd/log/:rw \
    --name $CONTAINER_NAME \
    $IMG_STRING
}

function runInteractive {
  echo "Interactive Run"
  prepTmp
  sudo docker run \
    -it \
    --rm \
    -p 24224:24224 \
    -p 8080:8080 \
    -v $WORKING_DIR/log/:/fluentd/log/:rw \
    --entrypoint="/bin/bash" \
    --name $CONTAINER_NAME \
    $IMG_STRING
}

function cleanDockerImage {
  echo "Cleaning up Docker Image $1"
  sudo docker ps -a \
   | awk '{print $1,$2 }' \
   | grep $1 \
   | awk '{print $1}' \
   | xargs -I {} sudo docker rm -f {}
}

function cleanDocker {
echo "Cleaning any stopped containers and unused image layers"
# remove built image for rebuild
 sudo docker rmi $(sudo docker images -f "dangling=true" | grep none | awk {'print $3'})

# remove any existing stopped containers
 sudo docker ps -a | awk '{print $1}' | xargs sudo docker rm
}


while getopts "cdtiv:" arg; do
  case $arg in
    v)
      echo "Version being built: $OPTARG"
      VERSION="$OPTARG"
      ;;
    c)
      echo "Building with cached layers"
      CACHE=true
      ;;
    d)
      echo "Deploying to the registry upon success"
      DEPLOY=true
      TESTRUN=true
      ;;
    t)
      echo "Testing enabled"
      TESTRUN=true
      ;;
    i)
      echo "Interactive mode"
      INTERACTIVE=true  
      echo "Disabling testrun"
      TESTRUN=false
      echo "Disabling deployment"
      DEPLOY=false
      ;;
  esac
done

IMG_STRING="$REPO_AND_IMAGE:$VERSION"
IMG_STRING_LATEST="$REPO_AND_IMAGE:latest"

# build the image, removing intermediate layers, deleting cache
if [ $CACHE = true ]; then
  echo "Building with caching enabled"
  sudo docker build -t "$IMG_STRING" -t "$IMG_STRING_LATEST" $DOCKER_FILE
else
  echo "Building without cache"
  cleanDocker
  cleanDockerImage $IMG_STRING
  cleanDockerImage $IMG_STRING_LATEST
  sudo docker build --no-cache -t "$IMG_STRING" -t "$IMG_STRING_LATEST" $DOCKER_FILE
fi

if [ $? -gt 0 ]; then
  echo "Build failed" > $2
  exit 1;
fi

if [[ $? -eq 0 ]]; then
  echo "Successful build:  $IMG_STRING"
  sudo docker images | grep $REPO_AND_IMAGE
  if [[ $TESTRUN = true ]]; then
    if [[ $INTERACTIVE = true ]]; then
      runInteractive
    else
      testrun
    fi
  else
    if [[ $INTERACTIVE = true ]]; then
      runInteractive
    fi
  fi
fi

if [[ $DEPLOY = true ]]; then
  echo "Pushing to the registry"
  sudo docker push $IMG_STRING
fi


