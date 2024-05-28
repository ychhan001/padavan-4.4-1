#!/bin/bash

#根据编译的路由器型号，自动替换logo图片
#使用方法：在编译命令之前，执行`sh change_logo.sh 路由器型号`


LOGO_DIR=$PWD/user/www/logo
THEME_DIR=$PWD/user/www/n56u_ribbon_fixed/bootstrap/img
ROUTER=$1
if [ "$2" ];then
THEME_DIR=$PWD/user/www/n56u_rainbow/bootstrap/img
fi

case $ROUTER in
5K-W20 )
	LOGO=5k.png
	;;
360P2 | 360-T6M | 360-T6M-PB )
	LOGO=360.png
	;;
A3004NS )
	LOGO=totolink.png
	;;
B70 | HC5661A | HC5761A | HC5861B )
	LOGO=gee.png
	;;
BELL-A040WQ )
	LOGO=bell.png
	;;
CR660x | MI-3 | MI-4 | MI-R3G | MI-R3P | MI-R3P-PB | MI-NANO | MI-MINI | R2100 | RM2100 )
	LOGO=miwifi.png
	;;
DIR-878 | DIR-878-5.0 | DIR-882 | DIR-882-5.0)
	LOGO=dlink.png
	;;
GHL )
	LOGO=ghl.png
	;;
JCG-836PRO | JCG-836PRO-5.0 | JCG-AC836M | JCG-AC856M | JCG-AC856M-5.0 | JCG-AC860M | JCG-AC860M-5.0 | JCG-Q20 | JCG-Y2 | JCG-Y2-5.0 )
	LOGO=jcg.png
	;;
JDC-1 | JDC-1-5.0 )
	LOGO=jdc.png
	;;
K2P | K2P-5.0 | K2P_nano | K2P_nano-5.0 | K2P-USB | K2P-USB-5.0 | K2P-USB-512 | K2P-USB-512-5.0 | PSG1218_nano | PSG1218 | PSG1208 | PSG712 )
	LOGO=phicomm.png
	;;
MR2600 | MR2600-5.0)
	LOGO=motorola.png
	;;
MSG1500 | MSG1500-7615 )
	LOGO=raisecom.png
	;;
NETGEAR-BZV )
	LOGO=netgear.png
	;;
NEWIFI | NEWIFI-MINI | NEWIFI-D1 | NEWIFI3 )
	LOGO=newifi.png
	;;
MZ-R18 | MZ-R13P | MZ-R13 )
	LOGO=meizu.png
	;;
OYE-001 )
	LOGO=oye.png
	;;
RE6500 )	
	LOGO=linksys.png
	;;
RT-AC85P | RT-AC1200GU)
	LOGO=asus.png
	;;
WDR7300 )
	LOGO=tplink.png
	;;
WR1200JS )
	LOGO=youhua.png
	;;
XY-C1 )
	LOGO=xiaoyu.png
	;;
YK-L1 )
	LOGO=yk.png
	;;
ZTE-E8820S | E8820V2)
	LOGO=zte.png
	;;
WIA3300-10)
	LOGO=skspruce.png
	;;
G-AX1800)
	LOGO=fcj.png
* )
	LOGO=asus_logo.png
	;;
esac

cp -f $LOGO_DIR/$LOGO $THEME_DIR/asus_logo.png
