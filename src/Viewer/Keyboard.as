/**
 * Created by Morteza on 4/23/2017.
 */
package Viewer
{
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import src2.Utils;

public class Keyboard
{
    private var stage:Stage;
    private var main:ContentViewer;
    private var sndPlayer:SoundPlayer;

    public function Keyboard(stage:Stage, main:ContentViewer, sndPlayer:SoundPlayer)
    {
        this.stage = stage;
        this.main = main;
        this.sndPlayer = sndPlayer;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
    }

    private function onWheel(e:MouseEvent):void
    {
        if(!main.actived)
            return;

        if(e.delta < 0)
            sndPlayer.volumeDown();
        else
            sndPlayer.volumeUp();
    }


    private function onKeyDown(e:KeyboardEvent):void
    {
        if(!main.actived || !main.loaded)
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
                sndPlayer.volumeUp();
                break;

            case 40://Down
                sndPlayer.volumeDown();
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
        if(!main.sound.loaded)
            return;

        if(main.sound.pausePlay())
        {
            main.pauseIcon.visible = false;
            Utils.zoomToast(main.playIcon);
        }
        else
        {
            main.playIcon.visible = false;
            Utils.zoomToast(main.pauseIcon);
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
        main.time = main.sound.time + i;
    }
}
}
