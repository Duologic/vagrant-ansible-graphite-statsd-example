provider "template" {
  version = "~> 2.0"
}

data "template_file" "inventory-monitor-relay" {
  count    = "${var.monitor_relay_count}"
  template = "${file("templates/hostname.tpl")}"

  vars {
    name         = "${aws_instance.monitor-relay.*.tags.Name[count.index]}"
    ansible_host = "${aws_instance.monitor-relay.*.public_ip[count.index]}"
    ansible_user = "${aws_instance.monitor-relay.*.tags.Username[count.index]}"
    extra        = ""
  }
}

data "template_file" "ansible_inventory" {
  template = "${file("templates/ansible_inventory.tpl")}"

  vars {
    env                 = "${var.aws_profile}"
    monitor_relay_hosts = "${join("",data.template_file.inventory-monitor-relay.*.rendered)}"
    carbon_caches       = "[127.0.0.1]"
    carbon_relay        = "127.0.0.1"
  }
}

output "ansible_inventory" {
  value = "${data.template_file.ansible_inventory.rendered}"
}