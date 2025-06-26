## Configuring the Boot Menu in Ubuntu
```bash
$ sudo update-grub
```
just write grub.cfg. not write in to dist

## search in Vim
```bash
$ /search goal
```
[Reference](https://linuxhint.com/search-in-vim/)
[Reference2](https://officeguide.cc/vim-search-operations-tutorial-examples/)

## Why is Grub menu not shown when starting my computer
```
This did the trick for me:

$ sudo gedit /etc/default/grub

I changed these two:

GRUB_TIMEOUT_STYLE=hidden -> GRUB_TIMEOUT_STYLE=menu

GRUB_TIMEOUT=0 -> GRUB_TIMEOUT=10

after changes run $ sudo update-grub

$ reboot
```
[Reference](https://askubuntu.com/questions/182248/why-is-grub-menu-not-shown-when-starting-my-computer)
```
GRUB_TIMEOUT_STYLE=menu
```
:::success
If you have modified this file then you need to run update-grub for it to take effect. This will automatically be run each time a new kernel is installed by sudo apt full-upgrade
:::

### Ubuntu change right
因為你沒弄搞 sudo 跟 su 的差別

sudo 是要求 root 的權限，這邊輸入密碼是再次確保是帳號的擁有者操作，不是某個人看到別人忘了登出跑來用的，所以輸入的是自己的密碼

su 是切換到別人的帳號，跟登入是一樣的，所以輸入的是要登入的那個帳號的密碼，比如 su root 那你要輸入的就是 root 的密碼，不是你自己的

另外 root 有權限直接切換成任何人的帳號，也不需要密碼，所以另一個回答中，用 sudo su root 是能輸入自己的密碼就切換成 root 的，這邊是先用自己的密碼通過 sudo 的驗證，轉成 root 後再用 root 的不用輸入密碼的特權用 su 切換帳號

另外 sudo 也有個參數 -s ，可以用 root 的身份執行你目前的 shell ，用法就像這樣：
```
$ sudo -s
```
如果是要用 root 執行 shell ，我自己是比較喜歡這樣
[Reference](https://ithelp.ithome.com.tw/questions/10200522)

## 自制開機menu組態
[Reference](https://hugh712.gitbooks.io/grub/content/multi-boot-manual-config.html)

## Unable to edit grub.cfg
```
$ sudo vim /boot/grub/grub.cfg
```
[Reference](https://www.linuxquestions.org/questions/ubuntu-63/unable-to-edit-grub-cfg-file-4175615700/)
## 用 grub 更新開機選單
[Reference] (https://blog.zeroplex.tw/2014/01/19/grub/)
 Posted on2014 年 1 月 19 日  By日落 在〈用 grub 更新開機選單〉中尚無留言
安裝第二套作業系統並作多重開機，但把原來的開機程式蓋掉，開機選單一團亂，只好手動改。

Ubuntu 的開機選單設定放在 /boot/grub/grub.cfg，可以先用 update-grub (grub-mkconfig) 掃描現有可以開機的位置，並更新到 grub.cfg 設定檔：

```
$ sudo update-grub
```
or
```
$ sudo grub-mkconfig -o /boot/grub/grub.cfg
```
接個編輯 grub.cfg，改成需要的樣子存檔。存檔後還需要寫入 MBR，設定才能生效：
```
$ sudo grub-install /dev/sda
```

### Actually I just command
在這裡喔 /boot/grub/grub.cfg
```bash
$ sudo vim grub.cfg
```
vim add these

```bash
$ sudo grub-install /dev/sda
Installing for x86_64-efi platform.
Installation finished. No error reported.
```
then it will show it cannot find EFI

### My back up is in
/home/weihsin/initial/boot/grub
then in the ==grub.cfg== file

add these in line 162
```
### BEGIN /etc/grub.d/30_os-prober ###
menuentry 'Windows Boot Manager (on /dev/nvme0n1p1)' --class windows --class os $menuentry_id_option 'osprober-efi-A20A-F46F' {
	insmod part_gpt
	insmod fat
	if [ x$feature_platform_search_hint = xy ]; then
	  search --no-floppy --fs-uuid --set=root  A20A-F46F
	else
	  search --no-floppy --fs-uuid --set=root A20A-F46F
	fi
	chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
set timeout_style=menu
if [ "${timeout}" = 0 ]; then
  set timeout=10
fi
### END /etc/grub.d/30_os-prober ###
```

I back up it in my github also
![image](https://github.com/weihsinyeh/Linux/assets/90430653/59a48d8f-5ab9-4deb-bac2-ecf77763ec02)
