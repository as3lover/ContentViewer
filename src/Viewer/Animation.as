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
    private var _len:uint;

    private var main:ContentViewer;
    private var _currentIndex:int;
    private var _currentTopic:int;

    private var _master:Array;
    private var _clone:Array;
    public var _show:Array;

    private var _hide:Array;
    private const STEP:Number = 1;
    private var _timeout:uint;
    private var _topics:Array;

    private var _startTime:Number;
    private var _stopTime:Number;
    private var _duration:Number;


    public function Animation(Main:ContentViewer)
    {
        main = Main;
    }

    ///////////////////////////////// Set List
    public function set list(list:Array):void
    {
        _list = list;
    }

    ///////////////////////////////// reset Times
    public function resetTimes():void
    {
        clearTimeout(_timeout);
        main.board.removeEventListener(Event.ENTER_FRAME, checkTimes);
        _currentIndex = -1;
        _clone = [];
        main.board.addEventListener(Event.ENTER_FRAME, checkTime);
        _timeout = setTimeout(sett,700);
        function sett():void
        {
            main.board.addEventListener(Event.ENTER_FRAME, checkTimes);
            main.board.removeEventListener(Event.ENTER_FRAME, checkTime);
        }
    }

    ///////////////////////////////// Start
    public function start():void
    {
        Utils.sortArrayByField(_list,'startTime');

        _currentIndex = -1;
        
        _currentTopic = -1;
        _startTime = 0;
        _stopTime = main.sound.total;
        _duration = _stopTime - _startTime;
        main.activeTopic(0);

        _show = new Array()
        _hide = new Array()

        _master = new Array();

        var i:int;
        _len =  int(main.sound.total/STEP);


        for(i=0; i<_len; i++)
        {
            _master[i] = new Array();
        }

        _len =  _list.length;

        var i2:int;

        for(i = 0 ; i < _len; i++)
        {
            i2 = int(Item(_list[i]).startTime / STEP);
            _master[i2].push(_list[i]);
        }

        main.board.addEventListener(Event.ENTER_FRAME, checkTimes);
    }



    private function checkTimes(event:Event):void
    {
        var time:Number = main.sound.time;
        if(_time == time)
            return;

        _time = time;

        var i:int = int(_time/STEP);

        if(i != _currentIndex)
        {
            _currentIndex = i;

            _clone = Utils.copyArray(_master[i]);

            if(i>0)
                _clone = _clone.concat(_master[i-1])

        }

        var index:Array=[];
        _len = _clone.length;
        for(i = 0 ; i<_len; i++)
        {
            if(Item(_clone[i]).startTime <= _time)
                index.push(i);
            else
                break;
        }

        _len = index.length;
        for(i = _len-1 ; i>-1; i--)
        {
            Item(_clone[i]).visible = true;
            _clone.splice(i,1)
        }

        setTimes();
    }

    ///////////////////////////////// set Times
    private function setTimes():void
    {
        checkTopics();
        main.update();

        _len =  _show.length;
        for(var i:int = _len-1 ; i>-1 ; i--)
        {
            Item(_show[i]).time = _time;
        }
    }

    ///////////////////////////////// Old check Time
    private function checkTime(e:Event = null):void
    {
        var time:Number = main.sound.time;
        if(_time == time)
            return;

        _time = time;
        checkTopics();
        main.update();

        _len =  _list.length;
        for(var i:int = 0 ; i < _len; i++)
        {
            Item(_list[i]).time = _time;
        }
    }

    ////////////////////////////////////// Topics
    public function set topics(topics:Array):void
    {
        _topics = topics;
    }

    public function checkTopics():void
    {
        _len = _topics.length;
        for(var i:int=_len-1; i>-1; i--)
        {
            //trace('i:',i, 'topic i time:',_topics[i].time,'current time', _time, 'currentTopic:', _currentTopic, 'id:', _topics[i].id);
            if(_topics[i].time - 1 < _time)
            {
                if(_currentTopic != i)
                {
                    currentTopic = i;
                    main.activeTopic(i);
                    if(_topics[i].id)
                        main.pause();

                }
                return;
            }
        }
    }

    public function set currentTopic(i:Number):void
    {
        _currentTopic = i;

        _startTime = _topics[i].time;
        if(_topics.length > i+1)
            _stopTime = _topics[i+1].time;
        else
            _stopTime = main.sound.total;

        _duration = _stopTime - _startTime;
    }

    public function newTopic(num:int):String
    {
        //trace('newTopic', num)
        for(var i:int=0; i<num; i++)
        {
            if(_topics[i].id)
            {
                var score:Object = _topics[i].score;
                //trace('score', score);
                if(score == -1)
                {
                    return String('ابتدا باید به سؤالات ' + _topics[i].text + ' پاسخ دهید.');
                }
                else if(score < 70)
                {
                    return String('ابتدا باید نمره کافی در ' + _topics[i].text + ' به دست آورید');
                }
            }
        }

        main.time = _topics[num].time;

        return null;
    }

    public function get startTime():Number
    {
        return _startTime;
    }

    public function get stopTime():Number
    {
        return _stopTime;
    }

    /////////////////////////// Add / Remove : Show List
    public function remove(item:Item):void
    {
        Utils.removeObjectFromArray(_show, item);
    }

    public function add(item:Item):void
    {
        _show.push(item);
    }
    ///////////////////////////
    public function get duration():Number
    {
        return _duration;
    }

    public function get prevTime():Number
    {
        if(_currentTopic > 0)
            return _topics[_currentTopic-1].time;
        else
            return 0;
    }

    public function get nextTime():Number
    {
        if(_currentTopic < _topics.length-1)
            return _topics[_currentTopic+1].time;
        else
            return _time;
    }

    public function prevTopic():void
    {
        if(_currentTopic > 0)
            main.setTopicNumber(_currentTopic-1);
        else
            main.setTopicNumber(_currentTopic);
    }

    public function nextTopic():void
    {
        if(_currentTopic < _topics.length-1)
            main.setTopicNumber(_currentTopic+1);
        else
                main.resume();
    }

    public function get quizScore():Number
    {
        return _topics[_currentTopic].score;
    }

    public function set quizScore(n:Number):void
    {
        if( _topics[_currentTopic].score > n && n == 0)
                return;

         _topics[_currentTopic].score = n;
        Client.save('quiz_score_' + _topics[_currentTopic].id, n)
    }

    public function getQuiz(num:int):Array
    {
        return Utils.shuffle(_topics[num].quiz);
    }

    public function resetTopic():void
    {
        _currentTopic = -1;
    }
}
}
