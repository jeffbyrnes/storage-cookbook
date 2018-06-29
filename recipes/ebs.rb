#
# Cookbook:: storage
# Recipe:: ebs
#
# Copyright:: (C) 2016 EverTrue, Inc.
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

Chef::Recipe.send(:include, Storage::Helpers)

unless iam_profile_instance?
  creds = data_bag_item('secrets', 'aws_credentials')['Storage']
end

node['storage']['ebs_volumes'].each_with_index do |(name, conf), i|
  aws_ebs_volume name do
    conf.each { |key, value| send(key, value) }
    if creds
      aws_access_key creds['access_key_id']
      aws_secret_access_key creds['secret_access_key']
    end
    action %i(create attach)
  end

  mount_point = "/mnt/ebs#{i}"
  device_name = if nvme_instance?
                  if node['storage'].attribute?('ebs_mounts') &&
                     node['storage']['ebs_mounts'].include?('mount_point')
                    Chef::Log.info "#{mount_point} already mounted."
                    node['filesystem']['by_mountpoint'][mount_point]['devices'].first
                  else
                    if node['filesystem']['by_device'].keys.length > 10
                      log 'Greater than 10 devices detected, sorting may not work properly'
                    end

                    # Get the list of filesystem devices, sort them in order,
                    # grab the last one, and increment the device number.
                    # This ensures that any EBS volumes are assigned an open device number.
                    #
                    # Per the above log resource, > 10 devices means sort will not work
                    # properly b/c 10 comes before 2 when sorting strings.
                    node['filesystem']['by_device'].keys.grep(%r{/dev/nvme}).sort.last
                                                   .gsub(/nvme([1-9]|1[0-9]|2[0-6])n1/) do |_m|
                                                     "nvme#{Regexp.last_match(1).to_i + i + 1}n1"
                                                   end
                  end
                else
                  Chef::Log.info "Mounting the user supplied #{conf['device']} to #{mount_point}."
                  conf['device']
                end

  storage_format_mount mount_point do
    device_name device_name
  end

  # rubocop:disable ChefCorrectness/NodeNormal
  node.normal['storage']['ebs_mounts'] = (node['storage']['ebs_mounts'] || []) | [mount_point]
  # rubocop:enable ChefCorrectness/NodeNormal
end
