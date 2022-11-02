<!DOCTYPE html>
<html>
	<head>
		<title>
			<#Web_Title#>
		</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta http-equiv="Pragma" content="no-cache">
		<meta http-equiv="Expires" content="-1">
		<link rel="shortcut icon" href="images/favicon.ico">
		<link rel="icon" href="images/favicon.png">
		<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
		<link rel="stylesheet" type="text/css" href="/iconmoon/css/iconmoon.css">
		<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
		<script type="text/javascript" src="/jquery.js">
		</script>
		<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js">
		</script>
		<script type="text/javascript" src="/state.js">
		</script>
		<script type="text/javascript" src="/popup.js">
		</script>
		<script type="text/javascript" src="/disk_functions.js">
		</script>
		<script type="text/javascript" src="/client_function.js">
		</script>
		<script>
			var $j = jQuery.noConflict();

<% disk_pool_mapping_info(); %>
<% available_disk_names_and_sizes(); %>
<% get_usb_ports_info(); %>
<% get_ext_ports_info(); %>

var all_disks = foreign_disks().concat(blank_disks());
var all_disk_interface = foreign_disk_interface_names().concat(blank_disk_interface_names());

var flag = '<% get_parameter("flag"); %>';
var disk_number = foreign_disks().length + blank_disks().length;

var ccount = <% get_static_ccount(); %> ;

function initial() {
    show_banner(0);
    show_menu('if-m1-netmap', '', 0);
    show_footer();
    show_usb_ports();
    show_ata_pool();
    show_mmc_card();
    show_middle_status();
    show_client_status(ccount);
    set_default_choice();

    if (!support_2g_radio() && !support_5g_radio()) { // Remove radio row
        $("row_radio").style.display = "none";
    }

    if (sw_mode == '3')
        $("linkInternet").href = "/device-map/intranet.asp";

    update_internet_status();
}

function detect_update_info() {
    var str = $("internetStatus").innerHTML;
    if (str == "<#QKSet_detect_freshbtn#>...")
        refreshpage();
}

function show_default_icon() {
    var icon_name = "iconClient";
    $("statusframe").src = "/device-map/clients.asp";
    clickEvent($(icon_name));
}

function set_default_choice() {
    var icon_name;
    if (flag && flag.length > 0 && sw_mode != "3") {
        if (flag == "Internet")
            $("statusframe").src = "/device-map/internet.asp";
        else if (flag == "Client")
            $("statusframe").src = "/device-map/clients.asp";
        else if (flag == "Router2g")
            $("statusframe").src = "/device-map/router2g.asp";
        else if (flag == "Router5g")
            $("statusframe").src = "/device-map/router.asp";
        else {
            show_default_icon();
            return;
        }
        if (flag == "Router2g" || flag == "Router5g")
            icon_name = "iconRouter";
        else
            icon_name = "icon" + flag;
        clickEvent($(icon_name));
    } else
        show_default_icon();
}

function showMapWANStatus(flag) {
    $j("#internetStatus").removeClass("badge-success badge-warning badge-important");

    if (flag == 1) {
        $j("#internetStatus").addClass("badge-success").html('<i class="if if-center if-status-online"></i>');
    } else if (flag == 2) {
        $j("#internetStatus").addClass("badge-warning").html('<i class="if if-center if-status-connecting"></i>');
    } else {
        $j("#internetStatus").addClass("badge-important").html('<i class="if if-center if-status-offline"></i>');
    }
}

