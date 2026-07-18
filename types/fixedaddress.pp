# A DHCPv4 fixed-address value: an IPv4 address or a DNS hostname.
#
# DNS names are rendered as unquoted ISC DHCP configuration tokens, so this
# type deliberately excludes whitespace and configuration punctuation.
type Dhcp::FixedAddress = Variant[
  Stdlib::IP::Address::V4::Nosubnet,
  Pattern[/\A(?=.{1,253}(?:\.)?\z)(?![0-9]+(?:\.[0-9]+){3}\.?\z)[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\.?\z/],
]
