# Inspec test for recipe ds_base::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

{
  '/dev/nvme1n1' => '/mnt/dev0',
}.each do |device, mountpoint|
  describe mount mountpoint do
    its('device') { should eq device }
    its('type') { should eq 'ext4' }
    its('options') { should eq ['rw', 'relatime', 'data=ordered'] }
  end
end

describe mount '/mnt' do
  it { should_not be_mounted }
end
