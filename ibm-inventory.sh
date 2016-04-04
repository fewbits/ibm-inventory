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
logFile="`hostname`.log"
repositoryFile="`hostname`.repository"
repositoryFileTemp="$repositoryFile.tmp"
moduleFileTemp="module.tmp"
inventoryFile="`hostname`.inventory"
inventoryFileTemp="$inventoryFile.tmp"
#
#############
# Functions #
#############

function logInfo() {
	#1 module
	#2 message
	
	echo "[`date +"%Y-%m-%d %H:%M:%S"`] [$1:info] $2" | tee -a $logFile
}

function logError() {
	#1 module
	#2 message
	#3 error code
	
	echo "[`date +"%Y-%m-%d %H:%M:%S"`] [$1:error] $2" | tee -a $logFile
	tempClean
	exit $3
}

function repositorySearch() { # Create the sources repository
	logInfo "repository" "Searching for IBM Software sources..."

	# Creating empty repository file
	> $repositoryFile

	# Generating temp repository file
	find / \( -name "db2ls" -o -name "mqsiprofile" -o -name "InterchangeSystem.log" -o -name "idsversion" -o -name "imcl" -o -name "versioninfo.sh" -o -name "Version.xml"-o -name "de_lsrootiu.sh" -o -name "nco_id" -o -name "FinalInstallInfo.txt" -o -name "versionInfo.sh" -o -name "fmcver" \) >> $repositoryFileTemp 2>/dev/null

	# Checking number of sources found
	repositoryCount=`cat $repositoryFileTemp | wc -l`
	
	# If 0, exit script with error
	if [ $repositoryCount -eq 0 ]; then
		logError "repository" "No sources has been found on this server. Check user and filesystem permissions, or maybe there is no software installed." 1
	# If 1 or more, continue
	else
		logInfo "repository" "Number of sources: $repositoryCount"
	fi

	#sleep 3																	# DESCOMENTAR

	## Formatting repository file

	# Header
	logInfo "repository" "Creating an empty repository file"
	echo "# IBM Repository - Generated by fewbits/ibm-inventory.sh - Timestamp `date +'%Y-%m-%d %H:%M:%S'`" >> $repositoryFile
	echo >> $repositoryFile

	# Broker
	#echo "[Broker]" | tee -a $repositoryFile
	#grep mqsiprofile $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# DB2
	#echo "[DB2]" | tee -a $repositoryFile
	#grep db2ls $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# ICS
	#echo "[ICS]" | tee -a $repositoryFile
	#grep InterchangeSystem.log $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# IDS
	#echo "[IDS]" | tee -a $repositoryFile
	#grep idsversion $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# IM
	#echo "[IM]" | tee -a $repositoryFile
	#grep imcl $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# Impact
	#echo "[Impact]" | tee -a $repositoryFile
	#grep versioninfo.sh $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# InfoSphere
	#echo "[InfoSphere]" | tee -a $repositoryFile
	#grep Version.xml $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# lsroot
	#echo "[lsroot]" | tee -a $repositoryFile
	#grep de_lsrootiu.sh $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# OMNIbus
	#echo "[OMNIbus]" | tee -a $repositoryFile
	#grep nco_id $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# Reporter
	#echo "[Reporter]" | tee -a $repositoryFile
	#grep FinalInstallInfo.txt $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# WebSphere
	#echo "[WebSphere]" | tee -a $repositoryFile
	#grep versionInfo.sh $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile

	# Workflow
	#echo "[Workflow]" | tee -a $repositoryFile
	#grep fmcver $repositoryFileTemp | sort | tee -a $repositoryFile
	#echo | tee -a $repositoryFile
}

function inventoryCreate() { # Create the inventory file
	logInfo "inventory" "Creating an empty inventory file"
	> $inventoryFile
	
	echo "# IBM Inventory - Generated by fewbits/ibm-inventory.sh - Timestamp `date +'%Y-%m-%d %H:%M:%S'`" >> $inventoryFile
	echo >> $inventoryFile

}

function moduleCollect() {
	moduleName=$1		#1 Module name
	moduleFilter=$2		#2 Module filter for grep command
	moduleAction="$3"	#3 Module action after grep output

	logInfo "module" "Starting module: $moduleName - Collecting software..."
	
	grep "$moduleFilter" $repositoryFileTemp | sort > $moduleFileTemp

	# Checking number of module entries
	moduleCount=`cat $moduleFileTemp | wc -l`

	# If 1 or more, continue
	if [ $moduleCount -gt 0 ]; then
		logInfo "module" "Number of entries: $moduleCount"
		# Write to repository
		echo "[$moduleName]" >> $repositoryFile
		cat $moduleFileTemp >> $repositoryFile
		echo >> $repositoryFile
		# Write to inventory
		while read repositoryEntry; do
			eval "$moduleAction"  >> $inventoryFileTemp
		done < $moduleFileTemp
	# If 0, skip
	else
		logInfo "module" "No entries found. Skipping"
	fi
	
}

function tempClean() { # Delete temporary files
	rm -f $repositoryFileTemp
	rm -f $moduleFileTemp
}

##########
# Script #
##########

#logInfo "test" "Testing..."
#repositoryEntry="/usr/local/bin/db2ls"
#moduleName="DB2"
#moduleFilter="db2ls"
#moduleAction="$repositoryEntry | grep -e '^\/.*..:..:' | awk '{print \$2}' | while read version; do echo \"DB2 \$version\"; done | sort -n | uniq"
#echo $moduleAction
#exit

logInfo "system" "Starting fewbits/ibm-inventory tool"
repositorySearch
inventoryCreate
moduleCollect "Broker" "mqsiprofile" "grep 'MQSI_VERSION=' | sed 's/MQSI_VERSION=//g' | while read version; do echo \"IBM WebSphere Message Broker \$version\"; done | sort -n | uniq"
moduleCollect "DB2" "db2ls" "\$repositoryEntry 2> /dev/null | grep -e '^\/.*..:..:' | awk '{print \$2}' | while read version; do echo \"DB2 \$version\"; done | sort -n | uniq"
#tempClean

