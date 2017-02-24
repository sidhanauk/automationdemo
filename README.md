Task:
--------------------------------
The solution should contain a Vagrantfile, all associated configuration management files, and a README that lists both the steps we should run to duplicate your solution and any assumed software version(s). The solution should only require vagrant installed on the  host machine with all additional software installed on the virtual machines. 
· Create a Vagrantfile that creates a single machine using this box:https://vagrantcloud.com/puppetlabs/boxes/ubuntu-14.04-64-nocm and installs the latest released version of your chosen configuration management tool. 
· Install the nginx webserver via configuration management. 
· Run a simple test using Vagrant's shell provisioner to ensure that nginx is listening on port 80 
· Again, using configuration management, update contents of /etc/sudoers file so that Vagrant user can sudo without a password and that anyone in the admin group can sudo with a password. 
· Make the solution idempotent so that re-running the provisioning step will not restart nginx unless changes have been made 
· Create a simple "Hello World" web application in your favourite language of choice. 
· Ensure your web application is available via the nginx instance. 
· Extend the Vagrantfile to deploy this webapp to two additional vagrant machines and then configure the nginx to load balance between them. 
· Test (in an automated fashion) that both app servers are working, and that the nginx is serving the content correctly. 

I’m interested in your working as much as your answers, so where you make a decision to go one way rather than another, please explain your thinking. Your solution will be assessed on code quality and comprehensibility, not just on technical correctness. Optional Extra credit: · Have the webapp be dynamic - e.g. perform a db query for inclusion in the response (such as picking a random quote from a database) or calling an API of your choice(e.g. weather). => Any additional resources (e.g. a shared db server) should be set up by the Vagrant file · Include a section for possible improvements and compromises made during the development of your solution We’re interested in your working as much as your answers, so where you make a decision to go one way rather than another, please explain your thinking.


Solution:
--------------------------------
This project uses Vagrant to launch web nodes and configure nginx as loadbalancer. Ansible is used for Provisioning the virtual machines.

Vagrant: Vagrant script creates 1 Ansible Controller machine and N number of virtual ubuntu boxes to be used as web servers and 1 VM to be used as load balancer. 

Variables in vagrant file:
- Ansible Controler Machine IP: 10.0.0.10
- Load balancer IP: 10.0.0.11 
- Webserver ip address starts from 10.0.0.21

Roles:
- common - holds common tasks and handlers to both load balancer and web server. This installs nginx and git
- lb - holds task and handlers for loadbalancer. It also has config template for ngnix loadbalancer setup. Load balacing is performed in roundrobin way. 
- web - holds task and handlers for web servers. It also has html and config template for nginx webserver setup.

Playbook: pb_webserver.yml
This provisions web nodes by installing git, nginx and copy index.html template to webnodes. Data API git repo is downloaded and installed. Also configured nginx to add a custom response header to include name of hosts.

Playbook: pb_loadbalancer.yml 
This provisions loadbalance node and also updates the config file for load balancer based on number of web nodes created. It uses facts from ansible to get the ip address of the hosts and add them in load balancer config of nginx.

Test the loadbalancer and Web nodes
Script test_loadbalancer.rb is included which sends 100 requests to loadbalanced host and reads the host name (from response header) and stores the count of different hosts it has received response from.

How to run:
- $ vagrant up 

This will start the Web Nodes, Loadbalancer and Ansible controller VM's, and run the provisioning playbook (on the first VM startup).

To re-run a playbook on an existing VM, just run:
- $ vagrant provision

Script to test loadbalancer is distributing load to web nodes 
- $ ruby test_loadbalancer.rb
  - "web2 ====>  50"
  - "web1 ====>  50"

Remarks:
- Not able to test the nginx port 80 using inline shell provisioner in vagrant
- Ansible inventory is not dynamic and can be done as improvement 
- Test script can be parameterized