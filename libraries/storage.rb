#
# Cookbook Name:: storage
# Library:: storage
#
# Copyright (C) 2014 EverTrue, Inc.
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

module EverTools
  class Storage
    def dev_names
      @dev_names ||= begin
        names = []
        if @node['ec2'] &&
          @node['ec2']['block_device_mapping_ephemeral0']
          Chef::Log.debug('Using ec2 storage')
          names = ec2_dev_names
        elsif @node['etc']['passwd']['vagrant']
          Chef::Log.debug('Using vagrant storage')
          names = vagrant_dev_names
        elsif defined?(ChefSpec)
          Chef::Log.debug('Chefspec Detected, skipping mounts')
          names = []
        else
          fail 'Can\'t figure out what kind of node we\'re running on.'
          names = []
        end

        Chef::Log.debug 'Converted ephemeral device names: ' + names.join(', ')
        # Sometimes EC2/Ohai says that a device is present when it is not...
        names = names.select { |name| File.exist? name }

        Chef::Log.debug 'actually present ephemeral devices: ' + names.join(', ')
        names
      end
    end

    def mnt_device
      @node['filesystem'].find { |_k, v| v['mount'] == '/mnt' }
    end

    def initialize(node)
      @node = node
    end

    private

    def local
      non_root_bds = @node['block_device'].select { |bd, _conf| bd != 'sda' }
      r = non_root_bds.select do |_bd, bd_conf|
        bd_conf['model'] == 'VBOX HARDDISK'
      end
      Chef::Log.info('No additional block devices found') if r.size.zero?
      r
    end

    def nvme_devices
      devices = Dir.glob('/dev/nvme*n*')

      Chef::Log.debug "Found these NVME devices: #{devices.join ', '}" if devices.any?

      # If there are any partitions, we can't include their host devices because we have an
      # uncertain state. We'll exclude those devices (and their partitions) so as to avoid problems.
      devices.reject { |d| devices.find { |p| p =~ /#{d}p\d+$/ } || d =~ /p\d+$/ }
    end

    def ec2_dev_names
      e_block_devs = @node['ec2'].select { |k, _v| k =~ /^block_device_mapping_ephemeral.*/ }
      Chef::Log.debug "ephemeral devices in Ohai: #{e_block_devs}"
      r = e_block_devs.map { |_k, v| "/dev/#{v.sub(/^s/, 'xv')}" }
      r += nvme_devices
      return r if r.any?
      fail "e_block_devs did not parse correctly, no drives found: #{e_block_devs}"
    end

    def vagrant_dev_names
      local.map do |bd, _conf|
        "/dev/#{bd}"
      end
    end
  end
end
