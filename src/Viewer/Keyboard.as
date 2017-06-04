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

    public function Keyboard(stage:Stage, main:ContentViewer)
    {
        this.stage = stage;
        this.main = main;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
    }

    private function onWheel(e:MouseEvent):void
    {
        if(!main.visible)
            return;

        if(e.delta < 0)
                SoundPlayer.volumeDown();
        else
                SoundPlayer.volumeUp();
    }


    private function onKeyDown(e:KeyboardEvent):void
    {
        if(!main.loaded || !main.visible)
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
                SoundPlayer.volumeUp();
                break;

            case 40://Down
                SoundPlayer.volumeDown();
                break;

            case 32://Space
                pausePlay();
                break;

            case 13:// Enter
                pausePlay();
                break;
        }
    }

    private function pausePlay():void
    {
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

        trace(i);
        main.setTime(main.sound.time + i);
    }
}
}
