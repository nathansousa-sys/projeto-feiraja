# Criação da VM-BI-FeiraJa (passo a passo)

```bash
# 1. Disco virtual de 40 GB (qcow2, alocação dinâmica) a partir da imagem oficial do Ubuntu Server 24.04
qemu-img create -f qcow2 -F qcow2 -b noble-server-cloudimg-amd64.img vm-bi-feiraja.qcow2 40G

# 2. Disco de configuração inicial (cloud-init)
cloud-localds seed.iso user-data meta-data

# 3. Criação e inicialização da VM (2 vCPUs, 4 GB RAM, portas 22 e 3000)
qemu-system-x86_64 -name VM-BI-FeiraJa -machine q35 -cpu max -smp 2 -m 4096 \
  -drive file=vm-bi-feiraja.qcow2,if=virtio,format=qcow2 \
  -drive file=seed.iso,if=virtio,format=raw \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22,hostfwd=tcp:127.0.0.1:3000-:3000 \
  -device virtio-net-pci,netdev=net0 -vnc 127.0.0.1:1
```

Dentro da VM:

```bash
sudo apt update
sudo apt install -y postgresql
sudo -u postgres createdb dw_feiraja
sudo -u postgres psql -d dw_feiraja < modelo_dw_feiraja.sql
sudo -u postgres psql -d dw_feiraja < carga_teste.sql
sudo apt install -y openjdk-21-jre-headless
sudo mkdir -p /opt/metabase && sudo curl -sSL -o /opt/metabase/metabase.jar https://downloads.metabase.com/latest/metabase.jar
sudo useradd -r -s /usr/sbin/nologin metabase && sudo chown -R metabase:metabase /opt/metabase
sudo cp metabase.service /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now metabase
sudo ufw allow 22/tcp && sudo ufw allow 3000/tcp && sudo ufw --force enable
```

Snapshot (com a VM desligada): `qemu-img snapshot -c pos-instalacao vm-bi-feiraja.qcow2`
