/**
 * Created by Morteza on 5/27/2017.
 */
package
{
import Viewer.Animation;
import Viewer.Board;
import Viewer.FileLoader;
import Viewer.Keyboard;
import Viewer.TimeLine;
import Viewer.assets;

import flash.display.Bitmap;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.getTimer;
import flash.utils.setTimeout;

//import net.hires.debug.Stats;

[SWF(width="600", height="360", frameRate=60, backgroundColor='0x444444')]

public class ContentViewer extends Sprite
{
    public var board:Board;
    public var folder:String;
    public var loader:FileLoader;
    public var animation:Animation;
    public var sound:SoundPlayer;
    public var timeLine:TimeLine;
    public var progress:Progress;
    public var projectPath:String;
    public var keyboard:Keyboard;

    public var actived:Boolean;

    private var _time:int;
    private var _old:int = 0;
    private var _new:int = 0;
    private var _textBox:TextField;

    public var playIcon:Sprite;
    public var pauseIcon:Sprite;


    private static var _volume:Volume;

    public static const W:int = 600;
    public static const H:int = 337;


    public function ContentViewer()
    {
        trace('new: ContentViewer')
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

        progress = new Progress(this);
        addChild(progress);

        timeLine = new TimeLine(this, 0, 337+5, 600, 13);
        addChild(timeLine);

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


        //board.addEventListener(MouseEvent.CLICK, click);

        _textBox = new TextField();
        _textBox.y = 150;
        _textBox.width = 300;
        _textBox.height = H - _textBox.y;
        addChild(_textBox);

        load('D:/Projects/IdeaProjects/Template/Main/lessons/', '5');

        //addChild(new Stats());

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
        //percent = mouseX/W;
    }

    ///////////////////////////////
    public function load(dir:String, file:String):void
    {
        actived = true;
        projectPath = dir + file + '.rian';
        reset();
        this.folder = dir + file + '/';
        loader.load(projectPath);
    }

    public function get duration():Number
    {
        return sound.total;
    }

    public function get percent():Number
    {
        return sound.percent;
    }

    public function get time():String
    {
        return sound.timeString;
    }

    public function get totalTime():String
    {
        return sound.totalString;
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

        animation.resetTimes();
        sound.percent = p;
    }

    public function setTime(time:Number):void
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

    public function replay():void
    {
        //trace('replay');
        actived = true;

        animation.resetTimes();
        sound.stop();
        sound.play(0);
    }

    public function pause():void
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
    ///////////////////////////////

    public override function set visible(v:Boolean):void
    {
        //trace('Main visible', v);
        super.visible = v;
    }

    public function setTimer():void
    {
        _time = getTimer();
    }

    public function traceTime(s:String):void
    {
        if(s == 'new Type')
            _new += getTimer() - _time;
        else
            _old += getTimer() - _time;
        ////trace('old',_old,'new',_new);
        _textBox.text = 'old ' + _old + ' new ' + _new // + ' ' + String(animation._show.length)
    }

    public function add(s):void
    {
        if(s == null)
            _textBox.text = String(Math.random());
        else
            _textBox.text = _textBox.text + '\n' + String(s);
    }

    public static function ShowVolume(percent:Number):void
    {
        if(_volume)
            _volume.show(percent);
    }
}
}
