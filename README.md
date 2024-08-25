# padavan #

This project is based on original rt-n56u with latest mtk 4.4.198 kernel, which is fetch from D-LINK GPL code.

##### Enhancements in this repo

- commits has beed rewritten on top of [hanwckf/rt-n56u](https://github.com/hanwckf/rt-n56u) repo for better history tracking
- Optimized Makefiles and build scripts, added a toplevel Makefile
- Added ccache support, may save up to 50%+ build time
- Upgraded the toolchain and libc:
  - gcc 10.3.0
  - uClibc-ng 1.0.47
 - Enabled kernel cgroups support
 - Fixed K2P led label names
 - Replaced udpxy with msd_lite
 - Replaced Web Console with ttyd
 - Upgraded libs and user packages
 - And a lot of package related fixes
 - ...

# Features

- Based on 4.4.198 Linux kernel
- Support MT7621 based devices
- Support MT7615D/MT7615N/MT7915D wireless chips
- Support raeth and mt7621 hwnat with legency driver
- Support qca shortcut-fe
- Support IPv6 NAT based on netfilter
- Support WireGuard integrated in kernel
- Support fullcone NAT (by Chion82)
- Support LED&GPIO control via sysfs

# Supported devices

- CR660x
- JCG-Q20
- JCG-AC860M
- JCG-836PRO
- JCG-Y2
- DIR-878
- DIR-882
- K2P
- K2P-USB
- NETGEAR-BZV
- MR2600
- MI-4
- MI-R3G
- MI-R3P
- R2100
- XY-C1
- GHL(from https://github.com/fangenhui520/padavan-4.4, 没有机器测试，自行判断)
- EA7500(from https://github.com/MNM28/padavan-4.4, 没有机器测试，自行判断)
- R6800(from https://github.com/MNM28/padavan-4.4, 没有机器测试，自行判断)
- TX1801 Plus(from https://github.com/MNM28/padavan-4.4, 没有机器测试，自行判断)
- JDCloud RE-CP-02(无线宝鲁班, from https://github.com/240038901/padavan-4.4, 没有机器测试，自行判断)
- JDCloud RE-SP-01B(from https://github.com/MeIsReallyBa/padavan-4.4, 没有机器测试，自行判断)
- NEWIFI3(from https://github.com/GH-X/padavan-4.4, 必须拆除主板上编号为C48的电容(位于CPU旁边), 否则外网(WAN)将不能正常工作)
- MI-R4A(from https://github.com/vipshmily/padavan-4.4, 没有机器测试，自行判断)
- QM-B1(from https://github.com/monw/padavan, 没有机器测试，自行判断)
- WE410443-TC(from https://github.com/akw28888/padavan-4.4, 没有机器测试，自行判断)
- HAR-20S2U1(from https://github.com/vb1980/padavan-4.4, 没有机器测试，自行判断)
- SIM-AX1800T(from https://github.com/vb1980/padavan-4.4, 自测可用)
- G-AX1800(富春江G-AX1800, from https://github.com/ddyjyj/padavan-4.4, 自测可用)
- G-AX1800-B(富春江G-AX1800黑色版本, 网口配置和白色版不一样，4根天线都是ipex可拆，ttl排针焊接好了，做工比白色版好些， from https://github.com/vb1980/padavan-4.4, 自测可用)
- WIA3300-10(西加云杉WIA3300-10，据说和K2P配置差不多，from https://github.com/vb1980/padavan-4.4, 自测可用)
- JCQ-Q11Pro(from https://github.com/qewwqewq22/padavan11, 没有机器测试，自行判断)
- R7450(from https://github.com/vipshmily/padavan-4.4, 没有机器测试，自行判断)
- 360-T6M(from https://github.com/BINGHUAice/padavan-4.4, 没有机器测试，自定判断)
# Compilation steps

- Install dependencies
  ```sh
  # Debian/Ubuntu
  sudo apt install unzip libtool-bin ccache curl cmake gperf gawk flex bison nano xxd \
      fakeroot kmod cpio git python3-docutils gettext automake autopoint \
      texinfo build-essential help2man pkg-config zlib1g-dev libgmp3-dev \
      libmpc-dev libmpfr-dev libncurses5-dev libltdl-dev wget libc-dev-bin
  ```
  **Optional:** install [golang](https://go.dev/doc/install) (and add it to PATH), if you are going to build go programs
- Clone source code
  ```sh
  git clone https://github.com/vb1980/padavan-4.4.git
  ```
- Modify template file and start compiling
  ```sh
  # (Optional) Modify template file
  # vi trunk/configs/templates/K2P.config

  # Start compiling with: make PRODUCT_NAME
  make K2P

  # To build firmware for other devices, clean the tree after previous build
  make clean
  ```

# Package Development

- Makefile examples
  - [Makefile project](trunk/libs/libpcre/Makefile) 
  - [CMake project](trunk/user/ttyd/Makefile)
- Compiling a single package (cd to `trunk` first)
  - build: `make libs/libpcre_only`
  - clean: `make libs/libpcre_clean`
  - romfs: `make libs/libpcre_romfs`

# Manuals

- Controlling GPIO and LEDs via sysfs
- How to use NAND RWFS partition
- How to use IPv6 NAT and fullcone NAT
- How to add new device support with device tree
