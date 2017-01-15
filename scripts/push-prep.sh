#!/usr/bin/env bash
#  PURPOSE: Deploy a Docker app served from Nginx from Terraform.
# -----------------------------------------------------------------------------
#  PREREQS: a) Git post-receive hooks need to be copied to the remote host.
#           b)
# -----------------------------------------------------------------------------
#  EXECUTE: sudo /tmp/push-prep.sh
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2016/12/21
# -----------------------------------------------------------------------------
#set -ux


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
#declare builder="$(whoami)"
declare builder='admin'
declare appName='MobyDock'
declare theApp="${appName,,}"
declare theSvr='nginx'
declare appPrereqs=('postgres:9.4.5' 'redis:2.8.22')
declare tmpSource='/tmp/sources'
declare tmpHooks="$tmpSource/hooks"
declare appPostReceiveHook="$tmpHooks/prhook-$theApp"
declare webPostReceiveHook="$tmpHooks/prhook-$theSvr"
declare varGit='/var/git'
declare appRepoLocal="$varGit/$theApp.git"
declare webRepoLocal="$varGit/$theSvr.git"
declare deployDirs=("$appRepoLocal" "${appRepoLocal%.*}" \
    "$webRepoLocal" "${webRepoLocal%.*}")


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Pull the prerequisite images
###---
printf '\n\n%s\n' "Pulling images to support $theApp"
for dockerImage in "${appPrereqs[@]}"; do
    printf '%s\n\n' "  attempting to pull image: $dockerImage"
    if ! docker pull "$dockerImage"; then
        printf '''
        ************************
        *                      *
        *        Uh oh!        *
        *                      *
        ************************

        '''
    else
        printf '\n%s\n\n' "    All clear!"
    fi
done


###---
### Set/reset deploy directories
###---
printf '\n\n%s\n' "Making deploy directories..."
for deployDir in "${deployDirs[@]}"; do
    if [[ -d "$deployDir" ]]; then
        printf '%s\n\n' "Remaking $deployDir"
        rm -rf "$deployDir"
        mkdir -p "$deployDir"
        continue
    else
        printf '%s\n\n' "Making ${deployDirs[*]}"
        mkdir -p "${deployDirs[@]}"
        break
    fi
done


###---
### Prepare for a git "push"
###---
### Initialize "bare" Git repositories
git --git-dir="$appRepoLocal" --bare init
git --git-dir="$webRepoLocal" --bare init

### Put the post-receive hooks in place
printf '\n%s\n' "Putting the post-receive hooks in place"
cp -v "$appPostReceiveHook" "$appRepoLocal/hooks/post-receive"
cp -v "$webPostReceiveHook" "$webRepoLocal/hooks/post-receive"

### Set permissions and ownership
printf '\n%s\n' "Setting permissionsand ownership on post-receive hooks"
chmod u+x "$appRepoLocal/hooks/post-receive" "$webRepoLocal/hooks/post-receive"
chown -R "$builder:$builder" "${deployDirs[@]}"


###---
### Print success message
###---
printf '''


       App deploy prep successful!


       '''


###----------------------------------------------------------------------------
### POST-PROCESSING Setup
###----------------------------------------------------------------------------
### Create some directories for stuff that happens later
###---
printf '\n%s\n' "Setup for the service initialization script..."
mkdir -p /tmp/{certs,app}


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### fin~
###---
exit 0
