/**
 * Created by Morteza on 5/28/2017.
 */
package Viewer
{
import flash.events.Event;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import src2.Utils;

public class Animation
{
    private var _time:Number;
    private var _list:Array;
    private var _length:uint;

    private var main:ContentViewer;
    private var _currentIndex:int;

    private var _master:Array;
    private var _clone:Array;
    public var _show:Array;

    private var _hide:Array;
    private const STEP:Number = 1;
    private var _timeout:uint;


    public function Animation(Main:ContentViewer)
    {
        main = Main;
    }

    public function set list(list:Array):void
    {
        _list = list;
    }

    public function resetTimes()
    {
        clearTimeout(_timeout);
        main.board.removeEventListener(Event.ENTER_FRAME, checkTimes);
        _currentIndex = -1;
        _clone = [];
        main.board.addEventListener(Event.ENTER_FRAME, checkTime);
        _timeout = setTimeout(sett,700);
        function sett()
        {
            main.board.addEventListener(Event.ENTER_FRAME, checkTimes);
            main.board.removeEventListener(Event.ENTER_FRAME, checkTime);
        }
    }

    public function start():void
    {
        sort(_list);

        _currentIndex = -1;

        _show = new Array()
        _hide = new Array()

        _master = new Array();

        var i:int;
        _length =  int(main.sound.total/STEP);


        for(i=0; i<_length; i++)
        {
            _master[i] = new Array();
        }

        _length =  _list.length;

        var i2:int;

        for(i = 0 ; i < _length; i++)
        {
            i2 = int(Item(_list[i]).startTime / STEP);
            _master[i2].push(_list[i]);
        }

        main.board.addEventListener(Event.ENTER_FRAME, checkTimes);
    }


    private function sort(list:Array):void
    {
        _length = list.length;
        for(var i:int=0; i<_length-1; i++)
        {
            for(var j:int=_length-1; j>i; j--)
            {
                if(Item(list[j]).startTime < Item(list[j-1]).startTime)
                    swap(list, j, j-1);
            }
        }
    }

    private function swap(list:Array, i:int, j:int):void
    {
        var temp:Item = list[i];
        list[i] = list[j];
        list[j] = temp
    }

    private function checkTimes(event:Event):void
    {
        var time:Number = main.sound.time;
        if(_time == time)
            return;

        main.setTimer();

        //main.add(null);

        _time = time;

        var i:int = int(_time/STEP);

        if(i != _currentIndex)
        {
            _currentIndex = i;

            _clone = copyArray(_master[i]);

            if(i>0)
                _clone = _clone.concat(_master[i-1])

        }

        var index:Array=[];
        _length = _clone.length;
        for(i = 0 ; i<_length; i++)
        {
            if(Item(_clone[i]).startTime <= _time)
                index.push(i);
            else
                break;
        }

        _length = index.length;
        for(i = _length-1 ; i>-1; i--)
        {
            Item(_clone[i]).visible = true;
            _clone.splice(i,1)
        }

        setTimes();
    }

    private function setTimes():void
    {
        main.timeLine.percent = main.percent;

        _length =  _show.length;
        //trace(_length)
        for(var i:int = _length-1 ; i>-1 ; i--)
        {
            Item(_show[i]).time = _time;
        }

        main.traceTime('new Type');
        //checkTime();
    }

    public function remove(item:Item):void
    {
        Utils.removeObjectFromArray(_show, item);
    }

    public function add(item:Item):void
    {
        _show.push(item);
    }

    private function copyArray(list:Array):Array
    {
        if(!list)
            return [];

        var copy:Array = new Array();
        var l:int = list.length;
        for(var i:int=0; i<l; i++)
        {
            copy[i] = list[i];
        }
        return copy;
    }

    private function checkTime(e:Event = null):void
    {
        var time:Number = main.sound.time;
        if(_time == time)
            return;

        main.setTimer();
        main.timeLine.percent = main.percent;
        _time = time;

        _length =  _list.length;
        for(var i:int = 0 ; i < _length; i++)
        {
            Item(_list[i]).time = _time;
        }
        main.traceTime('oldType');

    }

}
}
