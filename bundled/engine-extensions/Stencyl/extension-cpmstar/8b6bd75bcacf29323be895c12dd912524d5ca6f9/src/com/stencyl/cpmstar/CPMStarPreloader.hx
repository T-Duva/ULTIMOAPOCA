package com.stencyl.cpmstar;

import com.stencyl.Extension;
import com.stencyl.loader.StencylPreloader;
import cpmstar.AdLoader;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;

class CPMStarPreloader extends StencylPreloader
{
	private var ad:AdLoader;
	private var clickArea:TextField;

	public function new()
	{
		super();
	}

	public override function showPreloader()
	{
		adStarted();

		clickArea = new TextField();
		clickArea.selectable = false;
		clickArea.x = 0;
		clickArea.y = 0;
		clickArea.width = getWidth();
		clickArea.height = getHeight();
		
		addChild(clickArea);
		
		ad = new AdLoader(Config.cpmstarID);
		ad.x = (getWidth() / 2) - 150;
		ad.y = (getHeight() / 2) - 150;
		addChild(ad);
		
		clickArea.addEventListener(MouseEvent.CLICK, startGame);
	}

	private function startGame(event:Event)
	{
		clickArea.removeEventListener(MouseEvent.CLICK, startGame);
		removeChild(ad);
		removeChild(clickArea);
		
		adFinished();
	}
}