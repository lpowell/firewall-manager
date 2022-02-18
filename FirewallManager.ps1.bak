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
	$Roles = (Get-WindowsFeature | where-object {$_. installstate -eq "installed"} | Format-List Name | foreach {$_.Name -as [string]})
	foreach($x in $Roles){
		echo $x
	}
}
# Scan and assess the server for installed roles and services

function Documentation(){
	
}
# Create the output information

function FirewallInit(){
	
}
# Initialize the firewall rules 

function LogManager(){
	
}
# Make the necessary preperations for Real-Time event monitoring and management

function EventMonitor(){
	
}
# Parse through event logs for suspicious activity

RollCall