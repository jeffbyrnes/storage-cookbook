#
# Cookbook:: storage
# Library:: helpers
#
# Copyright:: (C) 2017 EverTrue, Inc.
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

require 'net/http'

module Storage
  module Helpers
    def iam_profile_instance?
      Net::HTTP.get_response(
        URI('http://169.254.169.254/2016-09-02/meta-data/iam/')
      ).code.to_i == 200
    end

    # Some instances expose EBS volumes as NVMe block devices
    # We need to know this, and transform our device to /dev/nvme[0–26]n1 to accommodate
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html
    def nvme_instance?
      instance_classes = %w(
        a1
        c5
        c5d
        c5n
        g4
        i3.metal
        i3en
        inf1
        m5
        m5a
        m5ad
        m5d
        m5dn
        m5n
        p3dn.24xlarge
        r5
        r5a
        r5ad
        r5d
        r5dn
        r5n
        t3
        t3a
        u-12tb1.metal
        u-18tb1.metal
        u-24tb1.metal
        u-6tb1.metal
        u-9tb1.metal
        z1d
      )

      instance_classes.any? { |instance_class| node['ec2']['instance_type'].include?(instance_class) }
    end
  end
end
