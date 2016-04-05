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
	systemClean
	exit $3
}

function systemSplash() { # Display a Splash Screen
	logInfo "system" "Starting fewbits/ibm-inventory tool"
}

function systemResults() { # Display the results of the tool
	logInfo "system" "Finishing fewbits/ibm-inventory tool"
	logInfo "system" "Repository file => $repositoryFile"
	logInfo "system" "Inventory file => $inventoryFile"
	logInfo "system" "Log file => $logFile"
}

function systemClean() { # Delete temporary files
	logInfo "system" "Deleting temporary files"
	rm -f $repositoryFileTemp
	rm -f $inventoryFileTemp
	rm -f $moduleFileTemp
}


function repositorySearch() { # Create the sources repository
	logInfo "repository" "Searching for IBM Software sources..."

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

	logInfo "repository" "Creating an empty repository file"
	> $repositoryFile
	
	# Header
	echo "# IBM Repository - Generated by fewbits/ibm-inventory.sh - Timestamp `date +'%Y-%m-%d %H:%M:%S'`" >> $repositoryFile
	echo >> $repositoryFile

}

function inventoryCreate() { # Create the inventory file
	logInfo "inventory" "Creating an empty inventory file"
	> $inventoryFile

	# Header	
	echo "# IBM Inventory - Generated by fewbits/ibm-inventory.sh - Timestamp `date +'%Y-%m-%d %H:%M:%S'`" >> $inventoryFile
	echo >> $inventoryFile

}

function inventoryFormat() { # Format the output of inventory file
	logInfo "inventory" "Formatting the inventory file"
	
	cat $inventoryFileTemp | sort | uniq >> $inventoryFile
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

systemSplash
repositorySearch
inventoryCreate

## Modules - Begin ##
moduleCollect "Broker" "mqsiprofile" "\cat \$repositoryEntry | grep 'MQSI_VERSION=' | sed 's/MQSI_VERSION=//g' | while read version; do echo \"IBM WebSphere Message Broker \$version\"; done | sort -n | uniq"
moduleCollect "DB2" "db2ls" "\$repositoryEntry 2> /dev/null | grep -e '^\/.*..:..:' | awk '{print \$2}' | while read version; do echo \"DB2 \$version\"; done | sort -n | uniq"
## Modules - End ##

inventoryFormat
systemResults
systemClean

