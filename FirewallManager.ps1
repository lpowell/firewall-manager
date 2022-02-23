#############################################################
# Firewall Manager for Windows Servers						#
# 															#
# Creates and manages firewall rules for Windows Servers	#
#															#
#															#
# Author: Liam Powell										#
# Created on behalf of the Metropolitan CCDC Team			#
#############################################################

function RollCall(){
	#tmp binary file to store roles, deleted after array is created
	#New-Item -Path $env:UserProfile\Documents\FirewallManager -ItemType Directory
	#$file =[io.file]::ReadAllBytes('c:\$env:UserProfile\Documents\FirewallManager\tmp_roles.dat')
	#$Roles = (Get-WindowsFeature | where Installed | %{if($_.Name -eq 'AD-Domain-Services'){echo 'AD Found'}})
	#$Roles = (Get-WindowsFeature | where Installed | %{if($_.Name -match "AD-Domain-Services"){echo 'found'}})
	
	
	#Returns strings that match the "phrase", e.g. DNS will return DNS and RSAT-DNA-Server
	#create a rolecheck array and loop this
	#create firewall port number arrays -- pass roles to firewallinit instead?
	
	
	
	$RoleCheck =@("DNS","AD","DHCP")
	$AD =@()
	$DNS =@()
	$DHCP =@()
	
	
	foreach($x in $RoleCheck){$Roles += (Get-WindowsFeature | where Installed | %{out-string -InputObject $_.Name} | ?{$_ -match $x}) 
		FirewallRoles($x)}
	
	
	
	
	
	#foreach($x in $Roles){#add ports or function call here | if it matches AD,DNS,DHCP, ETC, pass that to firewallinit and initialize the rules
	
	#foreach($x in $Roles){
		#$y = (out-string -InputObject $x -Width 100)
		#doesn't work lol
		#[io.file]::WriteAllBytes($x,$file)
	#	if(select-object Name ){
	#		echo "found AD"
	#	}
		# convert internal format return to string
		
		# Build an array of all ports needed 
		# construct a separate array off all other ports
		# disable rules for array 2 and allow rules for array 1
		# don't forget UDP
		
	#	echo $x
	#}
}
# Scan and assess the server for installed roles and services

function Documentation(){
	
}
# Create the output information
function FirewallRoles($Role){
	
	$AD =@('88','389','464')
	$DHCP =@()
	$DNS =@('53')
	$Exchange =@()
	$Ftp =@()
	#ports to open based on service install
	
	switch($Role){
		'AD'{foreach($x in $AD){New-NetFirewallrule -DisplayName "AD Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow}}
		'DHCP'{foreach($x in $DHCP){New-NetFirewallrule -DisplayName "DHCP Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow}}
		'DNS'{foreach($x in $DNS){New-NetFirewallrule -DisplayName "DNS Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow}}
	}
	#Create allow rules for the installed services
	
}
function FirewallInit(){	
	Set-NetFirewallProfile -Enabled True
	#Enable firewall
	
	(New-Object -ComObject HNetCfg.FwPolicy2).RestoreLocalFirewallDefaults()
	#Reset to defaults
	
	$BasicRules =@('80','443')
	foreach($x in $BasicRules){New-NetFirewallrule -DisplayName "Basic Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow}
	#Create Basic rules for all devices
	#Inbound not outbound
	#80, 8080, 443, 
	
	$SecurityBlocks =@('445','3389','22','5300')
	$SecRangeBlocks =@('1-52','54-79','81-87','89-388','390-442','444-463','465-8079','8081-49151')
	#examine notes for updated ranges
	
	foreach($x in $SecurityBlocks){New-NetFirewallrule -DisplayName "Block Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Block
								   New-NetFirewallrule -DisplayName "Block Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Block
								   New-NetFirewallrule -DisplayName "Block Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Block
								   New-NetFirewallrule -DisplayName "Block Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Block}
	foreach($x in $SecRangeBlocks){New-NetFirewallrule -DisplayName "Block Range $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Block
								   New-NetFirewallrule -DisplayName "Block Range $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Block
								   New-NetFirewallrule -DisplayName "Block Range $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Block
								   New-NetFirewallrule -DisplayName "Block Range $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Block}
	
# Initialize the firewall rules 
}
function LogManager(){
	
}
# Make the necessary preperations for Real-Time event monitoring and management

function EventMonitor(){
	
}
# Parse through event logs for suspicious activity
FirewallInit
RollCall