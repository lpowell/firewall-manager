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
	$Roles = (Get-WindowsFeature | where Installed | %{if($_ -match "AD"){echo 'AD Found'}})
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