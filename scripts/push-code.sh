#!/usr/bin/env bash
#  PURPOSE: Push the app from Terraform. Works for 1 remote server
#           per $deployEnv
# -----------------------------------------------------------------------------
#  PREREQS: a) Must be using the correct SSH keys to interact with AWS.
#           b) Terraform must assign the correct EC2 Key Pairs to the instance.
#           c) Git post-receive hooks must be on the remote host.
# -----------------------------------------------------------------------------
#  EXECUTE: scripts/push-code.sh
# -----------------------------------------------------------------------------
#     TODO: 1) Wrap FOR loop in WHILE loop.
#           2)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2016/12/22
# -----------------------------------------------------------------------------
#set -ux


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# Setup stuff
declare builder='admin'
declare deployEnv='Dev'
declare knownHosts="$HOME/.ssh/known_hosts"
declare inventoryFile='/tmp/rhost.tfout'
declare projectDir="$(pwd)"
# Function
declare appName='MobyDock'
declare theApp="${appName,,}"
declare myCodeDir="$HOME/code"
declare codeMobyDock="$myCodeDir/$theApp"
declare codeMobyDockNGINX="$myCodeDir/nginx"
declare pushRepos=("$codeMobyDock" "$codeMobyDockNGINX")


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Push to the remote server
###---
while read -r rHostIP; do
    printf '\n\n%s\n' "Pushing code to $rHostIP..."
    # Add the host's public keys to our knownHosts file
    printf '%s\n' "  Adding $rHostIP public key to our known_hosts file..."
    ssh-keyscan -t 'rsa' "$rHostIP" >> "$knownHosts"

    # Push the repos
    for codeDir in "${pushRepos[@]}"; do
        #printf '\n\n%s\n\n' "${pushRepos[@]}"
        # Move to the code repo
        printf '\n%s\n' "  Moving to $codeDir..."
        cd "$codeDir" || exit

        # The remote host must be added as a "git push" host
        printf '%s\n\n' "  Adding $rHostIP as a $deployEnv server"
        git remote add "$deployEnv" "ssh://${builder}@${rHostIP}:/var/git/${codeDir##*/}.git"

        # Verify rHostIP has been added
        git remote -v

        # Push the build
        printf '\n%s\n' "  Now do the push to $deployEnv"
        git push "$deployEnv" master -v

        # Remove the $deployEnv
        printf '\n%s\n' "  Remove $deployEnv server..."
        git remote remove "$deployEnv"

        # Verify rHostIP has been removed
        git remote -v
    done

    # Remove the host's public keys from our knownHosts file
    printf '\n%s\n' "Removing the rHostIP public key from our known_hosts file..."
    #ssh-keygen -f "$knownHosts" -R "$rHostIP"
done < $inventoryFile

### Return to the project directory
cd "$projectDir" || exit


###---
### fin~
###---
exit 0