function show_middle_status() {
    var auth_mode = document.form.rt_auth_mode.value,
        wpa_mode = document.form.rt_wpa_mode.value,
        wl_wep_x = parseInt(document.form.rt_wep_x.value),
        security_mode;

    if (auth_mode == "open")
        security_mode = "Open System";
    else if (auth_mode == "shared")
        security_mode = "Shared Key";
    else if (auth_mode == "psk") {
        if (wpa_mode == "1")
            security_mode = "WPA-Personal";
        else if (wpa_mode == "2")
            security_mode = "WPA2-Personal";
        else if (wpa_mode == "0")
            security_mode = "WPA-Auto-Personal";
        else
            alert("System error for showing auth_mode!");
    } else if (auth_mode == "wpa") {
        if (wpa_mode == "3")
            security_mode = "WPA-Enterprise";
        else if (wpa_mode == "4")
            security_mode = "WPA-Auto-Enterprise";
        else
            alert("System error for showing auth_mode!");
    } else if (auth_mode == "wpa2")
        security_mode = "WPA2-Enterprise";
    else if (auth_mode == "radius")
        security_mode = "Radius with 802.1x";

    if (auth_mode == "open" && wl_wep_x == 0) {
        $j("#wl_securitylevel_span").addClass("badge-important").html('<i class="if if-center if-status-unlock"></i>');
    } else {
        $j("#wl_securitylevel_span").addClass("badge-success").html('<i class="if if-center if-status-lock"></i>');
    }
}

function show_client_status(clients_count) {
    $j("#clientNumber").addClass("badge-success");
    $j("#clientNumber").html('<span class="if if-center">' + clients_count + '</span>');
}

function show_usb_ports() {
    var i,
        dev_type_usb,
        usb_ports_num = get_usb_ports_num();

    if (usb_ports_num < 1) {
        $("row_usb_port1").style.display = "none";
        return;
    }

    dev_type_usb = get_device_type_usb(1);
    switch (dev_type_usb) {
        case "hub":
            hub_html(0);
            break;
        case "storage":
            for (i = 0; i < all_disks.length; ++i)
                if (foreign_disk_interface_names()[i] == "1") {
                    disk_html(0, i);
                    break;
                }
            break;
        case "printer":
            for (i = 0; i < printer_ports().length; ++i)
                if (printer_ports()[i] == "1") {
                    printer_html(0, i);
                    break;
                }
            break;
        case "modem_tty":
        case "modem_eth":
            for (i = 0; i < modem_ports().length; ++i)
                if (modem_ports()[i] == "1") {
                    modem_html(0, i);
                    break;
                }
            break;
        default:
            no_usb_device_html(0);
    }

    if (usb_ports_num < 2)
        return;

    $("row_usb_port2").style.display = "";

    dev_type_usb = get_device_type_usb(2);
    switch (dev_type_usb) {
        case "hub":
            hub_html(1);
            break;
        case "storage":
            for (i = 0; i < all_disks.length; ++i)
                if (foreign_disk_interface_names()[i] == "2") {
                    disk_html(1, i);
                    break;
                }
            break;
        case "printer":
            for (i = 0; i < printer_ports().length; ++i)
                if (printer_ports()[i] == "2") {
                    printer_html(1, i);
                    break;
                }
            break;
        case "modem_tty":
        case "modem_eth":
            for (i = 0; i < modem_ports().length; ++i)
                if (modem_ports()[i] == "2") {
                    modem_html(1, i);
                    break;
                }
            break;
        default:
            no_usb_device_html(1);
    }
}

function show_ata_pool() {
    var i,
        dev_found = 0;

    if (typeof(get_ata_support) !== 'function')
        return;

    if (!get_ata_support())
        return;

    $("row_ata_pool").style.display = "";

    for (i = 0; i < all_disks.length; ++i) {
        if (foreign_disk_interface_names()[i] == "1000") {
            dev_found = 1;
            ata_html(i);
            break;
        }
    }

    if (!dev_found)
        no_device_html("sataIcon");
}

function show_mmc_card() {
    var i,
        dev_found = 0;

    if (typeof(get_mmc_support) !== 'function')
        return;

    if (!get_mmc_support())
        return;

    $("row_mmc_slot").style.display = "";

    for (i = 0; i < all_disks.length; ++i) {
        if (foreign_disk_interface_names()[i] == "2000") {
            dev_found = 1;
            mmc_html(i);
            break;
        }
    }

    if (!dev_found)
        no_device_html("cardIcon");
}

