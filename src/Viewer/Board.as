/**
 * Created by Morteza on 5/27/2017.
 */
package Viewer
{
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;

import src2.Utils;

public class Board extends Sprite
{
    private var _back:Sprite;
    private var _mask:Sprite;
    private const RED:uint = 0xff0000;
    private var main:ContentViewer;
    ;

    public function Board(Main:ContentViewer)
    {
        main = Main;
        
        visible = false;
        color = RED;

        _back = new Sprite();
        addChild(_back);

        _mask = new Sprite();
        Utils.drawRect(_mask,0,0,600,337);

        addEventListener(Event.ADDED_TO_STAGE, init)
    }

    private function init(event:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);

        parent.addChild(_mask);
        mask = _mask;
    }

    public function set color(color:uint):void
    {
        var alpha:Number = 1;
        if(color == RED)
                alpha = 0;

        graphics.clear();
        graphics.beginFill(color, alpha);
        graphics.drawRect(0,0, 600, 337);
        graphics.endFill();
        visible = true;
    }

    public function reset():void
    {
        visible = false;
        while(numChildren > 1)
            removeChildAt(1);

        while(_back.numChildren)
            _back.removeChildAt(0);
    }

    public function set back(file:String):void
    {
        main.loader.loadBitmap(file, loadedBack)
    }

    private function loadedBack(bit:Bitmap):void
    {
        bit.width = _mask.width;
        bit.scaleY = bit.scaleX;

        if(bit.height < _mask.height)
        {
            bit.height = _mask.height;
            bit.scaleX = bit.scaleY
        }
        bit.x = bit.width - _mask.width;

        _back.addChild(bit);

        var mask:Sprite = new Sprite();
        Utils.drawRect(mask, 0,0, _mask.width, _mask.height);
        _back.addChild(mask);
        _back.mask = mask;
    }


    public override function set visible(v:Boolean):void
    {
        //trace('board visible', v);
        super.visible = v;
    }



}
}
