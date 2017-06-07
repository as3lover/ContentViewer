/**
 * Created by Morteza on 6/4/2017.
 */
package Viewer
{
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import src2.Utils;

public class TimeLine extends Sprite
{
    private var _bar:Sprite;
    public var main:ContentViewer;
    private var _w:Number;
    private var _mouseX:Number;
    private var _x:Number;
    private var _down:Boolean;
    private var _p:Number;
    private var _btn:Sprite;

    public function TimeLine(main:ContentViewer, x:int, y:int, width:int, height:int)
    {
        _btn = new Sprite();
        var bit:Bitmap = new assets.PausePlay();
        bit.height = height;
        bit.scaleX = bit.scaleY;
        bit.smoothing = true;
        _btn.buttonMode = true;
        addChild(_btn);
        _btn.addChild(bit);

        var space:int = bit.width + 5;
        _btn.x -= space;
        x += space;
        width -= space;
        /////////////////////////

        this.main = main;
        this.x = x;
        this.y = y;
        _w = width;

        Utils.drawRect(this, 0,0, _w, height, 0x1A783E);

        _bar = new Sprite();
        Utils.drawRect(_bar, 0,0, _w, height, 0x8EC2A2);
        addChild(_bar);

        var line:Sprite = new Sprite();
        Utils.drawRect(line, 0,0, _w, height, -1, .5, 0xffffff);
        addChild(line);

        addEventListener(MouseEvent.MOUSE_DOWN, onDown);
    }

    private function onDown(e:MouseEvent):void
    {
        if(e.target == _btn)
        {
            main.keyboard.pausePlay();
            return;
        }


        _x = -1;
        _p = -1;
        _down = true;
        stage.addEventListener(Event.ENTER_FRAME, ef);
        stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
    }

    private function ef(event:Event):void
    {
        _mouseX = mouseX;
        if(_x == _mouseX)
                return;
        _x = _mouseX;

        var p:Number = _mouseX / _w;

        if(p > 1)
            p = 1;
        else if(p < 0)
            p = 0;

        if(p == _p)
                return;

        _p = p;
        setScale(p);
        main.percent = p;
    }

    private function onUp(event:MouseEvent):void
    {
        stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
        stage.removeEventListener(Event.ENTER_FRAME, ef);
        _down = false;

    }

    public function set percent(p:Number):void
    {
        if(!_down)
            setScale(p);
    }

    private function setScale(p:Number):void
    {
        _bar.scaleX = p;
    }
}
}