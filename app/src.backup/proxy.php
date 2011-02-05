<?php

	//$TEST = true;
	$PROD = true;
	$RESULT_LOG = false;
	
	$CURRENT = 'http://api.playme.com';
	
	if (isset($TEST)) $log = true;
	else $log = false;

	if (isset($PROD)) $baseurl = $CURRENT;
	else $baseurl = $LOCAL;
	
	if (isset($_GET['op'])) $op = $_GET['op'];
	if (!isset($op) || !is_numeric($op)) die("Error: no operation requested!");
	
	$cmds = Array();
	$cmds[2] = Array('url'=>'/track.getRandom' , 'mparams'=>array('apikey')  , 'oparams'=>array('format'));
  $cmds[3] = Array('url'=>'/genre.getTracks' , 'mparams'=>array('apikey' , 'genreCode')  , 'oparams'=>array('format' , 'step'));

	if (isset($cmds[$op])) $cmd = $cmds[$op];
	else die("Error: wrong operation requested!");

	if (isset($cmd['toreplace'])) {
		$p = $cmd['mparams'][$cmd['toreplace']];
		if (isset($_GET[$p]) && ($_GET[$p] != 'null') && !empty($_GET[$p])) {
			$cmd['url'] = str_replace('TOREPLACE',urlencode($_GET[$p]), $cmd['url']);
		} else {
			die("Error: No param " . $p . " given");
		}
	}

	$params = '';
  $getParams = '';
	
	
	// A fast hack here to support POST params from those calls having attribute 'postParams' set
	// This currently works for mandatory params only, not for optional ones
	if (isset($cmd['mparams'])) {
		if (isset($cmd['postParams']) && $cmd['postParams']) {
			$count = count($cmd['mparams']);
			for ($i = 0; $i < $count; $i++) {
				$p = $cmd['mparams'][$i];
				if (isset($_POST[$p]) && ($_POST[$p] != 'null') && !empty($_POST[$p])) {
					$params .= $p . '=' . urlencode($_POST[$p]) . '&';
          if ($p == "id") $getParams .= $p . '=' . urlencode($_POST[$p]) . '&';
				} else {
					die("Error: No POST param " . $p . " given");
				}
			}
		} else {
			$count = count($cmd['mparams']);
			for ($i = 0; $i < $count; $i++) {
				$p = $cmd['mparams'][$i];
				if (isset($_GET[$p]) && ($_GET[$p] != 'null') && !empty($_GET[$p])) {
					$params .= $p . '=' . urlencode($_GET[$p]) . '&';
          $getParams .= $p . '=' . urlencode($_GET[$p]) . '&';
				} else {
					die("Error: No GET param " . $p . " given");
				}
			}
		}
	}
	
	if (isset($cmd['oparams'])) {
		$count = count($cmd['oparams']);
		for ($i = 0; $i < $count; $i++) {
			$p = $cmd['oparams'][$i];
			if (isset($_GET[$p]) && ($_GET[$p] != 'null') && !empty($_GET[$p])) {
				$params .= $p . '=' . urlencode($_GET[$p]) . '&';
        $getParams .= $p . '=' . urlencode($_GET[$p]) . '&';
			}
		}
	}
	
	/* Weird cases */
	if ($op == 13) {
		print shorten();
		return;		
	} elseif ($op == 33) {
		$url = $cmd['url'];
		$user = $_GET['user'];
		if (!is_numeric($user)) $url .= 'screen_name/';
		$url .= urlencode($user) . ".json";
		$cmd['url'] = $url;
	} elseif (($op == 36) || ($op == 46)) {
		$baseurl = '';
	} elseif ($op == 44) {
	  
    $jsVersion = 1;
    if(file_exists("plugin/js/cascaad.plugin.js.sha1")) {
  		$fh = fopen('plugin/js/cascaad.plugin.js.sha1', 'r');
  		$jsVersion = trim(fgets($fh));
  		fclose($fh);
    }
    
    $cssVersion = 1;
    if(file_exists("plugin/css/cascaad.plugin.css.sha1")) {
  		$fh = fopen('plugin/css/cascaad.plugin.css.sha1', 'r');
  		$cssVersion = trim(fgets($fh));
  		fclose($fh);
    }
    
    $jsChromeVersion = 1;
    if(file_exists("plugin/js/cascaad.plugin.chrome.js.sha1")) {
      $fh = fopen('plugin/js/cascaad.plugin.chrome.js.sha1', 'r');
      $jsChromeVersion = trim(fgets($fh));
      fclose($fh);
    }
    
    $libVersion = 1;
    if(file_exists("plugin/js/jquery.splice.deps.min.js.sha1")) {
      $fh = fopen('plugin/js/jquery.splice.deps.min.js.sha1', 'r');
      $libVersion = trim(fgets($fh));
      fclose($fh);
    }
    
    if (isset($_GET['callback']) && ($_GET['callback'] != 'null') && !empty($_GET['callback']))
      print $_GET['callback'] . '({"js":"' . $jsVersion . '","css":"' . $cssVersion . '","lib":"' . $libVersion . '"})';
    else
      print '{"js":"' . $jsVersion . '","chrome":"' . $jsChromeVersion . '","css":"' . $cssVersion . '","lib":"' . $libVersion . '"}';
      
		return;
	}
	
	$len = strlen($params);
	if ($len > 0) $params = substr($params, 0,strlen($params)-1);
	
	$len = strlen($getParams);
  if ($len > 0) $getParams = '?' . substr($getParams, 0,strlen($getParams)-1);
	
	$curl = curl_init();
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	
	if (isset($cmd['method']) && !($cmd['method'] == 'GET')) {
 		curl_setopt($curl, CURLOPT_POSTFIELDS, $params);
 		if ($cmd['method'] != 'POST') {
			curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
			curl_setopt($curl, CURLOPT_HEADER, 0);
			curl_setopt($curl, CURLOPT_CUSTOMREQUEST, $cmd['method']);
 		} else {
 			curl_setopt($curl, CURLOPT_POST, 1);
 		}
	}
	
	$url = $baseurl . $cmd['url'];
	curl_setopt($curl, CURLOPT_URL, $url . $getParams);
  curl_setopt($curl, CURLOPT_USERAGENT, 'CascaadPHP');
	$result = curl_exec($curl);
	$info = curl_getinfo($curl);
	curl_close($curl);			
	
	if ($log) {
		$fp = fopen('cascaad.log', 'a');
		if (isset($cmd['method'])) fwrite($fp, 'Method: <' . $cmd['method'] . ">\n");
		fwrite($fp, 'Url: <' . $url . ">\n");
		fwrite($fp, 'Complete url: <' . $url . '?' . $getParams . ">\n");
		fwrite($fp, 'Params: <' . $params . ">\n");
		fwrite($fp, 'Response: <' . $info['http_code'] . ">\n\n");
		if ($RESULT_LOG) fwrite($fp, $result . "\nRequest DONE.\n\n");
	}

	header("Content-type: application/json");
	print $result;
	
	function shorten() {
		if (isset($_GET['url']) && ($_GET['url'] != 'null') && !empty($_GET['url'])) {
			$url = $_GET['url'];
		} else {
			die('No url given');
		}
		$long_url = urlencode($url);
		$short_url = file_get_contents('http://metamark.net/api/rest/simple?long_url='.$long_url);
		
		if (strstr($short_url,'ERROR')) {
			print '{"long_url":"' . $url . '","error":"' . trim($short_url) . '"}';
		} else {
			print '{"long_url":"' . $url . '","short_url":"' . trim($short_url) . '"}';
		}
	}

?>