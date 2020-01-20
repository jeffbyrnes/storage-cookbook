#
# Cookbook:: storage
# Recipe:: default
#
# Copyright:: (C) 2014 EverTrue, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This recipe handles the mounting of additional volumes under various
# circumstances.

# Find all ephemeral block devices and mount them in subdirectories inside /mnt

Chef::Log.debug("Storage info: #{node['storage'].inspect}")

storage = StorageCookbook::Storage.new(node)
ephemeral_mounts = []

if File.exist?('/proc/mounts') && File.readlines('/proc/mounts').grep(%r{/mnt/dev0}).empty?
  Chef::Log.info '/mnt/dev0 not already mounted. Proceeding...'

  if node['ec2'] && node['ec2']['block_device_mapping_ephemeral0']
    # Unmount anything we find mounted at '/mnt' (as long as it's empty)
    Chef::Log.info 'EC2 ephemeral storage detected.'

    raise 'Directory /mnt not empty' if Dir.entries('/mnt') - %w(lost+found efs efs-maxio . ..) != []

    unless node['filesystem']['by_mountpoint']['/mnt'].nil?
      m = mount '/mnt' do
        fstype node['filesystem']['by_mountpoint']['/mnt']['fs_type']
        device node['filesystem']['by_mountpoint']['/mnt']['devices'].first
        action :nothing
      end
      m.run_action(:umount)
      m.run_action(:disable)
    end
  end

  if storage.dev_names.any?
    # This function formats newly discovered devices, mounts them, then stores
    # their name in our collector array ("ephemeral_mounts").
    Chef::Log.info 'Usable storage devices discovered.'
    Chef::Log.debug "Storage devices: #{storage.dev_names.inspect}"

    ephemeral_mounts = storage.dev_names.each_with_index.map do |dev_name, i|
      mount_point = "/mnt/dev#{i}"

      storage_format_mount mount_point do
        device_name dev_name
        action :nothing
      end.run_action(:run)

      mount_point
    end
  end
else
  # If we find /mnt/dev0 already mounted (which implies that this recipe has
  # already been run), just make sure the attribute gets populated.
  Chef::Log.info '/mnt/dev0 already mounted.'
  ephemeral_mounts = storage.dev_names.each_with_index.map { |_dev_name, i| "/mnt/dev#{i}" }

  # Shipped with Chef 12.0.0
  # https://github.com/chef/chef/pull/1719
  mount '/mnt' do
    action :disable
    device '/dev/xvdb'
    not_if { node['storage']['ephemeral_mounts'].empty? }
  end
end

# Ensure the filesystem attribute is up-to-date
ohai 'update_filesystem_mountpoints' do
  action :nothing
end.run_action(:reload)

# Populate the attribute with whatever we gathered during this convergence.
if ephemeral_mounts.any?
  # Check that a supposed ephemeral mount is, in fact, mounted.
  # If not, remove it from the array before populating the attribute.
  # This is b/c some AMIs list more ephemeral block devices than are actually present.
  ephemeral_mounts.each do |mount_point|
    unless node['filesystem']['by_mountpoint'].keys.include? mount_point
      ephemeral_mounts.delete mount_point
    end
  end

  # rubocop:disable ChefCorrectness/NodeNormal
  node.normal['storage']['ephemeral_mounts'] = ephemeral_mounts
  # rubocop:enable ChefCorrectness/NodeNormal

  Chef::Log.info "Configured these ephemeral mounts: #{node['storage']['ephemeral_mounts'].join(' ')}"
else
  Chef::Log.info 'No ephemeral mounts were found'
  node.rm('storage', 'ephemeral_mounts')
end

include_recipe 'storage::ebs' if node['storage']['ebs_volumes']

# Reload Ohai so our attributes are available to other cookbooks
ohai 'update_ephemeral_mounts'
