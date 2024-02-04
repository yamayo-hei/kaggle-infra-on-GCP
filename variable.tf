# project ID
variable "project" {
  default = ""
}

# サービスアカウントキー（.json）
variable "credentials" {
  default = ""
}

# firewallに登録するアドレス
variable "your_ip_address" {
  default = "XXX.XXX.XXX.XXX/32"
}

variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1-a"
}

variable "instance_name" {
  default = "kaggle-vm"
}

# 任意のマシンタイプを入力してください
# -------------------------------------------   
# n1-standard-1  vCPU:1	 メモリ（GB）:3.75
# n1-standard-2	 vCPU:2	 メモリ（GB）:7.50
# n1-standard-4	 vCPU:4	 メモリ（GB）:15	 
# n1-standard-8	 vCPU:8	 メモリ（GB）:30	 
# n1-standard-16 vCPU:16 メモリ（GB）:60  
# n1-standard-32 vCPU:32 メモリ（GB）:120
# n1-standard-64 vCPU:64 メモリ（GB）:240
# n1-standard-96 vCPU:96 メモリ（GB）:360
# -------------------------------------------
variable "machine_type" {
  default = "n1-standard-1"
}
