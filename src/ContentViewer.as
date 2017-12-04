/**
 * Created by Morteza on 5/27/2017.
 */
package
{
import Viewer.Animation;
import Viewer.Board;
import Viewer.FileLoader;
import Viewer.Keyboard;

import flash.display.Stage;

import flash.external.ExternalInterface;
import flash.text.TextField;
import flash.utils.clearTimeout;

import media.MediaPlayer;
import media.VideoPlayerMulti;

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
    //public var timeLine:TimeLine;
    public var progress:Progress;
    public var projectPath:String;
    public var keyboard:Keyboard;

    public var actived:Boolean;

    public var playIcon:Sprite;
    public var pauseIcon:Sprite;


    private var _volume:Volume;

    public static const W:int = 600;
    public static const H:int = 337;
    private var _topics:Array;
    private var _topicFunc:Function;
    private var _updateFunc:Function;
    private var _totalTime:String;

    public static var address:String;
    private var timeOut:uint;

    public var isVideo:Boolean;
    private var sound:SoundPlayer;
    private var video:VideoPlayerMulti;
    private var loadedText:String;
    private const W2:Number = W/2;
    private const H2:Number = H/2;
    private var _stage:Stage;

    public function ContentViewer()
    {
        trace('NEW: ContentViewer');
        addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(event:Event):void
    {
        _stage = stage;
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
        sound.visible = false;
        addChild(sound);

        video = new VideoPlayerMulti(this);
        video.addEventListener('loaded', dispachLoaded);
        video.addEventListener('finish', dispachFinish);
        video.visible = false;
        addChild(video);

        progress = new Progress(this);
        addChild(progress);

        //timeLine = new TimeLine(this, 0, 337+5, 600, 13);
        //addChild(timeLine);


        try
        {
            address = ExternalInterface.call("window.location.href.toString");
            if (address == null)
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

        /*
        if (address == null)
            address = 'file:///D|/Projects/IdeaProjects/Template/Main%202/movie.swf';
*/
        /*
        //// temp
        trace('address:', address);
        address = address.replace('movie.swf', '');
        var t:TextField = new TextField();
        addEventListener(Event.ENTER_FRAME, gg);
        function gg(d)
        {
            addChild(t);
            t.text = address;
        }
        //////////////////
*/

        animation = new Animation(this);

        loader = new FileLoader(this);

        keyboard = new Keyboard(_stage, this);

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


       // board.addEventListener(MouseEvent.CLICK, click);

        //load('D:/Projects/IdeaProjects/Template/Main 2/lessons/', '5');
        //timeOut = setTimeout(load, 1500, 'G:/Projects/IdeaProjects/Template/Main/lessons/', '7');
        //timeOut = setTimeout(load, 1500, 'G:\\Telegram\\Downloads\\estratejik part 2\\estratejik part 2\\', '1');
        //timeOut = setTimeout(load, 100, 'D:\\1\\', '1');

        //addChild(new Stats());

    }

    public function dispachFinish(e:Event = null):void
    {
        if(e == null)
            e = new Event('finish');

        trace("dispachFinish");
        dispatchEvent(e);
    }

    public function dispachLoaded(event:Event):void
    {
        trace("dispachLoaded");
        dispatchEvent(event);
    }


    private function reset():void
    {
        trace('Content reset');
        board.reset();
        myMedia.reset();
        loader.stop();

    }

    private function click(event:MouseEvent):void
    {
        //setTopicNumber(4);
        percent = mouseX/W;
    }

    ///////////////////////////////
    public function load(dir:String, file:String, updateFunc:Function = null, topicUpdater:Function = null):void
    {
        ///////////////
        clearTimeout(timeOut);

        actived = true;
        projectPath = dir + file + '.txt';
        reset();
        this.folder = dir + file + '\\';
        // loader.load(projectPath);
        //_topicFunc = topicUpdater;
        //_updateFunc = updateFunc;
        /////////////////


        // for video --------------------------------
        loader.loadText(folder + "video.txt", after);
        //-------------------------------------------

        function next():void
        {
            loader.load(projectPath);
            _topicFunc = topicUpdater;
            _updateFunc = updateFunc;
        }


        function after(txt:String):void
        {
            if (txt == null)
            {
                //trace("sound");
                isVideo = false;
                next();
            }
            else
            {
                try
                {
                    loadedText = txt;
                    isVideo = true;
                    next();

                }
                catch (e:*)
                {
                    next();
                }
            }
        }
    }

    public function loadVideos():void
    {
        var list:Array = loadedText.split(/\n/);

        var allVideosLen:Array = [];

        var numOfVids:int = int(list[0]);
        var ext:String = "." + String(list[1]).substr(0,3);

        if (list.length >= numOfVids + 2)
        {
            for(var j:int=0; j<numOfVids; j++)
            {
                allVideosLen.push(Number(list[j+2]))
            }
        }
        else
        {
            var vidLen:Number = Number(list[2]);
            var lastVidLen:Number = Number(list[3]);

            for(var j:int=0; j<numOfVids-1; j++)
            {
                allVideosLen.push(vidLen)
            }

            allVideosLen.push(lastVidLen)
        }


        //ext = ext.replace('\n','');
        //ext = ext.substr(0,4);

        var path:Vector.<String> = new <String>[];

        for (var i:int = 0; i < numOfVids; i++)
        {
            var str:String = folder + String(i + 1) + ext;
            trace(str, allVideosLen[i]);

            path.push(str);
        }

        isVideo = true;

        /*
         path = new <String>[];

         path.push('http://hw16.asset.aparat.com/aparat-video/e3e69632c6935b2fb29e88610051ebd17708949-144p__83594.mp4');
         path.push('http://hw2.asset.aparat.com/aparat-video/5472bdafdce2a3843b5bd95a435125e07713270-144p__78570.mp4');
         path.push('http://hw3.asset.aparat.com/aparat-video/d4d1600fe1ae3c0e872649ce9fc9fe007706280-144p__55335.mp4');
         path.push('http://hw4.asset.aparat.com/aparat-video/c9e5f5201a4c2c2afef8e3d7d5c0b9f37713839-144p__69039.mp4');
         path.push('http://hw14.asset.aparat.com/aparat-video/d9900b665e1a8013a29e6501ea0890b97703297-144p__63358.mp4');
         path.push('http://hw15.asset.aparat.com/aparat-video/64551a51e594961ae5e8bfa0a49d15087694009-144p__43097.mp4');
         path.push('http://hw7.asset.aparat.com/aparat-video/97e89d31fe8cdd94de212a96c6c6d7067696208-144p__68489.mp4');
         path.push('http://hw16.asset.aparat.com/aparat-video/211c1e7b60dabbe2811ef60a3292d93b7696973-144p__54884.mp4');

         allVideosLen = [81,81,81,81,81,81,81,81]
         */

        /*
        ///////////////////temp//////////////////
        path = new <String>[];
        path.push('https://hw18.asset.aparat.com/aparat-video/827b793a146ddceda64bd3f94f7bbadb8857639-1080p__37079.mp4');
        path.push('https://hw20.asset.filimo.com/aparat-video/12c2e09a429f831b92758863ec26ed7f8848069-1080p__58692.mp4');
        path.push('https://hw19.asset.aparat.com/aparat-video/32bc77a3b6be03a9a00d167b1353fb6f8874686-480p__45623.mp4');
        //path.push('https://hw18.asset.aparat.com/aparat-video/f2dc852b509a5e6db387fc5c4f72c9728818458-720p__23684.mp4');
        //path.push('https://hw20.asset.aparat.com/aparat-video/ace0cf1e6a8ad9381dd95213f26b33338873665-720p__80807.mp4');
        //path.push('https://hw17.asset.aparat.com/aparat-video/f456b3a90f952adee45e0a3e49e587298875176-480p__53114.mp4');
        //path.push('https://hw18.asset.aparat.com/aparat-video/c8100fb123cd8d774f099460407827dd8878801-480p__38587.mp4');
        allVideosLen = [1088,2890,1416];
        //allVideosLen = [1088,2890,1416,480,259,59,580];
        /////////////////////////////////////////
        */

        video.start(path, allVideosLen);
        video.width = W;
        video.scaleY = video.scaleX;

        manage();
    }

    private function manage():void
    {
        //trace('manage');
        var self = this;

        var back:Sprite = new Sprite();
        Utils.drawRect(back, 0, 0, W, H, 0xffffff, 1, 0xffffff, 0.5);
        addChildAt(back, 0);

        var bt:Sprite = new Sprite();

        //bt.graphics.beginFill(0xffffff);
        //bt.graphics.lineStyle(0);
        //bt.graphics.drawCircle(0,0,10);

        var arrow:Bitmap = new assets.Arrow();
        arrow.smoothing = true;
        if(arrow.width > arrow.height)
        {
            arrow.width = 40;
            arrow.scaleY = arrow.scaleX
        }
        else
        {
            arrow.height = 40;
            arrow.scaleX = arrow.scaleY
        }

        arrow.x = - arrow.width/2;
        arrow.y = - arrow.height/2;
        bt.addChild(arrow);

        bt.x = W2;
        bt.y = H2;
        bt.buttonMode = true;
        bt.alpha = 0.5;
        self.addChild(bt);

        var moving:Boolean = false;
        var outed:Boolean = true;

        bt.addEventListener(MouseEvent.MOUSE_OVER, over);
        function over(e:MouseEvent):void
        {
            bt.alpha = 1;
            outed = false;
        }

        bt.addEventListener(MouseEvent.MOUSE_OUT, out);
        function out(e:MouseEvent):void
        {
            if(!moving)
                bt.alpha = 0.5;

            outed = true;
        }

        var boardPos:Sprite = new Sprite();
        Utils.drawRect(boardPos, 0, 0, W, H);
        self.addChildAt(boardPos,0);

        var maskk:Sprite = new Sprite();
        Utils.drawRect(maskk, 0, 0, W, H);
        //self.addChildAt(maskk, 1);

        var pos:int;
        var posOld:int;

        bt.addEventListener(MouseEvent.MOUSE_DOWN, onDown);

        pos = W2;
        move();

        function onDown(event:MouseEvent):void
        {
            //trace('onDown');
            moving = true;
            _stage.addEventListener(Event.ENTER_FRAME, onMove);
            _stage.addEventListener(MouseEvent.MOUSE_UP, onUP)
        }
        function onUP(event:MouseEvent):void
        {
            //trace('onUp');
            moving = false;
            if (outed)
                    out(null)
            _stage.removeEventListener(Event.ENTER_FRAME, onMove);
        }

        function onMove(event:Event):void
        {
            pos = mouseX;

            if(pos<0)
                pos = 0;
            else if(pos>W)
                pos = W;

            move()

        }

        function move()
        {
            if (pos == posOld)
                return;

            import com.greensock.layout.*;

            posOld = pos;

            bt.x = pos;

            var area:AutoFitArea = new AutoFitArea(self, 0, 0, pos, H);
            area.attach(boardPos);

            area = new AutoFitArea(self, pos, 0, W-pos, H);
            area.attach(myMedia as Sprite);

            maskk.x = boardPos.x;
            maskk.y = boardPos.y;
            maskk.scaleX = boardPos.scaleX;
            maskk.scaleY = boardPos.scaleY;

            board.x = boardPos.x;
            board.y = boardPos.y;
            board.scaleX = boardPos.scaleX;
            board.scaleY = boardPos.scaleY;

            //board.mask = maskk;
        }
    }

    public function get duration():Number
    {
        return myMedia.total;
    }

    public function get percent():Number
    {
        //return sound.percent;
        var p:Number = (myMedia.time - animation.startTime) / animation.duration;

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
        var time:Number = myMedia.time - animation.startTime;

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
        return myMedia.loaded;
    }

    ///////////////////////////////
    public function set percent(p:Number):void
    {
        if(!loaded)
            return;

        //animation.resetTimes();
        //sound.percent = p;
        animation.resetTimes();
        myMedia.time =  animation.startTime + p*(animation.duration);
    }

    public function set time(time:Number):void
    {
        if(!loaded)
            return;

        animation.resetTimes();
        myMedia.time = time;
    }

    public function stop():void
    {
        trace('VIEWER stop');
        myMedia.stop();
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
        myMedia.stop();
        myMedia.play(0);
    }

    public function hide():void
    {
        actived = false;
        trace('Content hide');

        if (myMedia is VideoPlayerMulti)
            (myMedia as VideoPlayerMulti).stopLoad();

        if(loaded)
        {
            trace(' myMedia.pause(')
            myMedia.pause();
        }
        else
        {
            trace('reset');
            reset();
        }
    }

    public function resume():void
    {
        //trace('resume');
        myMedia.resume();
    }

    public function pause():void
    {
        trace('Content Pause');
        myMedia.pause();
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

    public function ShowVolume(percent:Number):void
    {
        if(_volume)
            _volume.show(percent);
    }

    public function get topics():Array
    {
        return _topics;
    }

    public function set topics(list:Array):void
    {
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


    public function get myMedia():MediaPlayer
    {
        if (isVideo)
        {
            video.visible = true;
            sound.visible = false;
            return video;
        }
        else
        {
            sound.visible = true;
            video.visible = false;
            return sound
        }
    }


}
}
