var minJavaVer		= "1.5";
var minFlashVer		= "10.0.12";
var promptForJava	= false;
var jsReady 		= false;

var flashBgColor	= "#ffffff";
var preloaderUrl 	= "";	
var appUrl 			= "";
var jarUrl 			= "java/MidiApplet.jar";

var flashDivId 		= "flash";
var javaDivId 		= "java";
var javaMsgDivId 	= "javamessage";
var serverPath 		= "";

var javaMsgDiv;
var flashDiv;
var appletObject;
var flashObject;

var javaVersion;		
var flashVersion;	

function noFlash(){var s = "<div>For this site you need Flash plugin version " + minFlashVer + " or higher:" +
					"<ul><li>click <a href='http://www.adobe.com/go/getflashplayer' target='_blank'>here</a> to install or update</li></ul></div>" +
					"<div><a href='http://www.adobe.com/go/getflashplayer' target='_blank'><img src='img/flash_icon.jpg' width='75' height='75' border='0' /></a></div>";
					return s;}

function noJava(){var s	= "<div>For this site you need Java plugin version " + minJavaVer + " or higher:" +
					"<ul><li>click <a href='javascript:loadJava()'>here</a> if your Java Plugin version is " + minJavaVer + " or higher</li>" +
					"<li>click <a href='http://java.com/en/download/index.jsp' target='_blank'>here</a> to install the Java plugin.</li>" +
					//"<li>click <a href='javascript:loadApp()'>here</a> to continue without java (midi data will not available!)</li>" +
					"</ul></div>" + 
					"<div><a href='http://java.com/en/download/index.jsp' target='_blank'><img src='img/java_icon.jpg' width='75' height='65' border='0' /></a></div>";
					return s;}


function trace(args)
{
	alert(args);
}

function start()
{
	flashDiv 					= document.getElementById(flashDivId);

	if(navigator.platform.indexOf("Mac") != -1 && navigator.appVersion.indexOf("Safari") == -1)
	{
		//alert("Sorry, only Safari is supported on OSX");
		flashDiv.innerHTML		= "<div class='error2'>Sorry, only Safari is supported on OSX</div>";
		return;
	}
	else if(navigator.platform.indexOf("Linux") != -1 && navigator.appVersion.indexOf("Konqueror") != -1)
	{
		//alert("Sorry, Konqueror is not supported.");
		flashDiv.innerHTML		= "<div class='error2'>Sorry, Konqueror is not supported.</div>";
		return;
	}

	checkFlash();
}

function checkFlash()
{
	if(swfobject.hasFlashPlayerVersion(minFlashVer))
	{
		var player   			= swfobject.getFlashPlayerVersion()
		flashVersion			= player.major + "." + player.minor + "." + player.release;
		checkJava();
	}
	else
	{
		flashDiv.innerHTML 	= noFlash();
		flashDiv.innerHTML += noJava();
	}
}

function checkJava()
{
	if(navigator.userAgent.indexOf('MSIE') != -1) 
	{
		minJavaVer = "1.6";
	}	
	//trace("browser:" + navigator.userAgent + "\njar:" + jarUrl + " \napplet:" + appletCode);

	if(promptForJava)
	{
		flashDiv.innerHTML = noJava();
	}
	else
	{
		loadJava();
	}
}
	
function loadJava()
{
	javaMsgDiv  			= document.getElementById(javaMsgDivId);
	var content   			= "<p style='text-align:left;'>Initializing Java....";
	content 	       	   += "<br>Please be patient, this can take up to 30 seconds.";
	content		       	   += "<br>Check your Java plugin settings if you see this message longer that a minute.";
	//content		       	   += "<br>Additionally, you might want to read <a href='http://www.abumarkub.net/abublog/?p=97' target='blank'>this</a>.";
	content		       	   += "</p>";
	javaMsgDiv.innerHTML 	= content;
	 
	javaDiv 				= document.getElementById(javaDivId);
	content 	 			= "<div id='java'><applet name='midiApplet' code='net.abumarkub.midi.applet.MidiApplet'";
	content		           += "archive='" + jarUrl + "' width='1' height='1' MAYSCRIPT>";
	content		           += "</applet></div>";
    javaDiv.innerHTML 		= content;
}

function loadApp()
{	
	javaMsgDiv.innerHTML = "";

	if(preloaderUrl != "")
	{	
		swfobject.embedSWF(preloaderUrl, flashDivId, flashWidth, flashHeight, minFlashVer, 
				'swf/expressinstall.swf', {url:flashUrl}, 
				{bgcolor: flashBgColor, menu: 'false', allowFullscreen:flashAllowFullscreen, allowScriptAccess: 'always', wmode:flashWmode}, 
				{id: 'flashApp'});
		return;
	}

	//alert(flashUrl + ":" + flashDivId + ":" + flashWidth + ":" + flashHeight);

	swfobject.embedSWF(flashUrl, flashDivId, flashWidth, flashHeight, minFlashVer, 
			'swf/expressinstall.swf', {conf:serverPath + '/xml/config.xml',css:serverPath + '/css/app.css'}, 
			{bgcolor: flashBgColor, menu: 'false', allowFullscreen:flashAllowFullscreen, allowScriptAccess: 'always', wmode:flashWmode}, 
			{id: 'flashApp'});
	
}

function talkToFlash(method,value) 
{
	//alert(method + ":" + appletObject + ":" + flashObject);
	if(method == "appletInitialized")
    { 	
    	appletObject	= getObject("midiApplet");
    	jsReady 		= true;
    	loadApp();
    	return;
    } 
    appletObject	= getObject("midiApplet");
    //javaMsgDiv.innerHTML = method + "(" + value + ")";
    flashObject.executeASMethod(method,value);
}

function talkToJava(method,value) 
{
	if(method == "getMidiConfiguration")
	{
		flashObject = getObject("flashApp");
	}
	//alert(method + "(" + value + ")" + flashObject);
	appletObject.executeJavaMethod(method,value);
}

function javaScriptReady()
{
	//alert("jsReady called")
	return jsReady;
}

function getObject(objectName) 
{
    if (navigator.appName.indexOf("Microsoft") != -1) 
    {
        return window[objectName];
    }
    else 
    {
        return document[objectName];
    }
}

