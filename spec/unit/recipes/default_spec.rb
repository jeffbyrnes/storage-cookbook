require 'spec_helper'

describe 'storage::default' do
  context '/mnt/dev0 is already mounted' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '18.04') do |node|
        node.normal['storage'] = {}
        allow(File).to receive(:readlines).and_return(
          ['/dev/xvdb /mnt/dev0 ext4 rw,relatime,data=ordered 0 0\n']
        )
      end.converge(described_recipe)
    end

    let(:storage) do
      double('storage', dev_names: ['/dev/xvdb', '/dev/xvdc'])
    end

    before { expect(StorageCookbook::Storage).to receive(:new).and_return(storage) }

    it 'disables mount /mnt' do
      expect(chef_run).to disable_mount('/mnt')
    end
  end
end
