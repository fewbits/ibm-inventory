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

function repositoryCreate() { # Creates a repository file with the software sources
	repositoryFilename=repository.txt
	touch $repositoryFilename

	find / \( -name "db2ls" -o -name "mqsiprofile" -o -name "InterchangeSystem.log" -o -name "idsversion" -o -name "imcl" -o -name "versioninfo.sh" -o -name "Version.xml"-o -name "de_lsrootiu.sh" -o -name "nco_id" -o -name "FinalInstallInfo.txt" -o -name "versionInfo.sh" -o -name "fmcver" \) > $repositoryFilename 2>/dev/null

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

repositoryCreate
inventoryCreate







