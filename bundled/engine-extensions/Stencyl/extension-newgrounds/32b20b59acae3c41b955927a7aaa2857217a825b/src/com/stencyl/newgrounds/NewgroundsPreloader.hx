package com.stencyl.newgrounds;

import com.newgrounds.components.APIConnector;
import com.stencyl.loader.StencylPreloader;
import openfl.events.Event;

class NewgroundsPreloader extends StencylPreloader
{
	var apiConnector:APIConnector;

	public function new()
	{
		super();
	}

	public override function showPreloader()
	{
		adStarted();

		apiConnector = new APIConnector();
		apiConnector.apiId = Config.newgroundsID;
		apiConnector.encryptionKey = Config.newgroundsKey;
		addChild(apiConnector);
		
		apiConnector.loader.addEventListener(Event.REMOVED_FROM_STAGE, finishNewgrounds);
		apiConnector.x = (getWidth() - apiConnector.width) / 2;
		apiConnector.y = (getHeight() - apiConnector.height) / 2;
	}

	public function finishNewgrounds(e:Event)
	{
		apiConnector.loader.removeEventListener(Event.REMOVED_FROM_STAGE, finishNewgrounds);
		
		// trace("Closed Newgrounds Ad");
		adFinished();
	}
}