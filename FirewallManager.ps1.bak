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
	$Roles = (Get-WindowsFeature | where-object {$_. installstate -eq "installed"} | Format-List Name)
	foreach($x in $Roles){
		if($x | select-string -Pattern "AD"){
			echo "found AD"
		}
		# Build an array of all ports needed 
		# construct a separate array off all other ports
		# disable rules for array 2 and allow rules for array 1
		# don't forget UDP
		
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