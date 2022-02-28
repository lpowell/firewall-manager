# firewall manager
 
# Summary of functions
This is a short script that creates role-based firewall rules for windows servers. It also audits the installed services and creates rules for specified services, such as exchange email servers. More functions are planned for future updates.

# Updates
2/28/2022
Finished the base code for rule creation on Active Directory, DNS, DHCP, and Exchange servers. Made the repo public as well.

# To-Do
Finish adding all the roles that can be installed on windows servers.

Add more service checks and create a modular system for expanding the services that are checked (mirror rolecheck).

Cleanup the range blocks and create a more elegant solution that can block unused role ports (e.g. if no AD connection or installation, block the AD ports).

Log readers and monitors for suspicious traffic/connections.

Auto-block suspected malicious IPs.
