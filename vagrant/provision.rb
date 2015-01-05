# This ruby file was intended to enable vagrant ansible provisioning

# usage example
# -------------
#
# # Vagrantfile
# Vagrant.configure('2') do |config|
#   vagrant_ansible_remote = ENV['VAGRANT_ANSIBLE_REMOTE']
#   if vagrant_ansible_remote
#     require_relative "#{vagrant_ansible_remote}/vagrant/provision.rb"
#     VagrantAnsibleRemote.provision
#   end
# end
#
# vagrant provision

# WARNING: it's current untested (not part of our use cases)
module VagrantAnsibleRemote
  def self.provision
    ansible_groups = ENV['ANSIBLE_RUN_GROUPS']
    ansible_playbook = ENV['ANSIBLE_RUN_PLAYBOOK']

    if ansible_groups
      raise "missing playbook #{ansible_playbook}" unless File.file?(ansible_playbook)

      require 'yaml'
      ansible_groups = YAML.load(File.read(ansible_groups))

      config.vm.provision "ansible" do |ansible|
        ansible.sudo = true
        ansible.playbook = ansible_playbook
        ansible.groups = ansible_groups
      end
    end
  end
end
