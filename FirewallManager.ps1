#############################################################
# Firewall Manager for Windows Servers			    #
# 							    #
# Creates and manages firewall rules for Windows Servers    #
#							    #
#							    #
# Author: Liam Powell					    #
# Created on behalf of the Metropolitan CCDC Team	    #
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
	#correlates to $role switch

	
	
	foreach($x in $RoleCheck){if(Get-WindowsFeature | where Installed | %{out-string -InputObject $_.Name} | ?{$_ -match $x}){FirewallRoles($x);if($x -eq 'AD'){$AD=$true}}}
	#Pass installed roles to firewall creator
	#added condi for separating DC for device in domain


	if((get-service | select-object Name, Status | %{$_.Name -match 'MSExchangeServiceHost'}) -eq 'True'){FirewallRoles('Exchange')}
	#If true, create exchange rules
	
	if(-Not $AD){if((gwmi win32_computersystem).partofdomain -eq $true){FirewallRoles('AD')}}
	#If the device is part of a domain, create the AD rules to allow communication
	#should only check if the device is not a DC
	
	
	
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
	
	$AD =@('88','135','138','139','389','445','464','636','3268','3269')
	$DHCP =@('647')
	$DHCPUDP =@('67','547','647','847')
	$DNS =@('53')
	$Exchange =@('143','993','110','995','587')
	$Ftp =@()
	#ports to open based on service install
	
	switch($Role){
		'AD'{foreach($x in $AD){New-NetFirewallrule -DisplayName "AD Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
								New-NetFirewallrule -DisplayName "AD Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
								New-NetFirewallrule -DisplayName "AD Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow
								New-NetFirewallrule -DisplayName "AD Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
		'DHCP'{foreach($x in $DHCP){New-NetFirewallrule -DisplayName "DHCP Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
								    New-NetFirewallrule -DisplayName "DHCP Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow}
			   foreach($x in $DHCPUDP){New-NetFirewallrule -DisplayName "DHCP Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
									   New-NetFirewallrule -DisplayName "DHCP Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
		'DNS'{foreach($x in $DNS){New-NetFirewallrule -DisplayName "DNS Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
								  New-NetFirewallrule -DisplayName "DNS Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
								  New-NetFirewallrule -DisplayName "DNS Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow
								  New-NetFirewallrule -DisplayName "DNS Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
		'Exchange'{foreach($x in $Exchange){New-NetFirewallrule -DisplayName "Exchange Port $x" -Direction Inbound -LocalPort $x -Protocol TCP -Action Allow
											New-NetFirewallrule -DisplayName "Exchange Port $x" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow
											New-NetFirewallrule -DisplayName "Exchange Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow
											New-NetFirewallrule -DisplayName "Exchange Port $x" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow}}
	}
	#Create allow rules for the installed services
	
}
function FirewallInit(){	
	Set-NetFirewallProfile -Enabled True
	#Enable firewall
	
	(New-Object -ComObject HNetCfg.FwPolicy2).RestoreLocalFirewallDefaults()
	#Reset to defaults
	
	$BasicRules =@('53','80','443')
	$BasicRulesUDP =@('53','123')
	foreach($x in $BasicRules){New-NetFirewallrule -DisplayName "Basic Port $x" -Direction Outbound -LocalPort $x -Protocol TCP -Action Allow}
	foreach($x in $BasicRulesUDP){New-NetFirewallrule -DisplayName "Basic Port $x (UDP)" -Direction Outbound -LocalPort $x -Protocol UDP -Action Allow
								  New-NetFirewallrule -DisplayName "Basic Port $x (UDP)" -Direction Inbound -LocalPort $x -Protocol UDP -Action Allow}
	#Create Basic rules for all devices
	#outbound not inbound
	#80, 8080, 443, 
	
	$SecurityBlocks =@('3389','22','5300')
	$SecRangeBlocks =@('1-52','54-66','68-79','81-87','89-109','111-122','124-134','136-137','140-142','144-388','390-442','444','446-463','465-546','548-586','588-635','637-646','648-846','848-992','993-994','996-1023','8081-49151')
	#examine notes for updated ranges
	#1024-5000 must be open for endpoint <-> domain connection
	
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
