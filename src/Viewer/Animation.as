/**
 * Created by Morteza on 5/28/2017.
 */
package Viewer
{
import flash.events.Event;
import flash.utils.getTimer;

public class Animation
{
    private var _time:Number;
    private var _list:Array;
    private var _length:uint;
    private var _newTimer:int;
    private var _oldTimer:int;

    public function Animation()
    {
    }

    public function play(time:Number = -1):void
    {
        _time = time;

        _length =  _list.length;
        for(var i:int = 0 ; i < _length; i++)
        {
            ViewItem(_list[i]).time = _time;
        }

        _oldTimer = getTimer();
        View.board.addEventListener(Event.ENTER_FRAME, ef);
    }

    private function ef(e:Event):void
    {
        _newTimer = getTimer();
        _time += (_newTimer - _oldTimer)/1000;
        for(var i:int = 0 ; i < _length; i++)
        {
            ViewItem(_list[i]).time = _time;
        }
        _oldTimer = _newTimer;
    }

    public function set list(list:Array):void
    {
        _list = list;
    }
}
}
