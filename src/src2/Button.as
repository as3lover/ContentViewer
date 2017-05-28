/**
 * Created by Morteza on 4/5/2017.
 */
package src2
{
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import texts.Text;


public class Button extends Sprite
{
    private var _textColor:uint;
    private var _func:Function;
    public function Button(text:String = '.', x:int = 0, y:int = 2, width:int = 20, height:int = 20, textColor:uint = 0xeeeeee, backColor:uint = 0x333333)
    {
        super();
        buttonMode = true;
        Utils.drawRect(this, x, y, width, height, backColor);
        _textColor = textColor;
        this.text = text;
    }

    public function setProps(obj:Object):void
    {
        for (var i:String in obj)
        {
            switch(i)
            {
                case 'text':
                    text = obj[i];
                    break;

                case 'handler':
                        handler = obj[i];
                    break;
            }
        }
    }

    public function set handler(func:Function):void
    {
        _func = func;
        addEventListener(MouseEvent.CLICK, onClick);
    }

    private function onClick(event:MouseEvent):void
    {
        if(buttonMode || alpha == 1)
            _func();
    }

    public function set text(text:String):void
    {
        removeChildren();
        addChild(Text.sprite(text,_textColor,"B Yekan", 12, width, height));
    }

    public function disable():void
    {
        buttonMode = false;
        alpha = .75;
    }

    public function enable():void
    {
        buttonMode = true;
        alpha = 1;
    }
}
}
