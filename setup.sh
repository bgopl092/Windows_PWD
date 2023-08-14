clear 
cd /root
echo "Go to: https://dashboard.ngrok.com/get-started/your-authtoken"
read -p "Paste Ngrok Authtoken: " CRP
echo "Setup is Starting...."
apt update -y
apt upgrade -y
apt install qemu qemu-utils ovmf -y
apt install qemu-kvm -y
wget 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz'
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1CClaOwHCfatYDbgYmX0r_TmDxlQOq7il' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1CClaOwHCfatYDbgYmX0r_TmDxlQOq7il" -O windows.tar.xz && rm -rf /tmp/cookies.txt
tar xvzf windows.tar.xz -C /root
tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
rm -rfv windows.tar.xz ngrok-v3-stable-linux-amd64.tgz
ngrok config add-authtoken $CRP
echo "Repo: https://github.com/bgopl092/Windows_PWD"
echo "================================================"
echo "Choose ngrok region (for better connection)."
echo "================================================"
echo "us - United States (Ohio)"
echo "eu - Europe (Frankfurt)"
echo "ap - Asia/Pacific (Singapore)"
echo "au - Australia (Sydney)"
echo "sa - South America (Sao Paulo)"
echo "jp - Japan (Tokyo)"
echo "in - India (Mumbai)"
read -p "Choose ngrok region: " CRP
ngrok tcp --region $CRP 3389 &>/dev/null &
sleep 1
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels  > /dev/null 2>&1; then echo OK; else echo "Ngrok Error! Please try again!" && sleep 1 && goto ngrok; fi
echo IP Address:
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p' 
echo User: PlayWithDocker
echo Passwd: PWDLtsc1989
qemu-system-x86_64 \
-m 12G \
-cpu host,+nx,vmx=on \
-enable-kvm \
-drive file=/root/disk.qcow2,media=disk,format=raw,if=virtio,cache=none,aio=native \
-device usb-ehci,id=usb \
-device usb-tablet \
-smp 4 \
-vga virtio \
-machine type=pc,accel=kvm:tcg \
-rtc base=localtime,clock=vm \
-device virtio-net-pci,netdev=net0 \
-bios /usr/share/ovmf/OVMF.fd \
-netdev user,id=net0,hostfwd=tcp::3389-:3389 \
-vnc :0
