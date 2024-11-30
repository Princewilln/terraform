
output "instance_ip_addr" {
  value = module.myapp-ec2.instance_ip_addr.public_ip
}