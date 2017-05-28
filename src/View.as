/**
 * Created by Morteza on 5/27/2017.
 */
package
{
import Viewer.Animation;
import Viewer.Board;
import Viewer.FileLoader;

import flash.display.Sprite;

import texts.TextEditor;

[SWF(width="1000", height="800", frameRate=60, backgroundColor='0x444444')]

public class View extends Sprite
{
    public static var board:Board;
    public static var folder:String;
    public static var loader:FileLoader;
    public static var text:TextEditor;
    public static var animation:Animation;


    public function View()
    {
        board = new Board();
        addChild(board);

        animation = new Animation();

        loader = new FileLoader();

        text = new TextEditor(0,0,600,337,0)

        folder = "C:\\Users\\Morteza\\Downloads\\Telegram Desktop\\BackUp\\backUp10_files\\";
        loader.load("C:\\Users\\Morteza\\Downloads\\Telegram Desktop\\BackUp\\backUp10.rian");
    }

    public static function reset():void
    {
        trace('reset')
    }
}
}
