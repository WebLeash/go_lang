#!/usr/bin/env bash
#################################################
# Gocd Agent for Jenkins using the Jenkins CLI  #
#################################################
#--------------------------
# Date: 18th October
# Author: Nathan C Stott
#--------------------------
######################################################################################################
# Version 1.2 | Call Jenkins CLI and avoud race conditions.  NCS 
######################################################################################################

#--------------------------------------------------------
# Downloading the client
# The CLI client can be downloaded directly from a Jenkins controller at the URL /jnlpJars/jenkins-cli.jar, in effect JENKINS_URL/jnlpJars/jenkins-cli.jar
#
# While a CLI .jar can be used against different versions of Jenkins, should any compatibility issues arise during use, please re-download the latest .jar file from the Jenkins controller.
# https://www.jenkins.io/doc/book/managing/cli/
#--------------------------------------------------------
branch=${GITLAB_BRANCH}
query="$srvurl/job/routetolive/job/deployment/job/pipeline2-deploy-component/lastBuild/api/json"
call="$srvurl/job/routetolive/job/deployment/job/pipeline2-deploy-component/buildWithParameters?"
#git_lab_repo="covea-digital/trading/applications/rspca/rspca-server"
git_lab_repo=${GITLAB_REPO}

HOST="http://10.229.18.50:8080"
JOB_URL="job/deployment/job/pipeline2-deploy-component"
JENKINS_USER=${JENKINS_USER}
JENKINS_USER_TOKEN=${JENKINS_USER_TOKEN}
job="routetolive/deployment/pipeline2-deploy-component"
NUMBER=0
export TERM=xterm

output() {
	
	str="$1"
	error_level=$2
	#red=$(tput setaf 1)
        #green=$(tput setaf 2)
        #reset=`tput sgr0`
	dt=$(date)

	if [ "$2" == 9 ]; then
	   str=$(curl --silent -u ${JENKINS_USER}:${JENKINS_USER_TOKEN} ${HOST}/job/routetolive/job/deployment/job/pipeline2-deploy-component/$NUMBER/consoleText)
           str1="${str}  "
           str="[ERROR:] ${str1}"
        elif [ "$2" == 1 ]
        then
           str="${str} "
        else  # Provides console output of the job to GoCD. Needs looking at though. Security Issues?
	   str=$(curl --silent -u ${JENKINS_USER}:${JENKINS_USER_TOKEN} ${HOST}/job/routetolive/job/deployment/job/pipeline2-deploy-component/$NUMBER/consoleText)
           str="${str}  "
        fi

	echo "----------------------------------------------"
	echo "[$dt] [$str] "
	echo "----------------------------------------------"

}


function callJenkins() {
build=$(/gocd-jre/bin/java -jar /home/go/devops_scripts/jenkins-cli.jar -s $HOST -auth ${JENKINS_USER}:${JENKINS_USER_TOKEN} build $job -p GITLAB_BRANCH=${GITLAB_BRANCH} -p COVEA_ENV=${COVEA_ENV} -p GITLAB_REPO=${GITLAB_REPO} -p RELEASE_IMAGE_TAG=${RELEASE_IMAGE_TAG} -w)
        # Calls the jenkins CLI stdout is [Started my_test_job #167], it will wait for the job to start then return with the job_number.
	NUMBER=$(echo $build |cut -d'#' -f2)
	if ! [ "$NUMBER" -eq "$NUMBER" ] 2> /dev/null
        then
		output "Error: Not an Integer [$NUMBER], issue calling $job using the CLI" 9 
		exit 1
	fi
	output "Build Number = ($NUMBER)" 1
}

getStatus () {

	res=$(curl --silent -u ${JENKINS_USER}:${JENKINS_USER_TOKEN}  ${HOST}/job/routetolive/job/deployment/job/pipeline2-deploy-component/$NUMBER/api/json |/home/go/devops_scripts/jq -r '.result')
	while [[ "$res" == "null" ]];
	do
		res=$(curl --silent -u ${JENKINS_USER}:${JENKINS_USER_TOKEN}  ${HOST}/job/routetolive/job/deployment/job/pipeline2-deploy-component/$NUMBER/api/json |/home/go/devops_scripts/jq -r '.result')
		output "Waiting for Jenkins to finish, please wait..." 1
		sleep 3
	done
	if [ "$res" == "SUCCESS" ]; then
        output "Deployed with Success!" 1 
		output "console output log from Jenkins" 0
                exit 0;
    fi
    if [ "$res" != "SUCCESS" ]; then
        output "Deployment failed status = [$res]" 9 
        exit 1
    fi
}

#/-/-/-/-/-/-/-/-/-/
# Start Here
#/-/-/-/-/-/-/-/-/-/

callJenkins
getStatus 
