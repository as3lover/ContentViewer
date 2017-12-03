/**
 * Created by Morteza on 12/3/2017.
 */
package media
{
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import src2.Utils;

import videoPlayerPackage.VideoObject;

public class VideoPlayerMulti extends Sprite implements MediaPlayer
{
    private var _main:ContentViewer;

    private const W:int = ContentViewer.W;
    private const H:int = ContentViewer.H;

    private var list:Vector.<VideoObject>;
    private var buffers:Vector.<Sprite>;
    private var step:int;
    private var last:int;
    private var len:uint;

    private var buffer:Sprite;
    private var bar:Sprite;

    private var _duration:Number;
    private var _vidNum:int;
    private var _video:VideoObject;
    private var loadingVideo:VideoObject;
    private var _loadingIndex:int;
    private var zeroPercent:Number;
    private var zeroTime:int;
    private var timeOut:uint;
    private var txt:TextField;
    private var _playing:Boolean;
    private var _loaded:Boolean;



    public function VideoPlayerMulti(Main:ContentViewer)
    {
        setMain(Main);

        bar = new Sprite();
        Utils.drawRect(bar, 0, 0, W, 5, 0xff0000, .5);
        bar.y = H - 10;
        addChild(bar);
    }

    public function load(file:String):void
    {
        stop();
        progressText = 'Loading Video';
        progressPercent = 0;
        loaded = false;


        var path = new <String>[];
        path.push('http://hw16.asset.aparat.com/aparat-video/e3e69632c6935b2fb29e88610051ebd17708949-144p__83594.mp4');
        path.push('http://hw2.asset.aparat.com/aparat-video/5472bdafdce2a3843b5bd95a435125e07713270-144p__78570.mp4');
        path.push('http://hw3.asset.aparat.com/aparat-video/d4d1600fe1ae3c0e872649ce9fc9fe007706280-144p__55335.mp4');
        path.push('http://hw4.asset.aparat.com/aparat-video/c9e5f5201a4c2c2afef8e3d7d5c0b9f37713839-144p__69039.mp4');
        path.push('http://hw14.asset.aparat.com/aparat-video/d9900b665e1a8013a29e6501ea0890b97703297-144p__63358.mp4');
        path.push('http://hw15.asset.aparat.com/aparat-video/64551a51e594961ae5e8bfa0a49d15087694009-144p__43097.mp4');
        path.push('http://hw7.asset.aparat.com/aparat-video/97e89d31fe8cdd94de212a96c6c6d7067696208-144p__68489.mp4');
        path.push('http://hw16.asset.aparat.com/aparat-video/211c1e7b60dabbe2811ef60a3292d93b7696973-144p__54884.mp4');

        start(path, 81, 80);
    }

    private function start(path:Vector.<String>, step:int, last:int):void
    {
        trace("start", step, last);
        for (var x=0; x<path.length; x++)
            trace(path[x])

        this.len = path.length;
        this.step = step;
        this.last = last;
        this.duration = (step * (len-1)) + last;
        this.list = new <VideoObject>[];
        this._vidNum = -1;
        this.video = null;
        this.loadingVideo = null;

        list = new <VideoObject>[];
        buffers = new <Sprite>[];

        for(var i:int=0; i<len; i++)
        {
            list.push(new VideoObject(path[i]));

            buffer = new Sprite();

            if(i != len-1)
                Utils.drawRect(buffer, 0, 0, (step/duration)*W, 5, 0xff9900, .5);
            else
                Utils.drawRect(buffer, 0, 0, (last/duration)*W, 5, 0xff9900, .5);

            buffer.x = ((i * step)/duration)*W;
            buffer.y = H - buffer.height;
            buffer.scaleX = 0;
            addChild(buffer);
            buffers.push(buffer);
        }

        //play(0);
        //addEventListener(Event.ENTER_FRAME, ef);
        vidNum = 0;
    }

    public function pausePlay():Boolean
    {
        if (playing)
        {
            pause();
            return false;
        }
        else
        {
            resume();
            return true;
        }
    }

    public function pause():void
    {
        if(video)
        {
            if (playing)
            {
                video.pause();
                playing = false;
            }
        }
    }

    public function resume():void
    {
            if(!playing && video)
            {
                playing = true;
                video.resume();
            }
    }

    public function play(time:Number):void
    {
        if(time>duration)
            time = duration;
        else if(time<0)
            time = 0;

        vidNum = Math.floor(time/step);

        var percent:Number;

        if(vidNum != len-1)
            percent = (time - zeroTime)/step;
        else
            percent = (time - zeroTime)/last;

        if(video)
            video.play(percent);
    }

    public function stop():void
    {
        playing = false;

        if(video)
            video.stop();
    }

    public function reset():void
    {
    }

    public function set percent(per:Number):void
    {
        play(per * duration);
    }

    public function get percent():Number
    {
        if(video)
            return zeroPercent + video.seconds / duration;
        else
            return 0
    }

    private function ef(e:Event):void
    {
        bar.scaleX = percent;

        if(video && !video.loaded && buffer)
            buffer.scaleX = video.loadPercent;

        if(video && !video.loaded)
                progressPercent = video.loadPercent;
    }

    private function get vidNum():int
    {
        return _vidNum;
    }

    private function set vidNum(value:int):void
    {
        if(_vidNum == value || value < 0)
            return;
        else if (value >= len)
            value = 0;


        removeEventListener(Event.ENTER_FRAME, ef);

        _vidNum = value;
        if(video)
        {
            removeChild(video);
            video.pause();
        }

        video = list[vidNum];
        addChildAt(video, 0);

        zeroTime = vidNum * step;
        zeroPercent = zeroTime/duration;
        setVideoLoading(vidNum);

        //addEventListener(Event.ENTER_FRAME, ef);
    }

    private function setVideoLoading(index:int):void
    {
        if(loadingVideo && loadingIndex == index)
        {
            addEventListener(Event.ENTER_FRAME, ef);

            return;
        }

        var vid:VideoObject;

        for(var i:int = index; i<len; i++)
        {
            vid = list[i];
            if(!vid.loaded)
            {
                //loadVideo(i);
                clearTimeout(timeOut);
                timeOut = setTimeout(loadVideo, 1, i);
                return;
            }
        }

        for(i = 0; i<index; i++)
        {
            vid = list[i];
            if(!vid.loaded)
            {
                //loadVideo(i);
                clearTimeout(timeOut);
                timeOut = setTimeout(loadVideo, 1, i);
                return;
            }
        }

        addEventListener(Event.ENTER_FRAME, ef);


        function loadVideo(index:int):void
        {
            if(loadingVideo)
            {
                if(loadingIndex == index)
                    return;
                else
                {
                    loadingVideo.stopLoad();
                    loadingVideo.removeEventListener('loaded', onVideoLoaded);
                    buffer.scaleX = 0;
                }
            }

            buffer = buffers[index];
            loadingVideo = list[index];
            loadingIndex = index;
            loadingVideo.addEventListener('loaded', onVideoLoaded);
            loadingVideo.load();

            addEventListener(Event.ENTER_FRAME, ef);

        }

    }

    public function get loadingIndex():int
    {
        return _loadingIndex;
    }

    public function set loadingIndex(value:int):void
    {
        _loadingIndex = value;
    }

    public function get video():VideoObject
    {
        return _video;
    }

    public function set video(vid:VideoObject):void
    {
        if(_video == vid)
            return;

        if(_video)
            _video.removeEventListener('finish', finished);

        _video = vid;
        _video.addEventListener('finish', finished);
    }

    private function finished(e:Event):void
    {
        if (vidNum >= len)
        {
            video.stop();
            dispatchEvent(new Event('finish'));
        }
        else
        {
            vidNum++;
            video.play(0);
        }
    }

    public function get duration():Number
    {
        return _duration;
    }

    public function set duration(value:Number):void
    {
        _duration = value;
    }

    private function onVideoLoaded(event:Event):void
    {
        if(video == loadingVideo)
        {
            progressPercent = 1;

            loaded = true;
            startAnimation();
            resume();
        }

        loadingVideo.removeEventListener('loaded', onVideoLoaded);
        loadingVideo = null;
        buffer.scaleX = 1;
        buffer = null;
        var i:int = loadingIndex+1;
        loadingIndex = -1;
        setVideoLoading(i);
    }

    public function set volume(volume:int):void
    {
    }

    public function get volume():int
    {
        return 0;
    }

    public function volumeUp():void
    {
        volume += 5;
    }

    public function volumeDown():void
    {
        volume -= 5;
    }

    public function set time(seconds:Number):void
    {
        percent = seconds/duration;
    }

    public function get time():Number
    {
        return percent * duration;
    }

    public function get total():Number
    {
        return 0;
    }

    public function set loaded(loaded:Boolean):void
    {
        _loaded = loaded;
        if(loaded)
            dispatchEvent(new Event('loaded'))
    }

    public function get loaded():Boolean
    {
        return _loaded;
    }

    public function set playing(value:Boolean):void
    {
        _playing = value;
    }

    public function get playing():Boolean
    {
        return _playing;
    }

    public function setMain(Main:ContentViewer):void
    {
        _main = Main;
    }

    public function set progressText(txt:String):void
    {
        _main.progress.text = txt;
    }

    public function set progressPercent(p:Number):void
    {
    }

    public function startAnimation():void
    {
        _main.animation.start();
    }

    public function showVolume(vol:Number):void
    {
        _main.ShowVolume(vol);
    }
}
}
