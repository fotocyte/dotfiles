timedatectl set-ntp true
parted -s /dev/sda mklabel gpt
sgdisk /dev/sda -n=1:0:+1024M -t=1:ef00
sgdisk /dev/sda -n=2:0:0
mkfs.ext4 /dev/sda2
mkfs.fat -F32 /dev/sda1
mount /dev/sda2 /mnt

dd if=/dev/zero of=/mnt/swapfile bs=1G count=1
mkswap /mnt/swapfile
chmod 600 /mnt/swapfile
swapon /mnt/swapfile


echo 'Server = http://mirror.arizona.edu/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

wpa_supplicant -B -i wlan0 -c<(wpa_passphrase WIRELESSNET PASSWORD)

pacman -Sy
pacstrap /mnt base linux linux-firmware grub efibootmgr util-linux networkmanager networkmanager-openvpn

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Phoenix /etc/localtime
arch-chroot /mnt hwclock --systohc


echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
echo "tpad" > /mnt/etc/hostname

cat > /mnt/etc/hosts <<EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	tpad.localdomain	tpad
EOF

arch-chroot /mnt
mount /dev/sda1 /mnt
# install either amd-ucode or intel-ucode
# pacman -S *-ucode
grub-install --target=x86_64-efi --efi-directory=/mnt --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg


echo "now set the root password"
reboot
nmcli device wifi connect WIRELESSNET password PASSWORD
