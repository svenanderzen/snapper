## Wat is dis?
The `snapper.sh` script is a bash script for making automatic snapshots of a
Google Cloud Compute instance using cronjobs. This makes it possible to take
snapshots of your instance at set intervals and make rollbacks of the server
from the Google Cloud Console.

## System requirements
* Google Cloud SDK
* cURL
* Bash (only supporting bash for the moment...)

## Setup
Place the `snapper.sh` script at a location of your choosing and call the
script from a cronjob on your Google Cloud instance.

## Waj is dis not working u pis of shiz?
#### Permission denied
If you are getting a `Permission denied` error when running the script,
double check that you have enabled **Read/Write** access in the
**Cloud API access scopes**. You can check this by going into your VM
instance on the Google Cloud Console and scroll down to the list labeled
**Cloud API access scopes** and check for the entry **Compute**.
