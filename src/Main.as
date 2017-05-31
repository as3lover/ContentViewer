/**
 * Created by Morteza on 5/27/2017.
 */
package
{
import Viewer.Animation;
import Viewer.Board;
import Viewer.FileLoader;

import flash.display.Bitmap;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

import src2.Utils;

import texts.TextEditor;

[SWF(width="600", height="337", frameRate=60, backgroundColor='0x444444')]

public class Main extends Sprite
{
    public static var board:Board;
    public static var folder:String;
    public static var loader:FileLoader;
    public static var text:TextEditor;
    public static var animation:Animation;
    public static var sound:soundPlayer;
    public static var loading:Loading;
    public static var projectPath:String;


    public function Main()
    {
        setTimeout(INIT,1);
    }

    public function INIT():void
    {
        /*
        Utils.drawRect(this, 100,100,100,100);
        LocalObject.start();
        loader = new FileLoader();
        //addChild(Utils.StringToBitmap('سلام'));
        var bit:Bitmap = Utils.StringToBitmap('سلام', 0xff0000);
        //addChild(bit);
        bit.x = bit.y = 0;
        bit.scaleX = bit.scaleY = 1;
        LocalObject.save('test1','1', bit);
        //bit.x = 200;
        //LocalObject.load('test1','1', comp);
        setTimeout(LocalObject.load,3000,'test1','1', comp)
        function comp(bit2:Bitmap)
        {
            addChild(bit2)
        }
        return;
        */




        /*
        var png:Bitmap = Utils.StringToBitmap('سلام');
        png.x = 200;
        addChild(png);
        LocalObject.save('test1','1', png);
        //LocalObject.load('test1','1', comp);
        setTimeout(LocalObject.load,3000,'test1','1', comp);
        function comp(bit:Bitmap)
        {
            addChild(bit)
        }
        //loader.loadBitmap('C:\\Users\\Public\\Pictures\\Sample Pictures\\e\\Tulips.jpg', func);





        loader.loadBitmap('C:\\Users\\Public\\Pictures\\Sample Pictures\\e\\Tulips.jpg', func);
        loader.loadBitmap('C:\\Users\\Public\\Pictures\\Sample Pictures\\e\\Chrysanthemum.jpg', func);
        loader.loadBitmap('C:\\Users\\Public\\Pictures\\Sample Pictures\\e\\Desert.jpg', func);
        loader.loadBitmap('C:\\Users\\Public\\Pictures\\Sample Pictures\\e\\Hydrangeas.jpg', func);
        loader.loadBitmap('C:\\Users\\Public\\Pictures\\Sample Pictures\\e\\Jellyfish.jpg', func);
        */

        /*
        function func(b:Bitmap)
        {
            if(b)
                addChild(b);
            else
                trace('no');
        }
        return
*/

        board = new Board();
        addChild(board);

        sound = new soundPlayer();

        loading = new Loading();
        addChild(loading);

        animation = new Animation();

        loader = new FileLoader();

        text = new TextEditor(0,0,600,337,0);

        board.addEventListener(MouseEvent.CLICK, click);

        load('D:\\Projects\\IdeaProjects\\ContentDesigner\\Template\\Main\\lessons\\', '1');

        return;
        //folder = "https://goftar.000webhostapp.com/test/project_files/";
        //folder = "C:\\Users\\Morteza\\Downloads\\Telegram Desktop\\BackUp\\backUp10_files\\";
        //loader.load("https://goftar.000webhostapp.com/test/project.rian");
        //loader.load("C:\\Users\\Morteza\\Downloads\\Telegram Desktop\\BackUp\\backUp10.rian");
        //loader.load("https://cdn.abasmanesh.com/uploads/video/1396/campain-ravanshenasi-servat3-1/abasmanesh-soal-ravanshenasi-servat-3-mp4.mp4");

    }

    private static function reset():void
    {
        trace('reset');
        board.reset();
        sound.reset();
        loader.stop();

    }
    private function click(event:MouseEvent):void
    {
        percent = mouseX/600;
    }

    ///////////////////////////////
    public function load(folder:String, file:String)
    {
        projectPath = folder + file + '.rian';
        reset();
        Main.folder = folder + file + '\\';
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
        trace('visible', v);
        super.visible = v;
    }

}
}
