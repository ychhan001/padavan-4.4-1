<!DOCTYPE html>
<html>
	<head>
		<title>
		</title>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta http-equiv="Pragma" content="no-cache">
		<meta http-equiv="Expires" content="-1">
		<link rel="shortcut icon" href="images/favicon.ico">
		<link rel="icon" href="images/favicon.png">
		<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
		<link rel="stylesheet" type="text/css" href="/iconmoon/css/iconmoon.css">
		<link rel="stylesheet" type="text/css" href="/bootstrap/css/simple.switch.three.css">
		<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
		<script type="text/javascript" src="/jquery.js">
		</script>
		<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js">
		</script>
		<script type="text/javascript" src="/bootstrap/js/simple.switch.min.js">
		</script>
		<script type="text/javascript" src="/state.js">
		</script>
		<script type="text/javascript" src="/general.js">
		</script>
		<script type="text/javascript" src="/itoggle.js">
		</script>
		<script type="text/javascript" src="/popup.js">
		</script>
		<script>
			var restart_time = 1;

function restart_needed_time(second) {
    restart_time = second;
}

function Callback() {
    setTimeout("document.redirectForm.submit();", 0);
}
		</script>
	</head>
	<body onLoad="Callback();">
		<% shadowsocks_action(); %>
			<form method="post" name="redirectForm" action="/Shadowsocks.asp" target="_self">
			</form>
	</body>

</html>
