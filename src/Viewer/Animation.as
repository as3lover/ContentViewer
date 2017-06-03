/**
 * Created by Morteza on 5/28/2017.
 */
package Viewer
{
import flash.events.Event;


public class Animation
{
    private var _time:Number;
    private var _list:Array;
    private var _length:uint;
    private var main:ContentViewer;

    public function Animation(Main:ContentViewer)
    {
        main = Main;
    }

    public function set list(list:Array):void
    {
        _list = list;
    }

    public function start():void
    {
        main.board.addEventListener(Event.ENTER_FRAME, checkTime);
    }


    private function checkTime(e:Event = null):void
    {
        _time = main.sound.time;

        _length =  _list.length;
        for(var i:int = 0 ; i < _length; i++)
        {
            Item(_list[i]).time = _time;
        }
    }
}
}
