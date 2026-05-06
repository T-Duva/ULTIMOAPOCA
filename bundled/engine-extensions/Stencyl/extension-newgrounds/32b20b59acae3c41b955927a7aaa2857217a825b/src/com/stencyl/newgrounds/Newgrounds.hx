#if flash
package com.stencyl.newgrounds;

import com.newgrounds.API;
import com.newgrounds.ScoreBoard;
import com.newgrounds.components.FlashAd;
import com.newgrounds.components.MedalPopup;
import com.newgrounds.components.ScoreBrowser;

import com.stencyl.Engine;
import com.stencyl.Extension;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;

class Newgrounds extends Extension
{
	public function new()
	{
		super();
		if(Config.newgroundsID != "")
		{
			API.connect(Lib.current.root, Config.newgroundsID, Config.newgroundsKey);
		}
	}

	public override function reloadGame():Void
	{
		medalPopup = null;
		clickArea = null;
		scoreBrowser = null;
	}

	private static var medalPopup:MedalPopup = null;
	private static var clickArea:TextField = null;
	private static var scoreBrowser:ScoreBrowser = null;
	
	public static function newgroundsShowAd()
	{
		var flashAd = new FlashAd();
		flashAd.fullScreen = true;
		flashAd.showPlayButton = true;
		flashAd.mouseChildren = true;
		flashAd.mouseEnabled = true;
		Engine.engine.root.parent.addChild(flashAd);
	}
	
	public static function newgroundsSetMedalPosition(x:Int, y:Int)
	{
		if(medalPopup == null)
		{
			medalPopup = new MedalPopup();
			Engine.engine.root.parent.addChild(medalPopup);
		}
		
		medalPopup.x = x;
		medalPopup.y = y;
	}
	
	public static function newgroundsUnlockMedal(medalName:String)
	{
		if(medalPopup == null)
		{
			medalPopup = new MedalPopup();
			Engine.engine.root.parent.addChild(medalPopup);
		}
		
		API.unlockMedal(medalName);
	}
	
	public static function newgroundsSubmitScore(boardName:String, value:Float)
	{
		API.postScore(boardName, value);
	}
	
	public static function newgroundsShowScore(boardName:String)
	{
		if(scoreBrowser == null)
		{
			scoreBrowser = new ScoreBrowser();
			scoreBrowser.scoreBoardName = boardName;
			scoreBrowser.period = ScoreBoard.ALL_TIME;
			scoreBrowser.loadScores();
			
			scoreBrowser.x = Engine.screenWidth/2*Engine.SCALE*Engine.screenScaleX - scoreBrowser.width/2;
			scoreBrowser.y = Engine.screenHeight/2*Engine.SCALE*Engine.screenScaleY - scoreBrowser.height/2;
			
			var button = new Sprite();
			button.x = 8;
			button.y = scoreBrowser.height - 31;
			
			button.graphics.beginFill(0x0aaaaaa);
     		button.graphics.drawRoundRect(0, 0, 50, 20, 8, 8);
     		button.graphics.endFill();
			
			button.graphics.beginFill(0x713912);
     		button.graphics.drawRoundRect(1, 1, 50 - 2, 20 - 2, 8, 8);
     		button.graphics.endFill();
     		
			clickArea = new TextField();
			clickArea.selectable = false;
			clickArea.x = button.x + 9;
			clickArea.y = button.y + 3;
			clickArea.width = 50;
			clickArea.height = 20;
			clickArea.textColor = 0xffffff;
			clickArea.text = "Close";	
			
			scoreBrowser.addChild(button);
			scoreBrowser.addChild(clickArea);
			
			clickArea.addEventListener
			(
				MouseEvent.CLICK,
				newgroundsHelper
			);
		}
		
		Engine.engine.root.parent.addChild(scoreBrowser);
	}
		
	private static function newgroundsHelper(event:MouseEvent)
	{
		Engine.engine.root.parent.removeChild(scoreBrowser);
	}
}
#end