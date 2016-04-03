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
# [_] ???
#
#############
# Functions #
#############

function splashScreen() {
	echo
	echo "=> Welcome to fewbits/ibm-inventory <="
	echo
}

function logInfo() {
	#1 module
	#2 message
	
	echo "[`date +"%Y-%m-%d %H:%M:%S"`] [$1] $2"
}

function logError() {
	#1 module
	#2 message
	#3 error code
	
	echo "[`date +"%Y-%m-%d %H:%M:%S"`] [$1] $2"
	exit $3
}

function repositoryCreate() { # Creates a repository file with the software sources
	logInfo repository "Creating the source repository..."

	# Creating empty files
	repositoryFilename=repository.txt
	touch $repositoryFilename
	touch $repositoryFilename.inventorytmp
	# Force new repository
	> $repositoryFilename

	#find / \( -name "db2ls" -o -name "mqsiprofile" -o -name "InterchangeSystem.log" -o -name "idsversion" -o -name "imcl" -o -name "versioninfo.sh" -o -name "Version.xml"-o -name "de_lsrootiu.sh" -o -name "nco_id" -o -name "FinalInstallInfo.txt" -o -name "versionInfo.sh" -o -name "fmcver" \) > $repositoryFilename.inventorytmp 2>/dev/null
	
	# Number of sources found
	repositorySources=`cat $repositoryFilename.inventorytmp | wc -l`
	if [ $repositorySources -eq 0 ]; then
		logError repository "Repository can't be created. No sources founded on this server. Check filesystem permissions, or maybe there is no software installed." 1
	else
		logInfo repository "Repository created. Number of sources: $repositorySources."
	fi
	
	## DB2
	echo "[DB2]" >> $repositoryFilename
	grep db2ls $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename
	
	## Broker
	echo "[Broker]" >> $repositoryFilename
	grep mqsiprofile $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## ICS
	echo "[ICS]" >> $repositoryFilename
	grep InterchangeSystem.log $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## IDS
	echo "[IDS]" >> $repositoryFilename
	grep idsversion $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## IM
	echo "[IM]" >> $repositoryFilename
	grep imcl $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## Impact
	echo "[Impact]" >> $repositoryFilename
	grep versioninfo.sh $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## InfoSphere
	echo "[InfoSphere]" >> $repositoryFilename
	grep Version.xml $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## lsroot
	echo "[lsroot]" >> $repositoryFilename
	grep de_lsrootiu.sh $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## OMNIbus
	echo "[OMNIbus]" >> $repositoryFilename
	grep nco_id $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## Reporter
	echo "[Reporter]" >> $repositoryFilename
	grep FinalInstallInfo.txt $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## WebSphere
	echo "[WebSphere]" >> $repositoryFilename
	grep versionInfo.sh $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

	## Workflow
	echo "[Workflow]" >> $repositoryFilename
	grep fmcver $repositoryFilename.inventorytmp >> $repositoryFilename
	echo >> $repositoryFilename

}

function inventoryCreate() { # Creates the output/inventory file
	serverHostname=`hostname`
	#inventoryFile="$serverHostname-`date +%Y%m%d%H%M%S`"
	inventoryFilename="$serverHostname"
	touch $inventoryFilename
}

##########
# SCRIPT #
##########

splashScreen
repositoryCreate
#inventoryCreate







