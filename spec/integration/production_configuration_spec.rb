# frozen_string_literal: true

require 'spec_helper'

describe 'dhcp', type: :class do
  let(:facts) do
    {
      concat_basedir: '/dne',
      os: {
        family: 'RedHat',
        name: 'RedHat',
        release: { major: '8' }
      },
      osfamily: 'RedHat',
      operatingsystem: 'RedHat'
    }
  end

  let(:params) do
    {
      'default_lease_time' => 86_400,
      'max_lease_time' => 7200,
      'dnsdomain' => ['example.test'],
      'nameservers' => ['192.0.2.53'],
      'interfaces' => ['eth0'],
      'manage_service' => false,
      'hosts' => {
        'dns-backed-host' => {
          'comment' => 'DNS-backed reservation',
          'mac' => '00:50:56:00:00:01',
          'ip' => 'reserved-host.example.test'
        }
      },
      'pools' => {
        'client-network' => {
          'network' => '192.0.2.0',
          'mask' => '255.255.255.0',
          'range' => ['192.0.2.100 192.0.2.199'],
          'gateway' => '192.0.2.1',
          'max_lease_time' => 3600
        }
      }
    }
  end

  def rendered_target(target)
    catalogue.resources.
      select { |resource| resource.type == 'Concat::Fragment' && resource[:target] == target }.
      sort_by { |resource| [resource[:order].to_s, resource.title] }.
      map { |resource| resource[:content] }.
      join
  end

  it 'compiles the representative catalog' do
    is_expected.to compile.with_all_deps
  end

  it 'assembles the main configuration with its generated includes' do
    content = rendered_target('/etc/dhcp/dhcpd.conf')

    expect(content).to include('default-lease-time 86400;')
    expect(content).to include('max-lease-time 7200;')
    expect(content).to include('include "/etc/dhcp/dhcpd.pools";')
    expect(content).to include('include "/etc/dhcp/dhcpd.hosts";')
  end

  it 'assembles a DNS-backed host reservation without quoting its address' do
    content = rendered_target('/etc/dhcp/dhcpd.hosts')

    expect(content).to include('host dns-backed-host {')
    expect(content).to include('fixed-address       reserved-host.example.test;')
    expect(content).not_to include('fixed-address       "reserved-host.example.test";')
  end

  it 'assembles pool-level lease time inside the inner pool scope' do
    content = rendered_target('/etc/dhcp/dhcpd.pools')

    expect(content).to match(
      %r{subnet 192\.0\.2\.0 netmask 255\.255\.255\.0 \{\s*pool\s*\{.*?max-lease-time 3600;.*?range 192\.0\.2\.100 192\.0\.2\.199;.*?\}}m
    )
  end
end
