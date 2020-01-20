#
# Cookbook:: jb_base
# Spec:: default
#
# Copyright:: 2013, Jeff Byrnes, All Rights Reserved.

require 'spec_helper'

describe 'storage::default' do
  context 'When all attributes are default, on Ubuntu 18.04, with /mnt/dev0 is already mounted' do
    platform 'ubuntu', '18.04'

    normal_attributes['storage'] = {}

    let(:storage) do
      double('storage', dev_names: ['/dev/xvdb', '/dev/xvdc'])
    end

    before do
      allow(File).to receive(:readlines).and_return(['/dev/xvdb /mnt/dev0 ext4 rw,relatime,data=ordered 0 0\n'])
      expect(StorageCookbook::Storage).to receive(:new).and_return(storage)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'disables mount /mnt' do
      expect(chef_run).to disable_mount('/mnt')
    end
  end
end
