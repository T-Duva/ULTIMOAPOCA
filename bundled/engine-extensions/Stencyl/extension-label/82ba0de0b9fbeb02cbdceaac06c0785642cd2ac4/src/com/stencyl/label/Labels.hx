package com.stencyl.label;

import com.stencyl.models.Actor;
import com.stencyl.models.Font;
import com.stencyl.utils.Utils;

class Labels
{
	public static var LABEL:String = "label";

	public static function create(a:Actor)
	{
		if(a != null)
		{
			var l = new Label();
			l.multiLine = false;
			l.fixedWidth = false;
			l.useColor = false;
			
			a.disableActorDrawing();
			a.addChild(l);
			a.label = l;

			l.cacheParentAnchor = a.cacheAnchor;
			l.set_labelX(0);
			l.set_labelY(0);
			l.updatePosition();

			a.setActorValue(LABEL, l);
		}
	}
	
	public static function destroy(a:Actor)
	{
		if(a != null && a.label != null)
		{
			a.enableActorDrawing();
			a.removeChild(a.label);
			a.label.cacheParentAnchor = Utils.zero;
			a.label = null;
			
			a.setActorValue(LABEL, null);
		}
	}
	
	public static function setFont(a:Actor, f:Font)
	{
		if(a != null && a.label != null)
		{
			a.label.stencylFont = f;
		}
	}
	
	public static function setText(a:Actor, s:String)
	{
		if(a != null && a.label != null)
		{
			a.label.text = s;
		}
	}
	
	public static function enableTextWrap(a:Actor, width:Int)
	{
		if(a != null && a.label != null)
		{
			a.label.multiLine = true;
			a.label.fixedWidth = true;
			a.label.setWidth(width);
		}
	}
	
	public static function setAlignment(a:Actor, align:Int)
	{
		if(a != null && a.label != null)
		{
			a.label.alignment = align;
		}
	}
}