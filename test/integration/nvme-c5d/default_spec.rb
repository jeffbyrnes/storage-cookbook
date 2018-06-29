# Inspec test for recipe ds_base::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

describe mount '/mnt/dev0' do
  its('device') { should match %r{/dev/nvme\dn1} }
  its('type') { should eq 'ext4' }
  its('options') { should eq ['rw', 'relatime', 'data=ordered'] }
end

describe mount '/mnt/ebs0' do
  its('device') { should eq '/dev/nvme2n1' }
  its('type') { should eq 'ext4' }
  its('options') { should eq ['rw', 'relatime', 'data=ordered'] }
end

describe mount '/mnt' do
  it { should_not be_mounted }
end
