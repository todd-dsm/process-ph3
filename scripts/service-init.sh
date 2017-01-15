#!/usr/bin/env bash
#  PURPOSE: Spin-up the app and supporting services. EXECUTOR: Terraform/admin.
# -----------------------------------------------------------------------------
#  PREREQS: a) Code must have been coppied to the remote box.
#           b) The 'push-prep.sh' script must have already been run.
#           c) 'sources/units/' must be in place on the remote host.
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2016/12/25
# -----------------------------------------------------------------------------
#set -ux


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# System Setup Stuff
declare builder='admin'
declare homeBuilder="/home/$builder"
#declare deployEnv='Dev'
# App-related Stuff
declare appName='MobyDock'
declare theApp="${appName,,}"
declare tmpSource='/tmp/sources'
# NGINX Stuff
#declare tmpNGINX="$tmpSource/nginx"
#declare tmpConfig="$tmpSource/config"
#declare runConfig="$homeBuilder/config"
# Certs
declare tmpCerts="$tmpSource/certs"
declare sysSSLDir='/etc/ssl'
declare sysSSLPriv="$sysSSLDir/private"
declare sysSSLCerts="$sysSSLDir/certs"
declare sslCertName='productionexample'
# PostgreSQL
declare pgUser='postgres'
# Units
declare tmpUnits="$tmpSource/units"
declare sysUnits='/etc/systemd/system'
declare appUnits=('iptables-restore' 'swap' 'postgres' 'redis' \
    "$theApp" 'nginx')

###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Security First: Record firewall rules before we begin
###---
printf '\n\n%s\n' "Firewall rules: current:"
sudo iptables -L


###---
### Copy firewall rules to the system
###---
printf '\n\n%s\n' "Copying firewall rules to the system..."
mkdir -p /var/lib/iptables
cp "$tmpUnits/rules-save" /var/lib/iptables
sudo chown -R 0:0 /var/lib/iptables


###---
### Drop certs in place
###---
printf '\n\n%s\n' "Copying certs to the home directory..."
cp -rf "$tmpCerts" "$homeBuilder"
chown -R "$builder:$builder" "$homeBuilder/certs"
find "$homeBuilder/certs" -type f -exec chmod 644 {} \;
chmod o-r "$homeBuilder/certs/$sslCertName.key"

# FIX: shouldn't this really go in: '/etc/ssl/certs' ?
printf '\n\n%s\n' "Copying certs to the system..."
cp "$tmpCerts/dhparam.pem" "$sysSSLPriv"

### The crt is public
if [[ ! -d "$sysSSLCerts" ]]; then
    mkdir -p "$sysSSLCerts"
    cp "$tmpCerts/$sslCertName.crt" "$sysSSLCerts"
else
    cp "$tmpCerts/$sslCertName.crt" "$sysSSLCerts"
fi

### The key is private
if [[ ! -d "$sysSSLPriv" ]]; then
    mkdir -p "$sysSSLPriv"
    cp "$tmpCerts/$sslCertName.key" "$sysSSLPriv"
else
    cp "$tmpCerts/$sslCertName.key" "$sysSSLPriv"
fi

### Change owner to root
printf '%s\n' "  Ensuring proper ownership..."
find "$sysSSLDir" -type f -name "$sslCertName*" -exec chown 0:0 {} \;

### Remove the "other" "read" bit
printf '%s\n' "  Ensuring proper permissions..."
chmod o-r "$sysSSLPriv/$sslCertName.key"


###----------------------------------------------------------------------------
### Manage App and System Services
###----------------------------------------------------------------------------
### Copy units to their home
###---
printf '\n\n%s\n' "Copying $appName unit files to the system..."
for unit in "${appUnits[@]}"; do
    unit="$unit.service"
    printf '%s\n' "  Copying unit to system: $unit"
    cp "$tmpUnits/$unit" "$sysUnits"
    #printf '%s\n' "Change unit owner to: root"
    chown "0:0" "$sysUnits/$unit"
done


###---
### Copy app init files to $builder home
###---
#printf '\n\n%s\n' "Putting $appName init files in place..."
#cp -rf "$tmpConfig" "$runConfig"
## Change owner to $builder
#printf '%s\n' "  Ensuring proper ownership..."
#chown -R "$builder:$builder" "$runConfig"
## Make sure files are readable, however many there will be
#printf '%s\n' "  Ensuring proper permissions..."
#find "$runConfig" -type f -exec chmod 644 {} \;


###---
### Start supporting services
###---
printf '\n\n%s\n' "Enabling and starting $appName supporting services..."
noServices='4'
for (( i = 0; i < "$noServices"; i++ )); do
	for appService in ${appUnits[$i]}; do
		appService="$appService.service"
		printf '\n\n%s\n' "Enabling: $appService..."
		systemctl enable "$appService"
		printf '%s\n'     "Starting: $appService..."
		systemctl start "$appService"
		printf '%s\n'     "Status of $appService..."
		systemctl status -l "$appService"
	done
done


###----------------------------------------------------------------------------
### Start the App
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Restarting Docker..."
systemctl restart docker

exit 0

###----------------------------------------------------------------------------
### SECFIX: Grant the App DB Access
###----------------------------------------------------------------------------
### FAILING HERE; RESUME: S9 / L72
###----------------------------------------------------------------------------

# \i or \include filename
# Reads input from the file filename and executes it as though it had been
# typed on the keyboard.
###---
#\ir or \include_relative filename
# to read from relative locations



set -x
printf '\n\n%s\n' "Grant $appName access to postgres database..."
printf '%s\n' "  Creating database..."
docker exec -it postgres -U "$pgUser" createdb "$theApp"

printf '%s\n' "  Granting all-access to dbAdmin..."
docker exec -it postgres psql -U "$pgUser" "$theApp" -c "CREATE USER $theApp WITH PASSWORD "'$pgPassword'"; GRANT ALL PRIVILEGES ON DATABASE $theApp to $theApp;"
set +x

###---
### Record firewall rules after changes
###---
printf '\n\n%s\n' "Firewall rules: new:"
sudo iptables -L

exit 0

###----------------------------------------------------------------------------
### REQ
###----------------------------------------------------------------------------


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
### REQ
###---


###---
### REQ
###---


###---
### Do the housework
###---
printf '\n\n%s\n' "Post-game cleanup..."
#rm -rf "$tmpSource"


###---
### fin~
###---
exit 0
