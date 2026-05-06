package com.stencyl.gamecenter;

import cpp.Lib;

import com.stencyl.Extension;
import com.stencyl.event.Event;
import com.stencyl.models.Scene;

using com.stencyl.event.EventDispatcher;

@:buildXml('<include name="${haxelib:com.stencyl.gamecenter}/project/Build.xml"/>')
//This is just here to prevent the otherwise indirectly referenced native code from bring stripped at link time.
@:cppFileCode('extern "C" int gamecenter_register_prims();void com_stencyl_gamecenter_link(){gamecenter_register_prims();}')
class GameCenter extends Extension
{
	private static var instance:GameCenter;
	private static var initialized:Bool = false;
	
	//stencyl events
	public var gcEvent:Event<(GcEventData)->Void>;
	public var nativeEventQueue:Array<GcEventData> = [];
	
	public function new()
	{
		super();
		instance = this;
	}

	public static function get()
	{
		return instance;
	}

	//Native callbacks

	private static function notifyListeners(inEvent:Dynamic)
	{
		var type:String = Std.string(Reflect.field(inEvent, "type"));
		var data:String = Std.string(Reflect.field(inEvent, "data"));
		
		if(type == "auth-success")
		{
			trace("Game Center: Authenticated");
			instance.nativeEventQueue.push(GAME_CENTER_READY);
		}
		
		else if(type == "auth-failed")
		{
			trace("Game Center: Failed to Authenticate");
			instance.nativeEventQueue.push(GAME_CENTER_READY_FAIL);
		}
		
		else if(type == "score-success")
		{
			trace("Game Center: Submitted Score");
			instance.nativeEventQueue.push(GAME_CENTER_SCORE(data));
		}
		
		else if(type == "score-failed")
		{
			trace("Game Center: Failed to Submit Score");
			instance.nativeEventQueue.push(GAME_CENTER_SCORE_FAIL(data));
		}
		
		else if(type == "achieve-success")
		{
			trace("Game Center: Submitted Achievement");
			instance.nativeEventQueue.push(GAME_CENTER_ACHIEVEMENT(data));
		}
		
		else if(type == "achieve-failed")
		{
			trace("Game Center: Failed to Submit Achievement");
			instance.nativeEventQueue.push(GAME_CENTER_ACHIEVEMENT_FAIL(data));
		}
		
		else if(type == "achieve-reset-success")
		{
			trace("Game Center: Reset Achievements");
			instance.nativeEventQueue.push(GAME_CENTER_ACHIEVEMENT_RESET);
		}
		
		else if(type == "achieve-reset-failed")
		{
			trace("Game Center: Failed to Reset Achievements");
			instance.nativeEventQueue.push(GAME_CENTER_ACHIEVEMENT_RESET_FAIL);
		}
	}

	//Design Mode blocks

	public static function initializeGamecenter():Void 
	{
		if(!initialized)
		{
			set_event_handle(notifyListeners);
			gamecenter_initialize();
			initialized = true;
		}
	}

	public static function authenticate():Void 
	{
		gamecenter_authenticate();
	}
	
	public static function isAvailable():Bool 
	{
		return gamecenter_isavailable();
	}
	
	public static function isAuthenticated():Bool 
	{
		return gamecenter_isauthenticated();
	}
	
	public static function getPlayerName():String 
	{
		return gamecenter_playername();
	}
	
	public static function getPlayerID():String 
	{
		return gamecenter_playerid();
	}
	
	public static function showLeaderboard(categoryID:String):Void 
	{
		gamecenter_showleaderboard(categoryID);
	}
	
	public static function showAchievements():Void 
	{
		gamecenter_showachievements();
	}
	
	public static function reportScore(categoryID:String, score:Int):Void 
	{
		gamecenter_reportscore(categoryID, score);
	}
	
	public static function reportAchievement(achievementID:String, percent:Float):Void 
	{
		gamecenter_reportachievement(achievementID, percent);
	}
	
	public static function resetAchievements():Void 
	{
		gamecenter_resetachievements();
	}
	
	public static function showAchievementBanner(title:String, message:String):Void
	{
		gamecenter_showachievementbanner(title, message);
	}

	public static function getSubjectID(eventData:GcEventData):String
	{
		return switch(eventData)
		{
			case GAME_CENTER_SCORE(categoryID): categoryID;
			case GAME_CENTER_SCORE_FAIL(categoryID): categoryID;
			case GAME_CENTER_ACHIEVEMENT(achievementID): achievementID;
			case GAME_CENTER_ACHIEVEMENT_FAIL(achievementID): achievementID;
			case _: "";
		};
	}

	//Extension

	public override function loadScene(scene:Scene)
	{
		gcEvent = new Event<(GcEventData)->Void>();
	}
	
	public override function cleanupScene()
	{
		gcEvent = null;
	}

	public override function preSceneUpdate()
	{
		for(event in nativeEventQueue)
		{
			gcEvent.dispatch(event);
		}
		nativeEventQueue.splice(0, nativeEventQueue.length);
	}

	//Function loaders

	private static var set_event_handle = Lib.load("gamecenter", "gamecenter_set_event_handle", 1);
	private static var gamecenter_initialize = Lib.load("gamecenter", "gamecenter_initialize", 0);
	private static var gamecenter_authenticate = Lib.load("gamecenter", "gamecenter_authenticate", 0);
	private static var gamecenter_isavailable = Lib.load("gamecenter", "gamecenter_isavailable", 0);
	private static var gamecenter_isauthenticated = Lib.load("gamecenter", "gamecenter_isauthenticated", 0);
	
	private static var gamecenter_playername = Lib.load("gamecenter", "gamecenter_playername", 0);
	private static var gamecenter_playerid = Lib.load("gamecenter", "gamecenter_playerid", 0);
	
	private static var gamecenter_showleaderboard = Lib.load("gamecenter", "gamecenter_showleaderboard", 1);
	private static var gamecenter_showachievements = Lib.load("gamecenter", "gamecenter_showachievements", 0);
	private static var gamecenter_reportscore = Lib.load("gamecenter", "gamecenter_reportscore", 2);
	private static var gamecenter_reportachievement = Lib.load("gamecenter", "gamecenter_reportachievement", 2);
	private static var gamecenter_resetachievements = Lib.load("gamecenter", "gamecenter_resetachievements", 0);
	private static var gamecenter_showachievementbanner = Lib.load("gamecenter", "gamecenter_showachievementbanner", 2);
}

enum GcEventData {
	GAME_CENTER_READY;
	GAME_CENTER_READY_FAIL;
	GAME_CENTER_SCORE(categoryID:String);
	GAME_CENTER_SCORE_FAIL(categoryID:String);
	GAME_CENTER_ACHIEVEMENT(achievementID:String);
	GAME_CENTER_ACHIEVEMENT_FAIL(achievementID:String);
	GAME_CENTER_ACHIEVEMENT_RESET;
	GAME_CENTER_ACHIEVEMENT_RESET_FAIL;
}