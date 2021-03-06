﻿package {
//Morteza Khodadadi 1391/4/29

import flash.display.Sprite;
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;

import media.MediaPlayer;


public class SoundPlayer extends Sprite  implements MediaPlayer
{
    private var _sound:Sound;
    private var _position:Number;
    private const buffer:int = 10;
    private var _playing:Boolean;
    private var _loaded:Boolean = false;
    private var _main:ContentViewer;

    private static var _channel:SoundChannel;
    private static var _transform:SoundTransform;
    private static var _volume:Number = 1;

    public function SoundPlayer(Main:ContentViewer)
    {
        setMain(Main);

        // constructor code
        _transform= new SoundTransform();
        _transform.volume = _volume;
        _sound = new Sound();
        _channel = new SoundChannel();
    }

    public function setMain(Main:ContentViewer):void
    {
        _main = Main;
    }

    /////////////// Load File
    public function load(file:String):void
    {
        stop();
        progressText = 'Loading Sound';
        loaded = false;
        _channel.removeEventListener(Event.SOUND_COMPLETE,finished);
        _sound = null;
        _sound = new Sound();
        //_sound.load(new URLRequest(file), new SoundLoaderContext(buffer * 1000));
        _sound.load(new URLRequest(file));
        addEventListener(Event.ENTER_FRAME, ef);
    }

    public function set progressText(txt:String):void
    {
        _main.progress.text = txt;
    }

    private function ef(event:Event):void
    {
        var p:Number = 0;
        if(_sound.bytesTotal)
            p = _sound.bytesLoaded / _sound.bytesTotal;

        progressPercent = p;

        if(p == 1)
        {
            progressText = 'Loaded';
            removeEventListener(Event.ENTER_FRAME, ef);
            loaded = true;
            startAnimation();
            resume();
        }

    }

    public function startAnimation():void
    {
        _main.animation.start();
    }

    public function set progressPercent(p:Number):void
    {
        _main.progress.percent = p;
    }

    private function finished(e:Event):void
    {
        dispatchEvent(new Event('finish'));
    }

    /////////////// Pause / Play
    public function pausePlay():Boolean
    {
        if (playing)
        {
            pause();
            return false;
        }
        else
        {
            resume()
            return true;
        }

    }

    public function pause():void
    {
        if (playing)
        {
            _position = _channel.position;
            _channel.stop();
            playing = false;
        }
    }
    public function resume():void
    {
        if (!playing)
        {
            _channel = _sound.play(_position);
            _channel.soundTransform = _transform;
            _channel.addEventListener(Event.SOUND_COMPLETE,finished);
            playing = true;
        }
    }

    public function play(seconds:Number):void
    {
        stop();
        _position = seconds * 1000;
        resume();
    }


    /////////////// Stop
    public function stop():void
    {
        try
        {
            _channel.stop();
        }
        catch(a){}
        try
        {
            _sound.close();
        }
        catch(a){}

        _position = 0;
        playing = false;
    }

    public function reset():void
    {
        stop();
        loaded = false;
    }

    /////////////// setTimePercent
    public function set percent(percent:Number):void
    {
        time = percent * _sound.length / 1000;
    }

    /////////////// setTimeSecond
    public function set time(second:Number):void
    {
        if(second < 0)
            second = 0;
        else if(second > total)
            second = total;

        pause();
        _position = second * 1000;

        if(!loaded)
                return;

        resume();
    }
	////////////////////////
	public function set volume(volume:int):void
	{
		if(volume > 100)
				volume = 100;
		else if(volume < 0)
				volume = 0;

		_volume = volume/50;
		if(_transform)
				_transform.volume = _volume;
		if(_channel)
				_channel.soundTransform = _transform;

		showVolume(_volume/2);
	}

    public function showVolume(vol:Number):void
    {
        _main.ShowVolume(vol);
    }

	public function get volume():int
	{
		return int(_volume * 50);
	}

    public function volumeUp():void
    {
        volume += 5;
    }

    public function volumeDown():void
    {
        volume -= 5;
    }

    /////////////// getTime
    public function get timeString():String
    {
        return timeFormat(_channel.position);
    }

    public function get time():Number
    {
        if(playing)
            return _channel.position / 1000;
        else
            return _position/1000;
    }

    /////////////// getTotal
    public function get total():Number
    {
        return _sound.length / 1000;
    }

    public function get totalString():String
    {
        if(loaded)
            return timeFormat(_sound.length);
        else
            return "Loading";
    }

    /////////////// getPercent
    public function get percent():Number
    {
        if(loaded)
            return _channel.position / _sound.length;
        else
            return 0;
    }

    /////////////// timeFormat
    private function timeFormat(miliSec:Number):String
    {
        if (miliSec < 1 * 60 * 60 * 1000)
        {
            return addZero(miliSec / 1000 / 60) + " : " + addZero(miliSec / 1000 % 60);
        }
        else
        {
            return addZero(miliSec / 1000 / 60 / 60) + " : " + addZero(miliSec / 1000 % 3600)+ " : " + addZero(miliSec / 1000 % 60);
        }
    }

    /////////////// addZero
    private function addZero(num:Number):String
    {
        if ((num < 10))
        {
            return "0" + int(num);
        }
        else
        {
            return String(int(num));
        }
    }

    public function get loaded():Boolean
    {
        return _loaded;
    }

    public function set loaded(loaded:Boolean):void
    {
        _loaded = loaded;
        if(loaded)
            dispatchEvent(new Event('loaded'))
    }

    public function get playing():Boolean
    {
        return _playing;
    }

    public function set playing(value:Boolean):void
    {
        _playing = value;
    }

}

}