function dec_html(all_disk_order) {
    var dec_html_code = '',
        TotalSize,
        all_accessable_size,
        percentbar = 0,
        alertPercentbar = 'progress-info',
        mount_num = getDiskMountedNum(all_disk_order);

    if (mount_num > 0) {
        if (all_disk_order < foreign_disks().length)
            TotalSize = simpleNum(foreign_disk_total_size()[all_disk_order]);
        else
            TotalSize = simpleNum(blank_disk_total_size()[all_disk_order - foreign_disks().length]);

        all_accessable_size = simpleNum2(computeallpools(all_disk_order, "size") - computeallpools(all_disk_order, "size_in_use"));

        percentbar = simpleNum2((all_accessable_size) / TotalSize * 100);
        percentbar = Math.round(100 - percentbar);
        if (percentbar >= 66 && percentbar < 85)
            alertPercentbar = 'progress-warning';
        else if (percentbar >= 85)
            alertPercentbar = 'progress-danger';
        dec_html_code += '<div id="diskquota">\n';
        dec_html_code += '<div style="margin-bottom: 10px;" class="progress ' + alertPercentbar + '"><div class="bar" style="width:' + percentbar + '%">' + (percentbar > 10 ? (percentbar + '%') : '') + '</div></div>';
        dec_html_code += '</div>\n';
        dec_html_code += '<strong><#Totaldisk#></strong>: ' + TotalSize + ' GB<br>\n';
        dec_html_code += '<span class="style1"><strong><#Availdisk#></strong>: ' + (all_accessable_size) + ' GB</span>\n';
    } else
        dec_html_code += '<span class="style1"><strong><#DISK_UNMOUNTED#></strong></span>\n';

    return dec_html_code;
}

function dec_share_icon(device_dec) {
    device_dec.addClass("badge-success");
    device_dec.html('<i class="if if-center if-btn-share"></i>');
}

function disk_html(device_order, all_disk_order) {
    var device_icon = $j("#deviceIcon_" + device_order),
        device_dec = $j("#deviceDec_" + device_order),
        icon_html_code = '',
        dec_html_code = '',
        disk_model_name = '';

    if (all_disk_order < foreign_disks().length)
        disk_model_name = foreign_disk_model_info()[all_disk_order];
    else
        disk_model_name = blank_disks()[all_disk_order - foreign_disks().length];

    dec_html_code = dec_html(all_disk_order);

    icon_html_code += '<a href="device-map/disk.asp" target="statusframe" style="outline:0;">\n';
    icon_html_code += '    <i id="iconUSBdisk' + all_disk_order + '" class="if if-shortcut-harddisk" rel="rollover_disk" data-original-title="' + disk_model_name + '" data-content="' + (dec_html_code.replace(new RegExp('"', 'g'), "'")) + '" onclick="setSelectedDiskOrder(this.id);clickEvent(this);"></i>\n';
    icon_html_code += '</a>\n';

    //device_icon.innerHTML = icon_html_code;
    device_icon.after(icon_html_code);
    device_icon.remove();
    dec_share_icon(device_dec);
}

function printer_html(device_seat, printer_order) {
    var device_icon = $j("#deviceIcon_" + device_seat),
        device_dec = $j("#deviceDec_" + device_seat),
        icon_html_code = '';

    icon_html_code += '<a href="device-map/printer.asp" target="statusframe" style="outline:0;">\n';
    icon_html_code += '    <div id="iconPrinter' + printer_order + '" class="if if-shortcut-printer" onclick="clickEvent(this);"></div>\n';
    icon_html_code += '</a>\n';

    //device_icon.innerHTML = icon_html_code;
    device_icon.after(icon_html_code);
    device_icon.remove();
    dec_share_icon(device_dec);
}

function modem_html(device_seat, modem_order) {
    var device_icon = $j("#deviceIcon_" + device_seat),
        device_dec = $j("#deviceDec_" + device_seat),
        icon_html_code = '';

    icon_html_code += '<a href="device-map/modem.asp" target="statusframe" style="outline:0;">\n';
    icon_html_code += '    <div id="iconModem' + modem_order + '" class="if if-shortcut-modem" onclick="clickEvent(this);"></div>\n';
    icon_html_code += '</a>\n';

    //device_icon.innerHTML = icon_html_code;
    device_icon.after(icon_html_code);
    device_icon.remove();
    dec_share_icon(device_dec);
}

