#!/bin/bash
#
#############
# CHANGELOG #
#############
#
# 2016-04-03 <fewbits> Creation of this script
#
########
# TODO #
########
#
# [_] Create the output file based on the hostname and current timestamp
# [_] Create repository in a local text file
# [_] Split repository entries by module
# [_] Execute each module (if it has at least one entry)
# [_] Sort and exclude repeated entries from the output file
# [_] Remove temporary files
# [_] Create syntax message
# [_] Create help message
# [_] Create option to reuse or force a new repository
#
#########
# FIXME #
#########
#
#
#
###############
# User Config #
###############
#
#
#
#################
# System Config #
#################
#
logFilename="`hostname`.log"
repositoryFilename="`hostname`.repository"
repositoryFilenameTemp="$repositoryFilename.tmp"
moduleFilenameTemp="module.tmp"
inventoryFilename="`hostname`.inventory"
#
#############
# Functions #
#############

function logInfo() {
	#1 module
	#2 message
	
	echo "[`date +"%Y-%m-%d %H:%M:%S"`] [$1] $2" | tee -a $logFilename
}

function logError() {
	#1 module
	#2 message
	#3 error code
	
	echo "[`date +"%Y-%m-%d %H:%M:%S"`] [$1] $2" | tee -a $logFilename
	exit $3
}

function repositorySearch() { # Create the sources repository
	logInfo "repository" "Searching for IBM Software sources"

	# Creating empty repository file
	> $repositoryFilename

	# Generating temp repository file
	find / \( -name "db2ls" -o -name "mqsiprofile" -o -name "InterchangeSystem.log" -o -name "idsversion" -o -name "imcl" -o -name "versioninfo.sh" -o -name "Version.xml"-o -name "de_lsrootiu.sh" -o -name "nco_id" -o -name "FinalInstallInfo.txt" -o -name "versionInfo.sh" -o -name "fmcver" \) >> $repositoryFilenameTemp 2>/dev/null

	# Checking number of sources found
	repositorySources=`cat $repositoryFilenameTemp | wc -l`
	
	# If 0, exit script with error
	if [ $repositorySources -eq 0 ]; then
		logError "repository" "No sources has been found on this server. Check user and filesystem permissions, or maybe there is no software installed." 1
	# If 1 or more, continue
	else
		logInfo "repository" "Number of sources: $repositorySources."
	fi

	## Formatting repository file

	# Header
	echo "# Repository - Generated by fewbits/ibm-inventory.sh"	| tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# Broker
	echo "[Broker]" | tee -a $repositoryFilename
	grep mqsiprofile $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# DB2
	echo "[DB2]" | tee -a $repositoryFilename
	grep db2ls $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# ICS
	echo "[ICS]" | tee -a $repositoryFilename
	grep InterchangeSystem.log $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# IDS
	echo "[IDS]" | tee -a $repositoryFilename
	grep idsversion $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# IM
	echo "[IM]" | tee -a $repositoryFilename
	grep imcl $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# Impact
	echo "[Impact]" | tee -a $repositoryFilename
	grep versioninfo.sh $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# InfoSphere
	echo "[InfoSphere]" | tee -a $repositoryFilename
	grep Version.xml $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# lsroot
	echo "[lsroot]" | tee -a $repositoryFilename
	grep de_lsrootiu.sh $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# OMNIbus
	echo "[OMNIbus]" | tee -a $repositoryFilename
	grep nco_id $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# Reporter
	echo "[Reporter]" | tee -a $repositoryFilename
	grep FinalInstallInfo.txt $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# WebSphere
	echo "[WebSphere]" | tee -a $repositoryFilename
	grep versionInfo.sh $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename

	# Workflow
	echo "[Workflow]" | tee -a $repositoryFilename
	grep fmcver $repositoryFilenameTemp | sort | tee -a $repositoryFilename
	echo | tee -a $repositoryFilename
}

function moduleCollect() {
	moduleName=$1		#1 Module name
	moduleFilter=$2		#2 Module filter for grep command
	moduleAction=$3		#3 Module action after grep output
	
	logInfo "module:$moduleName" "Collecting software"
	
	grep "$moduleFilter" $repositoryFilename > $moduleFilenameTemp
	
	while read $repositoryEntry; do
		echo $repositoryEntry
	done < $moduleFilenameTemp
}

function inventoryCreate() { # Creates the output/inventory file
	logInfo "inventory" "Creating the output file..."

	# Creating empty files
	serverHostname=`hostname`
	#inventoryFile="$serverHostname-`date +%Y%m%d%H%M%S`"
	inventoryFilename="$serverHostname"
	touch $inventoryFilename
}

function tempClean() { # Delete temporary files
	rm -f $repositoryFilenameTemp
	rf -f $moduleFilenameTemp
}

##########
# Script #
##########

logInfo "system" "Starting fewbits/ibm-inventory tool"
repositorySearch
moduleCollect "db2" "db2ls"
#inventoryCreate
tempClean

