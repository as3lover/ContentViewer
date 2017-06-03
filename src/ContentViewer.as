/**
 * Created by Morteza on 5/27/2017.
 */
package
{
import Viewer.Animation;
import Viewer.Board;
import Viewer.FileLoader;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import net.hires.debug.Stats;

[SWF(width="600", height="337", frameRate=60, backgroundColor='0x444444')]

public class ContentViewer extends Sprite
{
    public var board:Board;
    public var folder:String;
    public var loader:FileLoader;
    public var animation:Animation;
    public var sound:SoundPlayer;
    public var progress:Progress;
    public var projectPath:String;
    private var _time:int;
    private var _old:int = 0;
    private var _new:int = 0;
    private var _textBox:TextField;


    public function ContentViewer()
    {
        setTimeout(INIT,1);
    }

    public function INIT():void
    {
        board = new Board(this);
        addChild(board);

        sound = new SoundPlayer(this);

        progress = new Progress(this);
        addChild(progress);

        animation = new Animation(this);

        loader = new FileLoader(this);

        board.addEventListener(MouseEvent.CLICK, click);

        _textBox = new TextField();
        _textBox.y = 150;
        _textBox.width = 300;
        _textBox.height = 1000;
        addChild(_textBox);

        load('D:/Projects/IdeaProjects/Template/Main/lessons/', '5');

        addChild(new Stats());

    }


    private function reset():void
    {
        trace('reset');
        board.reset();
        sound.reset();
        loader.stop();

    }
    private function click(event:MouseEvent):void
    {
        if(!loaded)
                return;

        animation.resetTimes();
        percent = mouseX/600;
    }

    ///////////////////////////////
    public function load(dir:String, file:String)
    {
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
        sound.percent = p;
    }

    public function stop():void
    {
        trace('stop');

        sound.stop();
    }

    public function replay():void
    {
        trace('replay');

        sound.stop();
        sound.play(0);
    }

    public function pause():void
    {
        trace('pause');

        if(loaded)
        {
            trace('sound.pause()')
            sound.pause();
        }
        else
            reset();
    }

    public function resume():void
    {
        trace('resume');
        sound.resume();
    }
    ///////////////////////////////

    public override function set visible(v:Boolean):void
    {
        trace('Main visible', v);
        super.visible = v;
    }

    public function setTime():void
    {
        _time = getTimer();
    }

    public function traceTime(s:String):void
    {
        if(s == 'new Type')
            _new += getTimer() - _time;
        else
            _old += getTimer() - _time;
        //trace('old',_old,'new',_new);
        _textBox.text = 'old ' + _old + ' new ' + _new // + ' ' + String(animation._show.length)
    }

    public function add(s):void
    {
        if(s == null)
            _textBox.text = String(Math.random());
        else
            _textBox.text = _textBox.text + '\n' + String(s);
    }
}
}
