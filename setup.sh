clear 
cd /root
echo "Go to: https://dashboard.ngrok.com/get-started/your-authtoken"
read -p "Paste Ngrok Authtoken: " CRP
echo "Setup is Starting...."
apt update -y
apt upgrade -y
apt install qemu qemu-utils ovmf curl -y
apt install qemu-kvm -y
ngrok config add-authtoken $CRP
sleep 1
echo "======================="
echo "choose ngrok region (for better connection)."
echo "======================="
echo "us - United States (Ohio)"
echo "eu - Europe (Frankfurt)"
echo "ap - Asia/Pacific (Singapore)"
echo "au - Australia (Sydney)"
echo "sa - South America (Sao Paulo)"
echo "jp - Japan (Tokyo)"
echo "in - India (Mumbai)"
read -p "choose ngrok region: " CRD
ngrok tcp --region $CRD 3389 &>/dev/null &
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
