#!/bin/bash

################################################################################
#                                                                              #
# Script for making automatic snapshots of a Google Cloud Compute instance     #
# using Cloud SDK, for the possibility to make rollbacks from Cloud Console.   #
#                                                                              #
################################################################################
#                                                                              #
# System requirements:                                                         #
#   - Google Cloud SDK                                                         #
#   - cURL                                                                     #
#   - Only running in bash for the moment... :(                                #
#                                                                              #
# Setup:                                                                       #
#   - Place the script in the folder of your choosing and run the script as a  #
#   cronjob.                                                                   #
#                                                                              #
# Info:                                                                        #
#   The snapshots will be added with the name "autosnapshot-instanceName       #
#   -%d-%m-%H-%M" where %d is the day, %m the month, %H the hour and %M the    #
#   minute.                                                                    #
#                                                                              #
# Released into the Public Domain under the WTFPL license.                     #
# Sven Anderzén - 2016                                                         #
#                                                                              #
################################################################################

# The number of days before the snapshot should be removed.
numberOfDays=7

# The Google Cloud Compute instance URL for internal meta data
# retrival. (see https://cloud.google.com/compute/docs/metadata)
metaDataURL=http://metadata.google.internal/computeMetadata/v1/instance

# We have to use the following header in our request to make it a valid request:
header="Metadata-Flavor: Google"

# Google Cloud instance variables:
instanceName=$(curl --url ${metaDataURL}/disks/0/device-name \
					--header "${header}" \
					--silent)
instanceZone=$(curl --url ${metaDataURL}/zone \
					--header "${header}" \
					--silent)
instanceZone=${instanceZone##*/}
time=$(date "+%d-%m-%H-%M")

################################################################################
#                                                                              #
# Delete our snapshots that are older than numberOfDays days:                  #
#                                                                              #
################################################################################

# Get our list of snapshots made by this script:
snapshots=$(gcloud compute snapshots list \
			--regexp "autosnapshot-${instanceName}-.*" \
			--uri)

# Loop through our list of snapshots and delete those that are older than
# $numberOfDays days.
for line in `sed '/^$/d' <<< ${snapshots}`; do

	# Get the snapshot info:
	snapshotName=${line##*/}
	snapshotDate=$(gcloud compute snapshots describe ${snapshotName} | \
		grep "creationTimestamp" | \
		cut -d "'" -f 2 | \
		cut -d "T" -f 1)
	snapshotDate=$(date -d ${snapshotDate} "+%Y%m%d")
	breakDate=$(date -d "-${numberOfDays} days" "+%Y%m%d")

	if [ ${snapshotDate} -le ${breakDate} ]; then
		$(gcloud compute snapshots delete ${snapshotName} --quiet)
	fi

done

################################################################################
#                                                                              #
# Create our new snapshot of our instance:                                     #
#                                                                              #
################################################################################

# Create a snapshot of the boot disk named in the format
# "autosnapshot-instanceName-01-01-13-37"
$(gcloud compute disks snapshot ${instanceName} \
	--snapshot-names autosnapshot-${instanceName}-${time} \
	--description "This backup was auto created on $(date)." \
	--zone ${instanceZone})
