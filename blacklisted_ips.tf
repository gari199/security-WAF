resource "aws_wafv2_ip_set" "blacklisted_ips" {
  name               = "blacklisted_ips"
  description        = "Blacklisted IPs"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = [
    "192.192.192.192/32",
    "92.192.192.192/32",
  ]
}