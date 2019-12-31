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

if nvme_instance?
  log 'Due to how EC2 supports EBS volumes on some NVMe instances, we cannot mount them at this time.'
else
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
    device_name = conf['device']

    storage_format_mount mount_point do
      device_name device_name
    end

    node.normal['storage']['ebs_mounts'] = (node['storage']['ebs_mounts'] || []) | [mount_point]
  end
end
