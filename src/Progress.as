/**
 * Created by Morteza on 5/28/2017.
 */
package
{

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

import src2.Utils;

public class Progress extends Sprite
{
    private var _bar:Sprite;
    private var _text:TextField;
    private var _f:TextFormat;
    private var main:ContentViewer;
    private var _textString:String = '';

    public function Progress(Main:ContentViewer)
    {
        main = Main;

        hide();

        scaleX = scaleY = 1.5;

        x = main.board.x + main.board.width / 2;
        y = main.board.y + main.board.height / 2;

        Utils.drawRect(this, -50, -20, 100, 40, 0x000000);
        Utils.drawRect(this, -40, 2, 80, 4, 0x333333);

        _bar = new Sprite();
        addChild(_bar);
        _bar.x = -40;
        _bar.y = 2;
        Utils.drawRect(_bar, 0, 0, 80, 4, 0xffffff);

        _text = new TextField();
        _text.x = -50;
        _text.y = -20 + 2;
        _text.width = 100;
        _text.selectable = false;
        addChild(_text);

        _f = new TextFormat();
        _f.color = 0xffffff;
        _f.font = 'Tahoma';
        _f.size = 7;
        _f.align = 'center';
    }

    private function hide():void
    {
        visible = false;
    }

    public function set percent(p:Number):void
    {
        if(p == 1)
            hide();
        else
        {
            _bar.scaleX = p;
            visible = true;
            _text.text = _textString + String(int(p*100)) + ' %';
            _text.setTextFormat(_f);
        }
    }

    public function set text(text:String):void
    {
        _textString = text + ' ';
    }
}
}
