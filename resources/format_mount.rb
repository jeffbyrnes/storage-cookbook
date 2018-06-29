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
  execute "format #{device_name} as #{fs_type}" do
    command "mke2fs -j -m#{reserved_space} -F #{device_name} -t #{fs_type}"
    action :run
    not_if { `file -s #{device_name}` =~ /filesystem data/ }
  end

  directory mount_point do
    recursive true
    action :create
  end

  mount mount_point do
    device device_name
    action %i(mount enable)
  end
end
