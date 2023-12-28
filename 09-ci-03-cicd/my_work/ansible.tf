resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl",{

    vmservers =  yandex_compute_instance.VM
  })

  filename = "${abspath(path.module)}/hosts.cfg"
}


resource "null_resource" "web_hosts_provision" {
#Ждем создания инстанса
depends_on = [
    yandex_compute_instance.VM
]

#Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  provisioner "local-exec" {
    command = "cat ~/.ssh/yacloud | ssh-add -"
  }

##Костыль!!! Даем ВМ 60 сек на первый запуск. Лучше выполнить это через wait_for port 22 на стороне ansible
## В случае использования cloud-init может потребоваться еще больше времени
# provisioner "local-exec" {
#    command = "sleep 60"
#  }


  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install epel-release",
      "sudo yum -y install python"
    ]
    connection {
      type        = "ssh"
      user        = "centos"
      host        = join(",", yandex_compute_instance.VM[*].sonar-01.network_interface.0.nat_ip_address)
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install epel-release",
      "sudo yum -y install python"
    ]
    connection {
      type        = "ssh"
      user        = "centos"
      host        = join(",", yandex_compute_instance.VM[*].nexus-01.network_interface.0.nat_ip_address)
    }
  }

#Запуск ansible-playbook
#  provisioner "local-exec" {
#    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/playbook.yml"
#    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
#    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
#    #срабатывание триггера при изменении переменных
#  }
#    triggers = {
#      always_run         = "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
#      playbook_src_hash  = file("${abspath(path.module)}/playbook.yml") # при изменении содержимого playbook файла
#      ssh_public_key     = "${file("/Users/aleksandrgrebeshkov/.ssh/yacloud.pub")}" # при изменении переменной
#    }
}
