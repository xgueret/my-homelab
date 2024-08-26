# HomeLab

#Proxmox #Ansible #Terraform #K8s #Kubeadm #k9s

[TOC]



## Proxmox

![](./Images/proxmox.png)

:eyes: https://www.proxmox.com/en/

Download the ISO for version **7.4-1**:

```shell
wget https://enterprise.proxmox.com/iso/proxmox-ve_7.4-1.iso
```

Verify the integrity of the download:

```shell
echo "55b672c4b0d2bdcbff9910eea43df3b269aaab3f23e7a1df18b82d92eb995916 proxmox-ve_7.4-1.iso" | sha256sum -c
```



### How to Create a Bootable USB Drive

> You can also use [Ventoy](https://www.ventoy.net/en/index.html) to create a bootable USB drive with multiple ISO images.

List the connected storage devices and drives with details:

```shell
df
```

To find information about your USB drive, list the connected devices:

> This command displays the system's partitions:

```shell
sudo fdisk -l
```

Or simply use the `lsblk` command:

```shell
lsblk
```

Format the USB drive (in this case, the USB is mounted at `/dev/sdb1`):

```shell
sudo mkfs.vfat -n 'UTILS' -I /dev/sdb1
```

> (i) Note: If necessary, unmount the USB drive:
>
> ```shell
> sudo umount /dev/sdb1
> ```

Create the bootable USB drive using **dd**:

```shell
sudo dd if=./proxmox-ve_7.4-1.iso of=/dev/sdb status=progress
```



>  To access the BIOS on my PC during startup, press the **Escape** key.
>
> In the **Advanced** tab, ensure the **Intel VT** option is enabled.
>
> After making these changes, select "**Save and Exit**."
>
> Upon reboot, press **F12** and then hit Enter.
>
> Select "**Install Proxmox VVE (Graphical)**."



### SSH Configuration on My Linux Workstation

Connect to the Proxmox server via SSH and create an SSH key pair:

```shell
ssh-keygen -t rsa -b 4096 -f ~/.ssh/proxmox -C "root@192.168.1.64"
```

> :information_source: *Include a passphrase if necessary.*
>
> ```shell
> ls -al ~/.ssh
> ```

Copy the public key to the Proxmox server:

```shell
ssh-copy-id -i ~/.ssh/proxmox.pub root@192.168.1.64
```

(Optional) Activate the SSH agent:

```shell
eval $(ssh-agent)
ssh-add ~/.ssh/proxmox
ssh root@192.168.1.64
```



## Infrastructure as Code (IaC)

### Step 1: Configure Proxmox

#### Preparing Proxmox to be Managed by Ansible

```shell
ssh root@192.168.1.64
```

```shell
apt install sudo
```

(i) From the workstation with Ansible installed:

```shell
cd Proxmox/iac/etape1
ansible-playbook -u root prepare_vm.yml --tags "bootstrap-vm"
```

#### Creating a VM Template

```shell
cd Proxmox/iac/etape1
ansible-playbook -u ansible prepare_vm.yml --tags "create_vm_template"
```

### Step 2: Provision VMs for the K8s Cluster

Connect to the Proxmox server:

```shell
ssh root@192.168.1.64
```

Create a Terraform provisioning role:

```shell
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
pveum user add terraform-prov@pve --password secure1234
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

Create a token:

```shell
pveum user token add terraform-prov@pve terraform -expire 0 -privsep 0 -comment "Terraform token"
```



:warning: Before proceeding, add the **`terraform.tfvars`** file to the **Proxmox/iac/etape2** directory.

(i) Replace `192.168.1.64` with your local IP address:

```
proxmox_api_url = "https://192.168.1.64:8006/api2/json"
ssh_key = "votre clef public"
```



Provision VMs for setting up a Kubernetes cluster with Kubeadm:

```shell
cd Proxmox/iac/etape2
export PM_API_TOKEN_ID='terraform-prov@pve!terraform' 
export PM_API_TOKEN_SECRET="[le token généré précédemment]" 
terraform init
terraform plan
terraform apply
```

### Step 3: Install the K8s Cluster (Kubeadm)

```shell
cd Kubernetes/iac
ansible-playbook -u ubuntu setup-k8s.yml

```



![](./Images/k8s-ready-to-use.png)





 :tada: Enjoy!!!!

# Outils

## k9s

![](./Images/k9s.png)



[K9S](https://k9scli.io/) is a tool written in GO that allows you to manage a Kubernetes cluster with lots of shortcuts and colors. :smiley:

### How to Install It?

> On Linux, install [Homebrew](https://docs.brew.sh/Installation):

```shell
brew install derailed/k9s/k9s
```

### How to Configure k9s to Connect to the K8s Cluster?

To interact with your K8s cluster, k9s needs to read the `~/.kube/config` file. This file and directory do not yet exist on your workstation.

First, connect to your `k8s-0` VM and retrieve the contents of the `.kube/config` file (admin context, which can be changed later). Then, on your workstation, create a `.kube` directory, add a `config` file inside, and paste the content you copied. Done! :tada:

Launch k9s from the command line...

![k9s Ready](./Images/k9s-ready-to-use.png)

![](./Images/k9s-ready-to-use.png)

You will also need to install the `kubectl` CLI on your workstation  [[doc](https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/)]

```shell
# Debian/ubuntu
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```



(i) For example, in k9s, when you want to edit a pod's manifest.



## :facepunch: Contribution

Contributions are welcome! If you'd like to contribute, please follow these steps:

1. **Fork the repository** to your own GitHub account.
2. **Clone your fork** locally:

```shell
git clone https://github.com/yourusername/my-homelab.git
cd manage-repo
```

**Create a new branch** for your feature or bug fix:

```shell
git checkout -b my-new-feature
```

**Make your changes** and commit them with a clear message:

```shell
git commit -m "Add new feature"
```

**Push your branch** to your fork:

1. ```shell
   git push origin my-new-feature
   ```

2. **Open a Pull Request** on the original repository and describe your changes.

By following these steps, you can help improve the project for everyone!





# Index

## How to Add a Storage Space

:eyes: https://nubcakes.net/index.php/2019/03/05/how-to-add-storage-to-proxmox/

## Terraform

:eyes: https://developer.hashicorp.com/terraform/install



