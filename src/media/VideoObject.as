/**
 * Created by mkh on 2017/07/28.
 */
package media
{
import Viewer.assets;

import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Linear;

import flash.display.Bitmap;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.text.TextField;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import src2.Utils;

public class VideoObject extends Sprite
{
    private const W:int = ContentViewer.W;
    private const H:int = ContentViewer.H;

    private var loading:Sprite;
    private var bar:Sprite;
    private var timeLine:Sprite;
    private var statusView:TextField;

    private var video:Video;
    private var _duration:Number;
    private var nc:NetConnection;
    private var videoSound:SoundTransform;
    private var _volume:int = 100;
    private var ns:NetStream;

    private var connected:Boolean;
    private var _bufferFull:Boolean;
    private var loadComplete:Boolean;
    private var paused:Boolean;
    private var _isPlaying:Boolean;

    private var bytesLoaded:uint;
    private var bytesTotal:uint;
    private var buffer:Sprite;
    private var currentFile:String;
    private var currentTime:Number;
    private var timeToSeek:int;
    private var _toPercent:Number = -1;
    private var lastMsg:String;

    private var loadTimeOut:uint;
    private var plyTimeout:uint;
    private var bfrTimeout:uint;
    private var path:String;
    private const bufferTime:Number = 10;

    public function get file():String
    {
        return path;
    }

    public function VideoObject(path:String = null)
    {
        var back:Sprite = new Sprite();
        Utils.drawRect(back, 0, 0, W, H, 0x333333, 1, 0, .5);
        addChildAt(back, 0);

        //addChild(new flvParse());
        //return

        //addChild(new StreamLoader());
        //return;

        //addChild(new FLVSliceTest());
        //return;
        this.path = path;

        video = new Video(W,H);
        video.smoothing = true;
        addChild(video);

        nc = new NetConnection();
        nc.connect(null);

        ns = new NetStream(nc);

        video.attachNetStream(ns);

        var newMeta:Object = new Object();
        newMeta.onMetaData = onMetaData;
        ns.client = newMeta;
        ns.bufferTime = bufferTime;

        videoSound = new SoundTransform();
        videoSound.volume = 1;
        ns.soundTransform = videoSound;
        ////////////////////////////

        loading = new Sprite();
        /*
        var text:TextField = new TextField();
        text.text = 'Loading...';
        text.background = true;
        text.backgroundColor = 0xffffff;
        text.width = text.textWidth + 10;
        text.height = text.textHeight + 10;
        text.scaleX = text.scaleY = 4;
        text.x = -text.width/2;
        text.y = -text.height/2;
        loading.addChild(text);
        */
        var bit:Bitmap = new assets.Loading();
        bit.x = - bit.width/2;
        bit.y = - bit.height/2;
        bit.alpha = 0.5;
        bit.smoothing = true;
        loading.addChild(bit);

        loading.x = W/2;
        loading.y = H/2;
        addChild(loading);
        ////////////////////////////
        buffer = new Sprite();
        Utils.drawRect(buffer, 0, 0, W, 10, 0xffffff, .5);
        buffer.y = H - buffer.height;
        //addChild(buffer);
        ////////
        bar = new Sprite();
        Utils.drawRect(bar, 0, 0, W, 10, 0xff0000, .5);
        bar.y = H - bar.height;
        //addChild(bar);
        ////////////////
        timeLine = new Sprite();
        Utils.drawRect(timeLine, 0, 0, W, 10, 0xff0000, 0);
        timeLine.y = H - timeLine.height;
        //addChild(timeLine);
        ////////////////

        statusView = new TextField();
        statusView. width = 300;
        statusView. height = 200;
        //statusView.scaleX = 2;
        //statusView.scaleY = 2;
        statusView.background = true;
        statusView.backgroundColor = 0xffffff;
        //addChild(statusView);


        addEventListener(Event.ADDED_TO_STAGE, init)
    }

    private function init(event:Event):void
    {
        //load('E:\\vid.flv')
        //load('E:\\vid2.flv')
        //load('F:\\2) Collections\\zz\\Terminator 2 - Judgment Day (1991)\\Terminator 2 - Judgment Day (1991).mp4')
        //load('http://as7.cdn.asset.aparat.com/aparat-video/4dff364ab2d6a20f39e093436e3156d07632788-480p__54124.mp4')
        //setTimeout(load,2000,'http://as7.cdn.asset.aparat.com/aparat-video/4dff364ab2d6a20f39e093436e3156d07632788-144p__54124.mp4')
        //setTimeout(load,2000,'http://hw6.asset.aparat.com/aparat-video/ce89d776c603d3019c5dc44866906fa87675871-720p__23080.mp4')
        addEventListener(MouseEvent.MOUSE_DOWN, onClick);
        //setTimeout(load,2000,'http://as3.cdn.asset.aparat.com/aparat-video/0b1c951b67df2bed6c7125a0097596dd2510188-352p__48707.mp4')
        //load('E:\\slice1.flv')
    }

    public function load(file:String = null, play:Boolean = false)
    {
        if(file == null)
        {
            if(path)
                file = path;
            else
                return;
        }

        clearTimeout(loadTimeOut);

        lastMsg = '';
        status = 'Start Load';

        ns.close();
        ns.dispose();

        currentFile = file;

        timeToSeek = -1;
        //toPercent = -1;
        _duration = 0;
        bytesLoaded = 0;
        bytesTotal = 0;
        currentTime = 0;
        _bufferFull = false;
        paused = false;
        connected = false;
        loadComplete = false;
        _isPlaying = false;


        status = 'connecting...';

        trace('LOAD Video', file)

        showLoading();
        bar.scaleX = 0;
        buffer.scaleX = 0;
        starting();
        ns.play(file);
        if(!play)
            ns.pause();
        else
            ns.resume();

        ns.soundTransform = videoSound;

    }

    private function starting():void
    {
        addEventListener(Event.ENTER_FRAME,ef);
        addEventListener(MouseEvent.MOUSE_DOWN, onClick);
        ns.addEventListener(NetStatusEvent.NET_STATUS, myStatusHandler);

    }

    private function stopping():void
    {
        removeEventListener(Event.ENTER_FRAME,ef);
        removeEventListener(MouseEvent.MOUSE_DOWN, onClick);
        ns.removeEventListener(NetStatusEvent.NET_STATUS, myStatusHandler);

    }

    private function ef(event:Event):void
    {
        if(!connected)
        {
            if(ns.bytesLoaded)
            {
                connected = true;
                status = 'connected'
            }
            else
            {
                return;
            }
        }


        //get total bytes
        if(bytesTotal != ns.bytesTotal)
        {
            bytesTotal = ns.bytesTotal;
            status = 'total ' + bytesTotal;
            ////trace('Total:', bytesTotal);
        }


        //get loaded bytes
        if(bytesLoaded != ns.bytesLoaded)
        {
            bytesLoaded = ns.bytesLoaded;

            if(bytesLoaded == 0)
                buffer.scaleX = 0;
            else
                buffer.scaleX = bytesLoaded / bytesTotal;

            if(!loadComplete)
            {
                if(bytesLoaded / bytesTotal >= .98)
                {
                    loadComplete = true;
                    status = 'loading Complete';
                    dispatchEvent(new Event('loaded'));
                }
            }
        }


        //get current time
        if(currentTime != ns.time)
        {
            currentTime = ns.time;

            if(currentTime == 0)
                bar.scaleX = 0;
            else
                bar.scaleX = currentTime / duration;
        }
    }

    private function set status(message:String):void
    {
        ////trace(message);
        if(message == null)
            lastMsg = message = '';
        else if(message != '')
            lastMsg = message + '\n' + lastMsg;
        else if(isPlaying)
            lastMsg = 'Playing' + '\n' + lastMsg;
        else
            lastMsg = 'Stopped' + '\n' + lastMsg;

        if(isPlaying)
            message = 'Playing' + '\n-------------\n' + lastMsg;
        else
            message = 'Stopped' + '\n-------------\n' + lastMsg;

        statusView.text = message;
    }

    private function myStatusHandler(e:NetStatusEvent):void
    {
        volume = _volume;

        switch(e.info.code)
        {
                //Connecting
            case "NetStream.Play.StreamNotFound":
                status = 'StreamNotFound';
                ErrorLoading();

                break;

            case "NetStream.Play.FileStructureInvalid":
                status = 'FileStructureInvalid';
                ErrorLoading();
                break;

            case "NetStream.Play.Start":
                status = 'Loading Data...';
                StartDownloading();
                break;

                //BUFFER
            case "NetStream.Buffer.Full":
                changeBufferFull(true);

                if(!paused)
                    playingStatus(true);

                break;

            case "NetStream.Buffer.Empty":
                changeBufferFull(false);
                if(!paused)
                    playingStatus(false, .3);
                break;

            case "NetStream.Buffer.Flush":
                //trace();
                if(!loadComplete)
                {
                    if(currentTime)
                    {
                        if(isPlaying)
                            pause();
                        toPercent = currentTime/duration;
                    }

                    ErrorLoading();
                }
                break;

                //Seek
            case "NetStream.SeekStart.Notify":
                ////trace(SEEK_START);
                changeBufferFull(false, .3);
                playingStatus(false, .3);

                break;

            case "NetStream.Seek.Notify":
                break;

            case "NetStream.Seek.Complete":
                ////trace();
                break;

            case "NetStream.load.Start":
                //trace();
                break;


            case "NetStream.Seek.InvalidTime":
                //trace();
                break;

            case "NetStream.Play.Stop":
                if(loadComplete)
                {
                    status = 'Finish';
                    dispatchEvent(new Event('finish'))
                }
                break;

            case "NetStream.Pause.Notify":
                break;

            case "NetStream.Unpause.Notify":
                break;

            default:
                Trace();
                break;
        }

        function Trace()
        {
            //trace(e.info.code)
        }

        function ErrorLoading():void
        {
            //trace();
            loadTimeOut = setTimeout(load,1000,currentFile);
        }

        function StartDownloading():void
        {
            ////trace('Ready to play after buffer full')
        }

    }

    private function changeBufferFull(val:Boolean, time:Number=0):void
    {
        clearTimeout(bfrTimeout);
        bfrTimeout = setTimeout(func, time*1000, val);
        function func(val:Boolean)
        {
            bufferFull = val;
        }
    }

    private function playingStatus(value:Boolean, seconds:Number = 0):void
    {
        clearTimeout(plyTimeout);
        plyTimeout = setTimeout(False, seconds*1000, value);
        function False(value):void
        {
            isPlaying = value;
        }
    }


    private function onClick(e:MouseEvent):void
    {
        return;

        if(e.target == timeLine)
            setPercent(timeLine.mouseX / (timeLine.width/timeLine.scaleX));
        else if(e.target == statusView)
        {
            status = '-------------';
            //trace('-------------');
        }
        else
            pausePlay(e)
    }





    private function hideLoading(time:Number = .3)
    {
        trace('NO LOIADING');
        TweenLite.to(loading, time, {alpha:0, onComplete:a});
        status = 'hideLoading';

        function a()
        {
            trace('removeTweens')
            TweenMax.killTweensOf(loading);
        }
    }

    private function showLoading(time:Number = .3)
    {
        trace('SHOW LOIADING');
        if(!bufferFull && ! loadComplete)
        {
            TweenLite.to(loading, time, {alpha:1});
            TweenMax.to(loading, 5, {rotation:loading.rotation+360, ease:Linear.easeNone, repeat:999});
            status = 'showLoading';
        }
    }

    public function setPercent(p:Number):void
    {
        if(p<0)
            p = 0;
        else if(p>1)
            p = 1;

        ////trace('percent', int(p*100));
        if(duration)
        {
            toPercent = -1;
            setTime(Math.floor(p * duration));
        }
        else
            toPercent = p;
    }

    private function setTime(time:Number):void
    {
        //trace('SEEK:', time);
        ns.seek(time);
        timeToSeek = -1;
        resume()
    }


    public function set volume(val:int):void
    {
        trace('change video volume', val/100);
        _volume = val;
        videoSound.volume = val/100;
        ns.soundTransform = videoSound;
    }


    private function onMetaData(newMeta:Object):void
    {

        ////trace('meta data ....................');

        if(duration != 0)
        {
            ////trace('re duration' , duration == newMeta.duration);
        }
        else
        {
            //trace('duration',newMeta.duration);
            duration = newMeta.duration;
            status = 'duration ' + duration;
            ////trace(newMeta.width, newMeta.height);
            //video.width = newMeta.width;
            //video.width = newMeta.height;
            ////trace('//////////////////////////////////');
            //Utils.traceObject(newMeta);
            ////trace('//////////////////////////////////');
        }

        //Utils.traceObject(newMeta);

        dispatchEvent(new Event('duration'));

        ////trace('..............................');

    }


    ///////////////


    public function resume(event:MouseEvent=null):void
    {
        if(bufferFull)
            playingStatus(true);

        paused = false;
        ns.resume();
        ns.soundTransform = videoSound;

        //trace('resume',ns.time)
    }
    public function pause(event:MouseEvent=null):void
    {
        playingStatus(false);
        paused = true;
        ns.pause();
    }
    private function Stop(event:MouseEvent=null):void
    {
        pause();
        setTime(0);
    }

    private function pausePlay(event:MouseEvent):void
    {
        if(paused)
            resume();
        else
            pause();
    }

    private function get isPlaying():Boolean
    {
        return _isPlaying;
    }

    private function set isPlaying(value:Boolean):void
    {
        if(_isPlaying == value)
            return;

        _isPlaying = value;
        status = ''
    }

    private function get duration():Number
    {
        return _duration;
    }

    private function set duration(value:Number):void
    {
        _duration = value;
        if(toPercent != -1)
            setPercent(toPercent);
    }

    private function get toPercent():Number
    {
        return _toPercent;
    }

    private function set toPercent(value:Number):void
    {
        // //trace('toPercent', value);
        _toPercent = value;
    }

    private function get bufferFull():Boolean
    {
        return _bufferFull;
    }

    private function set bufferFull(value:Boolean):void
    {
        if(_bufferFull == value)
            return;

        _bufferFull = value;

        if(value)
            status = 'Buffer Full';
        else
            status = 'Buffer Empty';

        if(value)
        {
            hideLoading();
            dispatchEvent(new Event('bufferFull'));
        }
        else
            showLoading();

    }

    public function reset():void
    {
        setPercent(0);
        resume();
    }

    public function replay():void
    {
        setPercent(0);
        resume();
    }

    public function stop():void
    {
        setTime(0);
        pause();
    }

    public function toggle():void
    {
        ns.togglePause();
    }

    public function stopLoad():void
    {
        ns.close();
        ns.dispose();
    }

    public function get loaded():Boolean
    {
        return loadComplete;
    }

    public function get seconds():Number
    {
        return ns.time;
    }

    public function get loadPercent():Number
    {
        return ns.bytesLoaded/ns.bytesTotal;
    }

    public function play(percent:Number = 0):void
    {
        setPercent(percent);
        resume();
    }
}
}
