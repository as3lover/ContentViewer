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

import media.VideoObject;

public class VideoPlayerMulti extends Sprite implements MediaPlayer
{
    private var _main:ContentViewer;

    private const W:int = ContentViewer.W;
    private const H:int = ContentViewer.H;

    private var list:Vector.<VideoObject>;
    private var buffers:Vector.<Sprite>;
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
    private var allVideosLen:Array;
    private var _volume:int = 100;
    private var animationStarted:Boolean = false



    public function VideoPlayerMulti(Main:ContentViewer)
    {
        setMain(Main);

        bar = new Sprite();
        Utils.drawRect(bar, 0, 0, W, 2, 0xff0000, .5);
        bar.y = H - bar.height * 2;
        bar.alpha = 0.1;
        addChild(bar);
    }

    public function load(file:String):void
    {
        stop();
        progressText = 'Loading Video';
        progressPercent = 0;
        loaded = false;
    }

    public function start(path:Vector.<String>, allVideosLen:Array):void
    {
        trace("start");

        stop();
        progressText = 'Loading Video';
        progressPercent = 0;
        loaded = false;


        for (var x=0; x<path.length; x++)
            trace(path[x])

        this.len = path.length;
        this.allVideosLen = allVideosLen;

        var d:Number = 0;
        for(var du:int=0; du<allVideosLen.length; du++)
            d += allVideosLen[du];
        this.duration = d;

        this.list = new <VideoObject>[];
        this._vidNum = -1;
        this.video = null;
        this.loadingVideo = null;

        list = new <VideoObject>[];
        buffers = new <Sprite>[];

        var sum:int = 0;

        for(var i:int=0; i<len; i++)
        {
            list.push(new VideoObject(path[i]));

            buffer = new Sprite();

            Utils.drawRect(buffer, 0, 0, (allVideosLen[i]/duration)*W, 2, 0xff9900, .5);

            buffer.alpha = 0.2;
            buffer.x = (sum/duration)*W;
            buffer.y = H - buffer.height;
            buffer.scaleX = 0;
            addChild(buffer);
            buffers.push(buffer);

            sum += allVideosLen[i];
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
        trace('video pause')
        if(video)
        {
            trace('has video')
            if (playing)
            {
                trace('playing')
                video.pause();
                playing = false;
            }
            else
            {
                trace('no playing')
                video.stop();
            }
        }
        else
            trace('no video')
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

        vidNum = timeToVidNum(time);

        var percent:Number;

        percent = (time - zeroTime)/currentDuration;

        if(video)
            video.play(percent);
    }

    private function get currentDuration():Number
    {
        return allVideosLen[vidNum];
    }

    private function timeToVidNum(time:Number):int
    {
        //return Math.floor(time/step);

        var sum:Number = 0;
        for(var i:int=0; i<allVideosLen.length; i++)
        {
            sum += allVideosLen[i];
            if(time < sum)
            {
                return i;
            }
        }

        i--;
        return i;

    }

    public function stop():void
    {
        playing = false;

        if(video)
            video.stop();
    }

    public function reset():void
    {
        stop();
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

        trace('Vid Num:', value + 1);

        removeEventListener(Event.ENTER_FRAME, ef);

        _vidNum = value;
        if(video)
        {
            removeChild(video);
            video.pause();
        }

        video = list[vidNum];
        addChildAt(video, 0);

        //zeroTime = vidNum * step;
        zeroTime = 0;
        for(var i:int=0; i<vidNum; i++)
            zeroTime += allVideosLen[i];

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

            if (loadingVideo == video)
                loadingVideo.addEventListener('bufferFull', onBufferFull);

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
        trace('set video 1', _video, vid);
        if(_video == vid)
            return;
        trace('set video 2');

        if(_video)
            _video.removeEventListener('finish', finished);

        trace('set video 3');

        _video = vid;

        trace('set video 4');


        video.addEventListener('finish', finished);
        video.volume = volume;
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

    private function onBufferFull(event:Event):void
    {
        trace('onBufferFull');
        if(loadingVideo)
            loadingVideo.removeEventListener('bufferFull', onBufferFull);

        if(vidNum == loadingIndex)
        {
            progressPercent = 1;
            loaded = true;
            startAnimation();
            resume();
        }
    }

    private function onVideoLoaded(event:Event):void
    {
        trace('onVideoLoaded');
        if(vidNum == loadingIndex)
        {
            trace('video == loadingVideo');
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
        if(volume > 100)
            volume = 100;
        else if(volume < 0)
            volume = 0;

        trace("Volume" , _volume, ' > ', volume);

        _volume = volume;
        if(video)
            video.volume = volume;

        showVolume(volume/100)
    }

    public function get volume():int
    {
        return _volume;
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
        if(!animationStarted)
            _main.animation.start();

        animationStarted = true;
    }

    public function showVolume(vol:Number):void
    {
        _main.ShowVolume(vol);
    }

    public function stopLoad():void
    {
        if(loadingVideo)
            loadingVideo.stopLoad();
    }
}
}
