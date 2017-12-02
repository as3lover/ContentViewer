/**
 * Created by Morteza on 4/23/2017.
 */
package Viewer
{
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import media.MediaPlayer;

import src2.Utils;

public class Keyboard
{
    private var _stage:Stage;
    private var _main:ContentViewer;
    private var _player:MediaPlayer;

    public function Keyboard(stage:Stage, main:ContentViewer, player:MediaPlayer)
    {
        _stage = stage;
        _main = main;
        _player = player;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
    }

    private function onWheel(e:MouseEvent):void
    {
        if(!_main.actived)
            return;

        if(e.delta < 0)
            _player.volumeDown();
        else
            _player.volumeUp();
    }


    private function onKeyDown(e:KeyboardEvent):void
    {
        if(!_main.actived || !_main.loaded)
                return;

        switch (e.keyCode)
        {
            case 37://Left Arrow
                changeTime(e.ctrlKey, e.shiftKey, -1);
                break;

            case 39://Right Arrow
                changeTime(e.ctrlKey, e.shiftKey, +1);
                break;

            case 38://Up
                _player.volumeUp();
                break;

            case 40://Down
                _player.volumeDown();
                break;

            case 32://Space
                pausePlay();
                break;

            case 13:// Enter
                pausePlay();
                break;
        }
    }

    public function pausePlay():void
    {
        if(!_main.myMedia.loaded)
            return;

        if(_main.myMedia.pausePlay())
        {
            _main.pauseIcon.visible = false;
            Utils.zoomToast(_main.playIcon);
        }
        else
        {
            _main.playIcon.visible = false;
            Utils.zoomToast(_main.pauseIcon);
        }
    }

    private function changeTime(ctrlKey:Boolean, shiftKey:Boolean, i:Number):void
    {
        if(shiftKey)
            i *= 60;
        else if(ctrlKey)
            i*= 30;
        else
            i *= 5;

        //trace(i);
        _main.time = _main.myMedia.time + i;
    }
}
}
