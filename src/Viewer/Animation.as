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

    ///////////////////
    public function Animation(Main:ContentViewer)
    {
        main = Main;
    }

    ///////////////////////////////// Set List
    public function set list(list:Array):void
    {
        _list = list;
    }

    ///////////////////////////////// Start
    public function start():void
    {
        trace('start animation');
        Utils.sortArrayByField(_list,'startTime');

        _currentIndex = -1;

        _currentTopic = -1;
        _startTime = 0;
        _stopTime = main.myMedia.total;
        _duration = _stopTime - _startTime;
        main.activeTopic(0);

        _show = new Array()
        _hide = new Array()

        _master = new Array();

        var i:int;

        _len =  int(main.myMedia.total/STEP);

        ////////////////////////////
        var maxStartTime = Item(_list[_list.length - 1]).startTime;
        var maxLen = int(maxStartTime/STEP);
        if(maxLen > _len) _len = maxLen;
        ////////////////////////////

        //
        _len++;
        //

        for(i=0; i<_len; i++)
        {
            _master[i] = new Array();
        }

        _len =  _list.length;

        var i2:int;

        for(i = 0 ; i < _len; i++)
        {
            i2 = int(Item(_list[i]).startTime / STEP);
            try
            {
                _master[i2].push(_list[i]);
            }
            catch (e)
            {
                trace(e);
                trace('_master:',_master);
                trace('_master.length:',_master.length);
                trace('i2:',i2);
                trace('_master[i2]:',_master[i2]);
                trace('_list:',_list);
                trace('_list.length:',_list.length);
                trace('i:',i);
                trace('_list[i]:',_list[i]);
                trace('>>>>>');
                //trace(_master.length, _list.length, i2, i);
            }
        }

        main.board.addEventListener(Event.ENTER_FRAME, checkTimes);
    }
    ////////////////////





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





    private function checkTimes(event:Event):void
    {
        //trace('checkTimes 1');
        var time:Number = main.myMedia.time;
        if(_time == time)
            return;

        _time = time;



        var i:int = int(_time/STEP);

        if(i > _master.length - 1)
                i = _master.length - 1;
        else if (i<0)
                i = 0;

        //trace('checkTimes 2', i, _currentIndex);


        if(i != _currentIndex)
        {
            _currentIndex = i;

            //trace('i:', i, '_master.length:', _master.length, '_master[i]:', _master[i], '_master:', typeof _master);

            //if(_clone)
                //trace('_clone.length:', _clone.length);

            _clone = Utils.copyArray(_master[i]);

            //trace(_clone.length, '_clone:', _clone);

            if(i>0)
                _clone = _clone.concat(_master[i-1]);

            //trace(_clone.length, '_clone:', _clone);

        }

        //trace('checkTimes 3');


        var index:Array=[];
        //trace('checkTimes 3.1');
        //trace(_len, _clone, "Hi!")

        if(_clone)
            _len = _clone.length;
        else
            _len = 0;


        //trace('checkTimes 3.2');

        for(i = 0 ; i<_len; i++)
        {
            //trace('checkTimes 3.2.1');

            var item = Item(_clone[i]);
            //trace('checkTimes 3.3', 'clone:', _clone, 'item:',  item, 'clone[i]:', _clone[i], 'i:', i, 'len:', _len, 'length:',  _clone.length);
            //trace('checkTimes 3.4', item.startTime);
            //trace('checkTimes 3.5', _time);


            if(Item(_clone[i]).startTime <= _time)
                index.push(i);
            else
                break;
        }

        //trace('checkTimes 4');


        _len = index.length;
        for(i = _len-1 ; i>-1; i--)
        {
            Item(_clone[i]).visible = true;
            _clone.splice(i,1)
        }

        //trace('checkTimes 5');


        setTimes();

        //trace('checkTimes 6');

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
        var time:Number = main.myMedia.time;
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
            _stopTime = main.myMedia.total;

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
