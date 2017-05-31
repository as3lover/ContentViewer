package {
	//Morteza Khodadadi 1391/4/29
import flash.display.Sprite;
import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.media.SoundLoaderContext;

	public class soundPlayer extends Sprite
	{
        private var _sound:Sound;
        private var _channel:SoundChannel;
        private var _transform:SoundTransform;
        private var _position:Number;
		private const buffer:int = 10;
		private var _playing:Boolean;
		private var _loaded:Boolean = false;

		public function soundPlayer()
		{
			// constructor code
			_transform= new SoundTransform();
			_transform.volume = 2;
			_sound = new Sound();
			_channel = new SoundChannel();
		}

		/////////////// Load File
		public function load(file:String)
		{
            stop();
            Main.loading.text = 'Loading Sound...';
            addEventListener(Event.ENTER_FRAME, ef);
			_loaded = false;
            _channel.removeEventListener(Event.SOUND_COMPLETE,finished);
			_sound = null;
			_sound = new Sound();
			_sound.load(new URLRequest(file), new SoundLoaderContext(buffer * 1000));
		}

        private function ef(event:Event):void
        {
            var p:Number = 0;
			if(_sound.bytesTotal)
					p = _sound.bytesLoaded / _sound.bytesTotal;

			Main.loading.percent = p;

            if(p == 1)
            {
                removeEventListener(Event.ENTER_FRAME, ef);
				_loaded = true;
                resume();
            }

        }

		private function finished(e:Event)
		{
			dispatchEvent(new Event('finish'));
		}

		/////////////// Pause / Play
		public function pausePlay():void
		{
			if (_playing)
			{
				pause();
			}
			else
			{
                resume()
			}

		}
		
		public function pause():void
		{
			if (_playing)
			{
				_position = _channel.position;
				_channel.stop();
                _playing = false;
			}
		}
        public function resume():void
        {
            if (!_playing)
            {
                _channel = _sound.play(_position);
                _channel.soundTransform = _transform
                _playing = true;
            }
        }

        public function play(seconds:Number):void
        {
			stop();
			_position = seconds * 1000;
            resume();
        }
		

		/////////////// Stop
		public function stop()
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
			_playing = false;
		}

		public function reset():void
		{
			stop();
			_loaded = false;
		}

		/////////////// setTimePercent
		public function set percent(percent:Number):void
		{
			time = percent * _sound.length / 1000;
		}
		
		/////////////// setTimeSecond
		public function set time(second:Number):void
		{
			if(!_loaded)
			{
				_position = second * 1000;
				return;
			}
			_channel.stop();
			_channel = _sound.play(second*1000);
			_channel.soundTransform = _transform
			_playing = true;
		}

		/////////////// getTime
		public function get timeString():String
		{
			return timeFormat(_channel.position);
		}
		
		public function get time():Number
		{
			if(_playing)
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
            if(_loaded)
                return timeFormat(_sound.length);
            else
                return "Loading";
        }

		/////////////// getPercent
		public function get percent():Number
		{
			if(_loaded)
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
    }

}