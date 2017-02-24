$script = <<SCRIPT
echo "Check if nginx service is running on port 80"
PROC="nginx"

# Let nginx start
sleep 30

# Loop proc and check if the service is running
for p in $PROC
do
  sudo netstat -nlap|grep :80 | grep $p > /dev/null

  # If its not running, exit with a 2
  if [ $? -eq 0 ]; then
    echo "nginx is served on port 80"
    exit 0
  else
    echo "nginx is not served on port 80"
    exit 2
  fi
done
SCRIPT


NUMBER_OF_WEBSERVERS = 2
CPU = 2
MEMORY = 256
ADMIN_USER = "vagrant"
ADMIN_PASSWORD = "vagrant"
VM_VERSION= "puppetlabs/ubuntu-14.04-64-nocm"
VM_URL= "https://vagrantcloud.com/puppetlabs/boxes/ubuntu-14.04-64-nocm"
VAGRANT_VM_PROVIDER = "virtualbox"

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  groups = { "webservers" => ["web[1:#{NUMBER_OF_WEBSERVERS}]"], "loadbalancers" => ["load_balancer"], "all_groups:children" => ["webservers","loadbalancers"] }

  # Web Nodes
  (1..NUMBER_OF_WEBSERVERS).each do |i|
    config.vm.define "web#{i}" do |node|
        node.vm.box = VM_VERSION
        node.vm.box_url = VM_URL
        node.vm.hostname = "web#{i}"
        node.vm.network :private_network, ip: "10.0.0.2#{i}"
        node.vm.network "forwarded_port", guest: 80, host: "808#{i}"
        node.vm.provider VAGRANT_VM_PROVIDER do |vb|
          vb.memory = MEMORY
        end
      end
    end

    # Nginx as load balancer
    config.vm.define "load_balancer" do |lb_config|
        lb_config.vm.box = VM_VERSION
        lb_config.vm.box_url = VM_URL
        lb_config.vm.hostname = "lb"
        lb_config.vm.network :private_network, ip: "10.0.0.11"
        lb_config.vm.network "forwarded_port", guest: 80, host: 8011
        lb_config.vm.provider VAGRANT_VM_PROVIDER do |vb|
          vb.memory = MEMORY
        end
    end


  # Ansible controller machine
  config.vm.define 'controller' do |machine|
    machine.vm.network "private_network", ip: "10.0.0.10"
    machine.vm.box = VM_VERSION
    machine.vm.box_url = VM_URL


    machine.vm.provision :ansible_local do |ansible|
      ansible.playbook       = "pb_webserver.yml"
      ansible.verbose        = true
      ansible.install        = true
      ansible.limit          = "webservers"
      ansible.groups         = groups
      ansible.inventory_path = "./inventory"
    end

    machine.vm.provision :ansible_local do |ansible|
      ansible.playbook       = "pb_loadbalancer.yml"
      ansible.verbose        = true
      ansible.install        = true
      ansible.limit          = "load_balancer"
      ansible.groups         = groups
      ansible.inventory_path = "./inventory"
    end

  end

  # Test loadbalancer running on port 80
#    config.vm.define "load_balancer" do |lb_config|
#        lb_config.vm.hostname = "lb"
#        lb_config.vm.network :private_network, ip: "10.0.0.11"
#
#        lb_config.vm.provision "run script",
#           type: "shell",
#           preserve_order: true,
#           inline: $script
#    end
end
