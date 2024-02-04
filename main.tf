provider "google" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["iap-ssh", "jupyter"]

  guest_accelerator {
    type = "nvidia-tesla-t4"
    count = 1
  }
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 100
    }
  }

  network_interface {
    # 自分で定義したsubnetwork内にインスタンスを起動する
    network    = google_compute_network.my_network.name
    subnetwork = google_compute_subnetwork.my_subnetwork.name
    # 外部IPアドレスを割り振る方法は次の2種類ある。静的外部IPアドレス、エフェメラル外部IPアドレス
    access_config {
      # nat_ip = "${google_compute_address.default.address}"
    }
  }

  scheduling {
    # 料金を抑えるためにプリエンプティブルにしておく
    preemptible = true
    # プリエンプティブルの場合は下のオプションが必須
    automatic_restart = false
    # gpu使用する場合は設定必須
    on_host_maintenance = "TERMINATE"
  }

  # Install
  metadata_startup_script = <<EOF
#!/bin/bash
sudo timedatectl set-timezone Asia/Tokyo
sudo apt update
sudo apt upgrade
sudo apt install git
# dockerインストール
## 依存パッケージインストール
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
## Dockerの公式GPGキーを追加
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
## Dockerリポジトリ登録
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
## Docker Engineのインストール
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
# docker compose インストール
## インストール先ディレクトリを作成
sudo mkdir -p /usr/local/libexec/docker/cli-plugins
cd /usr/local/libexec/docker/cli-plugins
## リリースモジュールをダウンロードし、docker-composeという名前でインストール先に保存
sudo curl -L https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o docker-compose
## docker-composeを実行可能にする
sudo chmod +x docker-compose
# dockerへの権限付与
sudo chmod 666 /var/run/docker.sock
EOF
}

resource "google_compute_network" "my_network" {
  name = "my-network"
  # リージョンごとにサブネットを自動で作成してくれます。今回は使わないのでfalseにします。
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "my_subnetwork" {
  name   = "my-subnetwork"
  region = var.region

  # サブネットで使用したい内部IPアドレスの範囲を指定する
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.my_network.id

  # CloudLoggingにFlowLogログを出力したい場合は設定する
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "ssh" {
  name = "allow-iap-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.my_network.id
  priority      = 1000
  source_ranges = ["35.235.240.0/20"] # IAPのアドレス範囲
  target_tags   = ["iap-ssh"]
}

resource "google_compute_firewall" "allow_jupyter_port" {
  name = "allow-jupyter-port"
  allow {
    ports    = ["8888"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.my_network.id
  priority      = 1000
  source_ranges = [var.your_ip_address] # グローバルIPアドレスをセット
  target_tags   = ["jupyter"]
}
