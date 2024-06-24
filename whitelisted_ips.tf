resource "aws_wafv2_ip_set" "whitelisted_ips" {
  name               = "whitelisted_ips"
  description        = "Whitelisted IPs"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = [
    "92.192.192.192/32",
    "92.192.192.192/32",
  ]
}
