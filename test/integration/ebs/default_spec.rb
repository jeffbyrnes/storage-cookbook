# Inspec test for recipe ds_base::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe mount '/mnt/ebs0' do
  its('device') { should eq '/dev/xvde' }
  its('type') { should eq 'ext4' }
  its('options') { should eq ['rw', 'relatime', 'data=ordered'] }
end

describe mount '/mnt' do
  it { should_not be_mounted }
end
