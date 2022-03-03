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

	$RoleCheck =@("DNS","AD","DHCP")
	#correlates to $role switch

	foreach($x in $RoleCheck){if(Get-WindowsFeature | where Installed | %{out-string -InputObject $_.Name} | ?{$_ -match $x}){FirewallRoles($x);if($x -eq 'AD'){$AD=$true}}}
	#Pass installed roles to firewall creator

	if((get-service | select-object Name, Status | %{$_.Name -match 'MSExchangeServiceHost'}) -eq 'True'){FirewallRoles('Exchange')}
	#If true, create exchange rules
	
	if(-Not $AD){if((gwmi win32_computersystem).partofdomain -eq $true){FirewallRoles('AD')}}
	#If the device is part of a domain, create the AD rules to allow communication
	
}

function Documentation(){
	
}

function FirewallRoles($Role){
	
	$AD =@('88','135','138','139','389','445','464','636','3268','3269')
	$DHCP =@('647')
	$DHCPUDP =@('67','547','647','847')
	$DNS =@('53')
	$Exchange =@('25','143','993','110','995','587')
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

	
	$SecurityBlocks =@('3389','22','5300')
	$SecRangeBlocks =@('1-24','26-52','54-66','68-79','81-87','89-109','111-122','124-134','136-137','140-142','144-388','390-442','444','446-463','465-546','548-586','588-635','637-646','648-846','848-992','993-994','996-1023','8081-49151')
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
