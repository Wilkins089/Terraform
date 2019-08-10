variable "digitalocean_api_token" {}

provider "digitalocean" {
token = "${var.digitalocean_api_token}"

}

resource "digitalocean_droplet" "terraform" {
	image 	= "ubuntu-16-04-x64"
	name 	= "terraform-droplet"
	region	= "nyc3"
	size 	= "1GB"
	ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]

connection {
        user = "root"
        type = "ssh"
        host = "${digitalocean_droplet.terraform.ipv4_address}"
        private_key = "${file("/home/wortiz/.ssh/id_rsa")}"
        timeout = "2m"
}

provisioner "remote-exec" {
   	inline = [
      	"export PATH=$PATH:/usr/bin",
      	"apt-get update",
      	"apt-get -y install nginx",
	"apt-get -y install git",
	"rm -r /var/www/*",
	"rm /etc/nginx/sites-available/*",
	"git clone https://github.com/Wilkins089/urban-site.git /var/www/",
	"mv /var/www/urban-site /etc/nginx/sites-available/",
	"ln -s /etc/nginx/sites-available/urban-site /etc/nginx/sites-enabled/",
	"systemctl restart nginx"
	
    ]
  }
}

resource "digitalocean_ssh_key" "default"{
	name 	= "Terraform KEY"
	public_key = "${file("/home/wortiz/.ssh/id_rsa.pub")}"
}

output "terraform_ip_address" {
	value = "${digitalocean_droplet.terraform.ipv4_address}"
}





