#
# Cookbook Name:: storage
# Resource:: format_mount
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

default_action :run

property :mount_point,    String, name_property: true
property :device_name,    String, required: true
property :fs_type,        String, default: 'ext4'
property :reserved_space, default: 0

action :run do
  execute "format #{new_resource.device_name} as #{new_resource.fs_type}" do
    command "mke2fs -j -m#{new_resource.reserved_space} -F #{new_resource.device_name} -t #{new_resource.fs_type}"
    action :run
    not_if { `file -s #{new_resource.device_name}` =~ /filesystem data/ }
  end

  directory new_resource.mount_point do
    recursive true
    action :create
  end

  mount new_resource.mount_point do
    device new_resource.device_name
    action %i(mount enable)
  end
end
