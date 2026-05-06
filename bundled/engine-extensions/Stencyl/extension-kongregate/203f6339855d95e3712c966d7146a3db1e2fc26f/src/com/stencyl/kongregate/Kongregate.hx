#if flash
package com.stencyl.kongregate;

import com.stencyl.Extension;
import openfl.Lib;

class Kongregate extends Extension
{
	private static var instance:Kongregate;
	private static var kongregate:Dynamic;
	private static var loader:openfl.display.Loader;
	
	public function new()
	{
		super();
		instance = this;
	}

	public override function reloadGame():Void
	{
		kongregate = null;
		loader = null;
	}

	public static function initAPI()
	{
		instance.loadKongregate();
	}

	private function loadKongregate()
	{
		kongregate = null;
		var parameters = openfl.Lib.current.loaderInfo.parameters;
		var url:String = parameters.api_path;
		
		if(url == null)
		{
			url = "http://www.kongregate.com/flash/API_AS3_Local.swf";
		}
			
		var request = new openfl.net.URLRequest(url);
		loader = new openfl.display.Loader();
		loader.contentLoaderInfo.addEventListener(openfl.events.Event.COMPLETE, onLoadComplete);
		loader.load(request);
		
		openfl.Lib.current.addChild(loader);
	}

	function onLoadComplete(e:flash.events.Event) 
	{
		try 
		{
			Kongregate.kongregate = loader.content;
			Kongregate.kongregate.services.connect();
			loader = null;
		}
		
		catch(msg:Dynamic) 
		{
			Kongregate.kongregate = null; 
		}
	} 

	/*public static function submitScore(score:Float, mode:String) 
	{
		if(Kongregate.kongregate != null)
		{
			Kongregate.kongregate.scores.submit(score, mode); 
		}
		
		else
		{
			error();
		}
	}*/
	
	public static function submitStat(name:String, stat:Float) 
	{
		if(Kongregate.kongregate != null) 
		{
			Kongregate.kongregate.stats.submit(name, Std.int(stat));
		}
		
		else
		{
			error();
		}
	}
	
	public static function isGuest():Bool
	{
		if(Kongregate.kongregate != null)
		{
			return Kongregate.kongregate.services.isGuest(); 
		}
		
		else
		{
			error();
		}
	
		return false;
	}
	
	public static function getUsername():String
	{
		if(Kongregate.kongregate != null)
		{
			return Kongregate.kongregate.services.getUsername(); 
		}
		
		else
		{
			error();
		}
	
		return "Guest";
	}
	
	public static function getUserID():Int
	{
		if(Kongregate.kongregate != null)
		{
			return Kongregate.kongregate.services.getUserId(); 
		}
		
		else
		{
			error();
		}
	
		return 0;
	}
	
	public static function error()
	{
		trace("Kongregate API is not ready yet. Call initAPI() first.");
	}
} 
#end