function hub_html(device_seat) {
    var device_icon = $j("#deviceIcon_" + device_seat),
        device_dec = $j("#deviceDec_" + device_seat),
        icon_html_code = '';

    icon_html_code += '<a href="device-map/hub.asp" target="statusframe" style="outline:0;">\n';
    icon_html_code += '    <i id="iconHub' + device_seat + '" class="if if-shortcut-hub" onclick="clickEvent(this);"></i>\n';
    icon_html_code += '</a>\n';

    //device_icon.innerHTML = icon_html_code;
    device_icon.after(icon_html_code);
    device_icon.remove();
    dec_share_icon(device_dec);
}

function ata_html() {
    var device_icon = $j("#sataIcon"),
        device_dec = $j("#sataDec"),
        icon_html_code = '';

    icon_html_code += '<a href="device-map/sata.asp" target="statusframe" style="outline:0;">\n';
    icon_html_code += '    <i id="iconSATA" class="if if-shortcut-satadisk" onclick="clickEvent(this);"></i>\n';
    icon_html_code += '</a>\n';

    //device_icon.innerHTML = icon_html_code;
    device_icon.after(icon_html_code);
    device_icon.remove();
    dec_share_icon(device_dec);
}

function mmc_html(all_disk_order) {
    var device_icon = $j("#cardIcon"),
        device_dec = $j("#cardDec"),
        icon_html_code = '',
        dec_html_code = '',
        disk_model_name = '';

    if (all_disk_order < foreign_disks().length)
        disk_model_name = foreign_disk_model_info()[all_disk_order];
    else
        disk_model_name = blank_disks()[all_disk_order - foreign_disks().length];

    dec_html_code = dec_html(all_disk_order);

    icon_html_code += '<a href="device-map/disk.asp" target="statusframe" style="outline:0;">\n';
    icon_html_code += '    <i id="iconCard' + all_disk_order + '" class="if if-shortcut-tfcard" rel="rollover_disk" data-original-title="' + disk_model_name + '" data-content="' + (dec_html_code.replace(new RegExp('"', 'g'), "'")) + '" onclick="setSelectedDiskOrder(this.id);clickEvent(this);"></i>\n';
    icon_html_code += '</a>\n';

    //device_icon.innerHTML = icon_html_code;
    device_icon.after(icon_html_code);
    device_icon.remove();
    dec_share_icon(device_dec);
}

function no_device_html(device_name) {
    var device_icon = $(device_name);
    if (device_icon) device_icon.innerHTML = '<div class="iconNo"></div>';
}

function no_usb_device_html(device_seat) {
    //no_device_html("deviceIcon_" + device_seat);
}

var clicked_device_order;

function get_clicked_device_order() {
    return clicked_device_order;
}

