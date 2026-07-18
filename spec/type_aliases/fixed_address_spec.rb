# frozen_string_literal: true

require 'spec_helper'

describe 'Dhcp::FixedAddress' do
  it do
    is_expected.to allow_values(
      '192.0.2.10',
      'server1',
      'server1.example.test',
      'Server-1.Example.Test',
      'server1.example.test.',
      'xn--bcher-kva.example'
    )
  end

  describe 'invalid value handling' do
    [
      '2001:db8::1',
      '192.0.2.1/24',
      '999.999.999.999',
      '-server.example.test',
      'server-.example.test',
      'server name.example.test',
      'server.example.test,other.example.test',
      'server.example.test;',
      'server.example.test"',
      "server.example.test\nnext-server 192.0.2.1"
    ].each do |value|
      it { is_expected.not_to allow_value(value) }
    end
  end
end
