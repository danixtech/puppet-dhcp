# frozen_string_literal: true

require 'spec_helper'

describe 'dhcp::pool', type: :define do
  let :title do
    'test_pool'
  end
  let(:facts) do
    {
      concat_basedir: '/dne',
      os: {
        family: 'RedHat',
        release: { major: '8' }
      }
    }
  end
  let :default_params do
    {
      'gateway' => '1.1.1.1',
      'mask' => '255.255.255.0',
      'host_mask' => '255.255.255.128',
      'network' => '1.1.1.0',
      'range' => '1.1.1.100 1.1.1.110'
    }
  end

  context 'creates a pool definition' do
    let(:params) { default_params }

    it { is_expected.to contain_concat__fragment("dhcp_pool_#{title}") }
  end

  context 'when optional parameters defined' do
    let(:params) do
      default_params.merge(
        'on_commit' => [
          'set ClientIP = binary-to-ascii(10, 8, ".", leased-address)',
          'execute("/usr/local/bin/my_dhcp_helper.sh", ClientIP)'
        ],
        'on_release' => [
          'set ClientIP = binary-to-ascii(10, 8, ".", leased-address)',
          'log(concat("Released IP: ", ClientIP))'
        ],
        'on_expiry' => [
          'set ClientIP = binary-to-ascii(10, 8, ".", leased-address)',
          'log(concat("Expired IP: ", ClientIP))'
        ]
      )
    end

    it 'creates a pool declaration with optional parameters' do
      content = catalogue.resource('concat::fragment', "dhcp_pool_#{title}").send(:parameters)[:content]
      expected_lines = [
        '#################################',
        "# #{title} #{params['network']} #{params['mask']}",
        '#################################',
        "subnet #{params['network']} netmask #{params['mask']} {",
        '  pool',
        '  {',
        "    range #{params['range']};",
        '  }',
        '',
        "  option subnet-mask #{params['host_mask']};",
        "  option routers #{params['gateway']};",
        '  on commit {',
        '    set ClientIP = binary-to-ascii(10, 8, ".", leased-address);',
        '    execute("/usr/local/bin/my_dhcp_helper.sh", ClientIP);',
        '  }',
        '  on release {',
        '    set ClientIP = binary-to-ascii(10, 8, ".", leased-address);',
        '    log(concat("Released IP: ", ClientIP));',
        '  }',
        '  on expiry {',
        '    set ClientIP = binary-to-ascii(10, 8, ".", leased-address);',
        '    log(concat("Expired IP: ", ClientIP));',
        '  }',
        '}',
      ]
      expect(content.split("\n")).to match_array(expected_lines)
    end
  end

  context 'with max_lease_time defined' do
    let(:params) { default_params.merge('max_lease_time' => 3600) }

    it 'renders max-lease-time inside the pool block' do
      is_expected.to compile
      content = catalogue.resource('concat::fragment', "dhcp_pool_#{title}").send(:parameters)[:content]
      expect(content).to match(%r{pool\s*\{.*?max-lease-time 3600;.*?\}}m)
    end
  end

  [-1, 0].each do |lease_time|
    context "when max_lease_time is #{lease_time}" do
      let(:params) { default_params.merge('max_lease_time' => lease_time) }

      it 'renders the value' do
        is_expected.to contain_concat__fragment("dhcp_pool_#{title}").
          with_content(%r{^    max-lease-time #{lease_time};$})
      end
    end
  end

  context 'with only max_lease_time creating the inner pool block' do
    let(:params) do
      default_params.reject { |name, _value| name == 'range' }.
        merge('max_lease_time' => 3600)
    end

    it 'renders max-lease-time inside a pool block' do
      content = catalogue.resource('concat::fragment', "dhcp_pool_#{title}").send(:parameters)[:content]
      expect(content).to match(%r{pool\s*\{\s*max-lease-time 3600;\s*\}}m)
    end
  end

  [-2, '3600'].each do |lease_time|
    context "when max_lease_time is invalid: #{lease_time.inspect}" do
      let(:params) { default_params.merge('max_lease_time' => lease_time) }

      it { is_expected.not_to compile }
    end
  end

  context 'without max_lease_time' do
    let(:params) { default_params }

    it 'does not render max-lease-time' do
      is_expected.to contain_concat__fragment("dhcp_pool_#{title}").
        without_content(%r{max-lease-time})
    end
  end

  context 'without a range, failover, or max_lease_time' do
    let(:params) { default_params.reject { |name, _value| name == 'range' } }

    it 'preserves the absence of an inner pool block' do
      is_expected.to contain_concat__fragment("dhcp_pool_#{title}").
        without_content(%r{^  pool$})
    end
  end
end
