/**
 * Created by Morteza on 5/27/2017.
 */
package
{
import Viewer.Animation;
import Viewer.Board;
import Viewer.FileLoader;
import Viewer.Keyboard;

import flash.external.ExternalInterface;
import flash.utils.clearTimeout;

import src2.Utils;

//import Viewer.TimeLine;
import Viewer.assets;

import flash.display.Bitmap;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

//import net.hires.debug.Stats;

[SWF(width="600", height="337", frameRate=60, backgroundColor='0x444444')]

public class ContentViewer extends Sprite
{
    public var board:Board;
    public var folder:String;
    public var loader:FileLoader;
    public var animation:Animation;
    public var sound:SoundPlayer;
    //public var timeLine:TimeLine;
    public var progress:Progress;
    public var projectPath:String;
    public var keyboard:Keyboard;

    public var actived:Boolean;

    public var playIcon:Sprite;
    public var pauseIcon:Sprite;


    private static var _volume:Volume;

    public static const W:int = 600;
    public static const H:int = 337;
    private var _topics:Array;
    private var _topicFunc:Function;
    private var _updateFunc:Function;
    private var _totalTime:String;

    public static var address:String;
    private var timeOut:uint;

    public function ContentViewer()
    {
        trace('new: ContentViewer');
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        setTimeout(INIT,1);
    }

    public function INIT():void
    {
        board = new Board(this);
        addChild(board);

        sound = new SoundPlayer(this);
        sound.addEventListener('loaded', dispachLoaded);
        sound.addEventListener('finish', dispachFinish);

        progress = new Progress(this);
        addChild(progress);

        //timeLine = new TimeLine(this, 0, 337+5, 600, 13);
        //addChild(timeLine);

        try
        {
            address = ExternalInterface.call("window.location.href.toString");
        }
        catch (e)
        {
            try
            {
                address = root.loaderInfo.url
            }
            catch (e)
            {
                address = 'rian-contentviewer-1'
            }
        }

        animation = new Animation(this);

        loader = new FileLoader(this);

        keyboard = new Keyboard(stage, this);

        _volume = new Volume();
        addChild(_volume);

        playIcon = new Sprite();
        sett(playIcon, new assets.PlayIcon());

        pauseIcon = new Sprite();
        sett(pauseIcon, new assets.PauseIcon());

        function sett(sprite:Sprite, bit:Bitmap):void
        {
            sprite.x = W/2;
            sprite.y = H/2;
            sprite.visible = false;
            addChild(sprite);
            bit.smoothing = true;
            bit.scaleX = bit.scaleY = .5;
            bit.x = - bit.width/2;
            bit.y = - bit.height/2;
            sprite.addChild(bit);
        }


        board.addEventListener(MouseEvent.CLICK, click);

        //load('D:/Projects/IdeaProjects/Template/Main/lessons/', '5');
        timeOut = setTimeout(load, 1500, 'D:/Projects/IdeaProjects/Template/Main/lessons/', '6');

        //addChild(new Stats());

    }

    public function dispachFinish(e:Event = null):void
    {
        if(e == null)
            e = new Event('finish');

        dispatchEvent(e);
    }

    private function dispachLoaded(event:Event):void
    {
        dispatchEvent(event);
    }


    private function reset():void
    {
        //trace('reset');
        board.reset();
        sound.reset();
        loader.stop();

    }

    private function click(event:MouseEvent):void
    {
        setTopicNumber(4);
        //percent = mouseX/W;
    }

    ///////////////////////////////
    public function load(dir:String, file:String, updateFunc:Function = null, topicUpdater:Function = null):void
    {
        clearTimeout(timeOut);

        actived = true;
        projectPath = dir + file + '.rian';
        reset();
        this.folder = dir + file + '/';
        loader.load(projectPath);
        _topicFunc = topicUpdater;
        _updateFunc = updateFunc;
    }

    public function get duration():Number
    {
        return sound.total;
    }

    public function get percent():Number
    {
        //return sound.percent;
        var p:Number = (sound.time - animation.startTime) / animation.duration;

        if(p < 0)
            p = 0;
        else if(p > 1)
            p = 1;

        return p;
    }

    public function get currentTime():String
    {
        //return sound.timeString;
        return Utils.timeFormat(1000 * time)
    }

    public function get time():Number
    {
        //return sound.time;
        var time:Number = sound.time - animation.startTime;

        if(time < 0)
            time = 0;
        else if(time > animation.duration)
            time = animation.duration;

        return time;
    }

    public function get totalTime():String
    {
        //return sound.totalString;
        return _totalTime;
    }

    public function get loaded():Boolean
    {
        return sound.loaded;
    }

    ///////////////////////////////
    public function set percent(p:Number):void
    {
        if(!loaded)
            return;

        //animation.resetTimes();
        //sound.percent = p;
        animation.resetTimes();
        sound.time =  animation.startTime + p*(animation.duration);
    }

    public function set time(time:Number):void
    {
        if(!loaded)
            return;

        animation.resetTimes();
        sound.time = time;
    }

    public function stop():void
    {
        //trace('stop');

        sound.stop();
    }

    public function pausePlay():void
    {
        keyboard.pausePlay();
    }

    public function prev():void
    {
        //time = animation.prevTime;
        animation.prevTopic();
    }

    public function next():void
    {
        //time = animation.nextTime;
        animation.nextTopic();
    }

    public function replay():void
    {
        //trace('replay');
        actived = true;

        animation.resetTimes();
        animation.resetTopic();
        sound.stop();
        sound.play(0);
    }

    public function hide():void
    {
        actived = false;
        //trace('pause');

        if(loaded)
        {
            //trace('sound.pause()')
            sound.pause();
        }
        else
            reset();
    }

    public function resume():void
    {
        //trace('resume');
        sound.resume();
    }

    public function pause():void
    {
        sound.pause();
    }

    public function setTopicNumber(num:int):String
    {
        return animation.newTopic(num);
    }

    public function get quizScore():Number
    {
        return animation.quizScore;
    }

    public function set quizScore(n:Number):void
    {
        animation.quizScore = n;
    }

    public function getQuiz(i:int):Array
    {
        return animation.getQuiz(i);
    }

    ///////////////////////////////

    public override function set visible(v:Boolean):void
    {
        //trace('Main visible', v);
        super.visible = v;
    }

    public static function ShowVolume(percent:Number):void
    {
        if(_volume)
            _volume.show(percent);
    }

    public function get topics():Array
    {
        trace('get topics')
        return _topics;
    }

    public function set topics(list:Array):void
    {
        trace('set topics');
        _topics = list;
        animation.topics = list;
        dispatchEvent(new Event('topics'))
    }

    public function activeTopic(i:int):void
    {
        _totalTime = Utils.timeFormat(animation.duration * 1000);
        if(_topicFunc)
            _topicFunc(i);
    }

    public function update():void
    {
        if(_updateFunc)
            _updateFunc();
    }
}
}