function clickEvent(obj) {
    if (obj == null) return;
    //var icon;
    var ContainerWidth;
    var Containerpadding;
    var stitle;
    var seat;

    clicked_device_order = -1;

    if (obj.id == "iflock") {
        obj = $("big-icons-router-active");
    }

    if (obj.id.indexOf("Internet") > 0) {
        ContainerWidth = "300px";
        Containerpadding = "5px";
        if (sw_mode == '3') {
            stitle = "<#statusTitle_Intranet#>";
            $("statusframe").src = "/device-map/intranet.asp";
        } else {
            stitle = "<#statusTitle_Internet#>";
            $("statusframe").src = "/device-map/internet.asp";
        }
    } else if (obj.id.indexOf("Router") > 0) {
        ContainerWidth = "320px";
        Containerpadding = "4px";
        stitle = "<#statusTitle_System#>";
    } else if (obj.id.indexOf("Client") > 0) {
        ContainerWidth = "396px";
        Containerpadding = "0px";
        stitle = "<#statusTitle_Client#>";
    } else if (obj.id.indexOf("USBdisk") > 0) {
        ContainerWidth = "556px";
        Containerpadding = "0px";
        stitle = "<#statusTitle_USB_Disk#>";
        $("statusframe").src = "/device-map/disk.asp";
    } else if (obj.id.indexOf("Printer") > 0) {
        seat = obj.id.indexOf("Printer") + 7;
        clicked_device_order = parseInt(obj.id.substring(seat, seat + 1));
        ContainerWidth = "666px";
        Containerpadding = "0px";
        stitle = "<#statusTitle_Printer#>";
        $("statusframe").src = "/device-map/printer.asp";
    } else if (obj.id.indexOf("Modem") > 0) {
        seat = obj.id.indexOf("Modem") + 5;
        clicked_device_order = parseInt(obj.id.substring(seat, seat + 1));
        ContainerWidth = "777px";
        Containerpadding = "0px";
        stitle = "<#statusTitle_Modem#>";
        $("statusframe").src = "/device-map/modem.asp";
    } else if (obj.id.indexOf("Hub") > 0) {
        seat = obj.id.indexOf("Hub") + 3;
        clicked_device_order = parseInt(obj.id.substring(seat, seat + 1));
        ContainerWidth = "892px";
        Containerpadding = "0px";
        stitle = "<#statusTitle_Hub#>";
        $("statusframe").src = "/device-map/hub.asp";
    } else if (obj.id.indexOf("SATA") > 0) {
        ContainerWidth = "892px";
        Containerpadding = "0px";
        stitle = "<#statusTitle_SATA#>";
        $("statusframe").src = "/device-map/sata.asp";
    } else if (obj.id.indexOf("Card") > 0) {
        ContainerWidth = "892px";
        Containerpadding = "0px";
        stitle = "<#statusTitle_Card#>";
        $("statusframe").src = "/device-map/disk.asp";
    } else if (obj.id.indexOf("No") > 0) {
        //icon = "iconNo";
    }

    $('statusContainer').style.width = ContainerWidth;
    $('statusContainer').style.paddingRight = Containerpadding;

    $j("#tblshortcut").find('[class*=" if-shortcut-"]').addClass("inactive");
    $j(obj).removeClass('inactive');

    // show arrow right icon
    $j(".arrow-right").hide();
    $j(obj).parents('tr').find(".arrow-right").show();

    $('helpname').innerHTML = stitle;
}

