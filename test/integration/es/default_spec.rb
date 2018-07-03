# Inspec test for recipe ds_base::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

{
  '/dev/xvdb' => { mountpoint: '/mnt/dev0', fstype: 'ext3' },
  '/dev/xvdc' => { mountpoint: '/mnt/dev1', fstype: 'ext3' },
  '/dev/xvde' => { mountpoint: '/mnt/ebs0', fstype: 'ext4' },
}.each do |device, prop|
  describe mount prop[:mountpoint] do
    its('device') { should eq device }
    its('type') { should eq prop[:fstype] }
    its('options') { should eq ['rw', 'relatime', 'data=ordered'] }
  end
end

describe mount '/mnt' do
  it { should_not be_mounted }
end