$j(document).ready(function() {
    $j('div[rel=rollover_disk]').popover();
});
		</script>
		<style>
			.arrow-right { position: absolute; margin-top: -29px; margin-left: 63px;
			display: none; } .badge { padding: 2px; /*padding-bottom: 3px;*/ } .table-big
			td { padding-top: 16px; padding-bottom: 16px; } .progress { background-image:
			-moz-linear-gradient(top, #f3f3f3, #dddddd); background-image: -ms-linear-gradient(top,
			#f3f3f3, #dddddd); background-image: -webkit-gradient(linear, 0 0, 0 100%,
			from(#f3f3f3), to(#dddddd)); background-image: -webkit-linear-gradient(top,
			#f3f3f3, #dddddd); background-image: -o-linear-gradient(top, #f3f3f3, #dddddd);
			background-image: linear-gradient(top, #f3f3f3, #dddddd); filter: progid:dximagetransform.microsoft.gradient(startColorstr='#f3f3f3',
			endColorstr='#dddddd', GradientType=0); }
		</style>
	</head>
	<body onunload="return unload_body();">
		<div id="Loading" class="popup_bg">
		</div>
		<div class="wrapper">
			<noscript>
				<div class="popup_bg" style="visibility:visible; z-index:999;">
					<div style="margin:200px auto; width:300px; background-color:#006699; color:#FFFFFF; line-height:150%; border:3px solid #FFF; padding:5px;">
						<#not_support_script#>
							</p>
					</div>
				</div>
			</noscript>
			<div class="container-fluid" style="padding-right: 0px">
				<div class="row-fluid">
					<div class="span3">
						<center>
							<div id="logo">
							</div>
						</center>
					</div>
					<div class="span9">
						<div id="TopBanner">
						</div>
					</div>
				</div>
			</div>
			<iframe name="hidden_frame" id="hidden_frame" width="0" height="0" frameborder="0"
			scrolling="no" style="position: absolute;">
			</iframe>
			<form name="form">
				<input type="hidden" name="current_page" value="index.asp">
				<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get_x("
				", "preferred_lang "); %>">
				<input type="hidden" name="wl_auth_mode" value="<% nvram_get_x(" ",  "wl_auth_mode
				"); %>">
				<input type="hidden" name="wl_wpa_mode" value="<% nvram_get_x(" ",  "wl_wpa_mode
				"); %>">
				<input type="hidden" name="wl_wep_x" value="<% nvram_get_x(" ",  "wl_wep_x
				"); %>">
				<input type="hidden" name="rt_auth_mode" value="<% nvram_get_x(" ",  "rt_auth_mode
				"); %>">
				<input type="hidden" name="rt_wpa_mode" value="<% nvram_get_x(" ",  "rt_wpa_mode
				"); %>">
				<input type="hidden" name="rt_wep_x" value="<% nvram_get_x(" ",  "rt_wep_x
				"); %>">
			</form>
			<form name="rt_form">
				<input type="hidden" name="rt_ssid" value="">
				<input type="hidden" name="rt_wpa_mode" value="">
				<input type="hidden" name="rt_key1" value="">
				<input type="hidden" name="rt_key2" value="">
				<input type="hidden" name="rt_key3" value="">
				<input type="hidden" name="rt_key4" value="">
				<input type="hidden" name="rt_ssid2" value="">
				<input type="hidden" name="rt_key_type" value="">
				<input type="hidden" name="rt_auth_mode" value="">
				<input type="hidden" name="rt_wep_x" value="">
				<input type="hidden" name="rt_key" value="">
				<input type="hidden" name="rt_asuskey1" value="">
				<input type="hidden" name="rt_crypto" value="">
				<input type="hidden" name="rt_wpa_psk" value="">
			</form>
			<form name="wl_form">
				<input type="hidden" name="wl_ssid" value="">
				<input type="hidden" name="wl_wpa_mode" value="">
				<input type="hidden" name="wl_key1" value="">
				<input type="hidden" name="wl_key2" value="">
				<input type="hidden" name="wl_key3" value="">
				<input type="hidden" name="wl_key4" value="">
				<input type="hidden" name="wl_gmode" value="">
				<input type="hidden" name="wl_ssid2" value="">
				<input type="hidden" name="wl_key_type" value="">
				<input type="hidden" name="wl_auth_mode" value="">
				<input type="hidden" name="wl_wep_x" value="">
				<input type="hidden" name="wl_key" value="">
				<input type="hidden" name="wl_asuskey1" value="">
				<input type="hidden" name="wl_crypto" value="">
				<input type="hidden" name="wl_wpa_psk" value="">
			</form>
			<div class="container-fluid">
				<div class="row-fluid">
					<div class="span3">
						<!--Sidebar content-->
						<!--=====Beginning of Main Menu=====-->
						<div class="well sidebar-nav side_nav" style="padding: 0px;">
							<ul id="mainMenu" class="clearfix">
							</ul>
							<ul class="clearfix">
								<li>
									<div id="subMenu" class="accordion">
									</div>
								</li>
							</ul>
						</div>
					</div>
					<div class="span9">
						<!--Body content-->
						<div class="row-fluid">
							<div class="span2">
								<div class="well" style="height: 570px; padding-left: 18px;">
									<div id="tabMenu">
									</div>
									<table id="tblshortcut" class="table table-big" style="margin-top: 12px;">
										<tbody>
											<tr id="row_internet">
												<td width="30%">
													<a id="linkInternet" href="/device-map/internet.asp" target="statusframe"
													style="outline:0;">
														<i id="iconInternet" class="if if-shortcut-internet" onclick="clickEvent(this);">
														</i>
													</a>
													<div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;">
													</div>
													<div class="badge-container">
														<div id="internetStatus" class="badge badge-circle">
														</div>
													</div>
													<div class="arrow-right" id="arrow-internet">
														<i class="if if-color-smoke if-arrow-right" style="font-size: 2.3em;">
														</i>
													</div>
												</td>
											</tr>
											<tr id="row_radio">
												<td width="30%">
													<a href="device-map/router2g.asp" target="statusframe" style="outline:0;">
														<i id="iconRouter" class="if if-shortcut-wifisetting" onclick="clickEvent(this);">
														</i>
													</a>
													<div class="badge-container">
														<div id="wl_securitylevel_span" class="badge badge-circle">
														</div>
													</div>
													<div class="arrow-right" id="arrow-router">
														<i class="if if-color-smoke if-arrow-right" style="font-size: 2.3em;">
														</i>
													</div>
												</td>
											</tr>
											<tr>
												<td>
													<a id="clientStatusLink" href="device-map/clients.asp" target="statusframe"
													style="outline:0;">
														<i id="iconClient" class="if if-shortcut-deviceslist" onclick="clickEvent(this);">
														</i>
													</a>
													<div class="badge-container">
														<div id="clientNumber" class="badge badge-circle">
															&nbsp;
														</div>
													</div>
													<div class="arrow-right" id="arrow-clients">
														<i class="if if-color-smoke if-arrow-right" style="font-size: 2.3em;">
														</i>
													</div>
												</td>
											</tr>
											<tr id="row_usb_port1">
												<td width="30%">
													<i id="deviceIcon_0" class="if if-shortcut-usbdevice">
													</i>
													<div class="badge-container">
														<div id="deviceDec_0" class="badge badge-circle">
														</div>
													</div>
													<div class="arrow-right" id="arrow-usb1">
														<i class="if if-color-smoke if-arrow-right" style="font-size: 2.3em;">
														</i>
													</div>
												</td>
											</tr>
											<tr id="row_usb_port2" style="display:none">
												<td width="30%">
													<i id="deviceIcon_1" class="if if-shortcut-usbdevice">
													</i>
													<div class="badge-container">
														<div id="deviceDec_1" class="badge badge-circle">
														</div>
													</div>
													<div class="arrow-right" id="arrow-usb2">
														<i class="if if-color-smoke if-arrow-right" style="font-size: 2.3em;">
														</i>
													</div>
												</td>
											</tr>
											<tr id="row_ata_pool" style="display:none">
												<td width="30%">
													<i id="sataIcon" class="if if-shortcut-harddisk">
													</i>
													<div class="badge-container">
														<div id="sataDec" class="badge badge-circle">
														</div>
													</div>
													<div class="arrow-right" id="arrow-ata">
														<i class="if if-color-smoke if-arrow-right" style="font-size: 2.3em;">
														</i>
													</div>
												</td>
											</tr>
											<tr id="row_mmc_slot" style="display:none">
												<td width="30%">
													<i id="cardIcon" class="if if-shortcut-tfcard">
													</i>
													<div class="badge-container">
														<div id="cardDec" class="badge badge-circle">
														</div>
													</div>
													<div class="arrow-right" id="arrow-mmc">
														<i class="if if-color-smoke if-arrow-right" style="font-size: 2.3em;">
														</i>
													</div>
												</td>
											</tr>
										</tbody>
									</table>
									<div class="row-fluid">
										<div class="span12">
											<div id="statusContainer" width="0" height="0" align="left" valign="top">
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="span10">
								<div class="box well grad_colour_dark_blue">
									<div id="statusIcon" style="display: none">
									</div>
									<h2 id="helpname" class="box_head round_top">
									</h2>
									<div class="round_bottom">
										<iframe id="statusframe" name="statusframe" src="/device-map/clients.asp"
										frameborder="0" width="100%" height="571">
										</iframe>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div id="footer">
			</div>
			<script>
				if (flag == "Internet" || flag == "Client")
    $("statusframe").src = "";
initial();
			</script>
		</div>
	</body>

</html>
