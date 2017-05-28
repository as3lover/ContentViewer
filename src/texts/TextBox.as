/**
 * Created by Morteza on 4/19/2017.
 */
package texts
{
import fl.text.TLFTextField;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flashx.textLayout.edit.EditManager;

import flashx.textLayout.formats.Direction;

import src2.Fonts;

import src2.Utils;

public class TextBox extends Sprite
{
    private var _box:TLFTextField;
    private var _fmt:TextFormat;

    private var i1:int = -1;
    private var i2:int = -1;

    public function TextBox()
    {
        _fmt = new TextFormat();
        _box = new TLFTextField ;

        _fmt.letterSpacing = -0;
        //fmt.lineSpacing = 19;
        _fmt.leading = 0;  //فاصله بین خطوط
        _fmt.leftMargin = 0;
        _fmt.align = TextFormatAlign.RIGHT; //راست چین
        //fmt.align = "justify";
        //fmt.align = "right";
        size = 12;

        _box.defaultTextFormat = _fmt;
        _box.border = true;
        _box.wordWrap = true;
        _box.multiline = true;
        _box.embedFonts = true;
        _box.condenseWhite = true;
        _box.selectable = false;
        padding();
        //_box.autoSize = TextFieldAutoSize.RIGHT;
        _box.cacheAsBitmap = true;
        _box.direction = Direction.RTL;
        font = Fonts.YEKAN;

        addChild(_box);

        _box.addEventListener(MouseEvent.MOUSE_UP, changeSelection);
        _box.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, true);
        _box.addEventListener(Event.CHANGE, onChange);
    }

    private function onKeyDown(e:KeyboardEvent):void
    {
        if(e.keyCode == 32 && e.ctrlKey)
        {
            e.stopImmediatePropagation();
            var index:int = _box.caretIndex;
            _box.text = _box.text.substring(0, index) + String.fromCharCode(8204)  + _box.text.substring(index);
            setFocus(index+1,index+1);
            _box.wordWrap = true;
        }
    }

    private function onChange(event:Event):void
    {
        if(box.text.indexOf(String.fromCharCode(8204,32)) != -1)
        {
            _box.removeEventListener(Event.CHANGE, onChange);
            var index:int = _box.caretIndex;
            _box.text = _box.text.replace(String.fromCharCode(8204,32), String.fromCharCode(8204));
            setFocus(index-1,index-1);
            _box.wordWrap = true;
            _box.addEventListener(Event.CHANGE, onChange);
        }

        if(box.text.indexOf(String.fromCharCode(172)) != -1)
        {
            _box.removeEventListener(Event.CHANGE, onChange);
            var index:int = _box.caretIndex;
            while(box.text.indexOf(String.fromCharCode(172)) != -1)
            {
                _box.text = _box.text.replace(String.fromCharCode(172), String.fromCharCode(8204));
            }
            setFocus(index,index);
            _box.wordWrap = true;
            _box.addEventListener(Event.CHANGE, onChange);
        }
    }

    private function changeSelection(e:MouseEvent):void
    {
        var a:int = _box.selectionBeginIndex;
        var b:int = _box.selectionEndIndex;
        if(i1 != a || i2 != b)
        {
            i1 = a;
            i2 = b;
        }
    }

    private function padding():void
    {
        _box.paddingBottom = 10;
        _box.paddingTop = 10;
        _box.paddingLeft = 10;
        _box.paddingRight = 10;
    }

    public function setFormat(format:TextFormat=null):void
    {
        var newFormat:TextFormat = _fmt;
        if(format)
                newFormat = format;

        _box.defaultTextFormat = newFormat;
        _box.setTextFormat(newFormat);
        _box.wordWrap = true;
        padding();
    }

    public function get text():String
    {
        return _box.text;
    }

    public function set text(value:String):void
    {
        _box.text = value;
    }

    public function set color(value:uint):void
    {
        _fmt.color = value;
        setFormat();
    }

    public function set font(value:String):void
    {
        _fmt.font = value;
        setFormat();
    }

    public function set size(value:uint):void
    {
        _fmt.size = value;
        setFormat();
    }

    public function set align(textFormatAlign:String):void
    {
        _fmt.align = textFormatAlign;
        setFormat();
    }

    public function set selectable(value:Boolean):void
    {
        _box.selectable = value;
    }

    public function set editable(value:Boolean):void
    {
        if(value)
            _box.type = TextFieldType.INPUT;
        else
            _box.type = TextFieldType.DYNAMIC;
    }

    public function set background(value:int):void
    {
        _box.backgroundColor = value;
    }

    public override function set width(value:Number):void
    {
        _box.width = value;
    }

    public override function get width():Number
    {
        return _box.width;
    }

    public override function set height(value:Number):void
    {
        _box.height = value;
    }

    public function set numberMode(value:Boolean):void
    {
        if(value)
        {
            _box.direction = Direction.LTR;
            align = TextFormatAlign.LEFT;
        }
        else
        {
            _box.direction = Direction.RTL;
            align = TextFormatAlign.RIGHT;
        }
    }

    public function get bitmap():Bitmap
    {
        return Utils.textBoxToBitmap(_box);
    }

    public function getBitmap(quality:Number):Bitmap
    {
        return Utils.textBoxToBitmap(_box, quality)
    }

    public function get box():TLFTextField
    {
        return _box;
    }

    public function get format():TextFormat
    {
        return _fmt;
    }

    public function set format(format:TextFormat):void
    {
        setFormat(format);
    }

    public function setFocus(i1:int, i2:int):void
    {
        if(i1 < 0)
            i1 = 0;

        if(i2 < 0)
            i2 = 0;

        if(i1 > _box.length)
            i1 = _box.length;

        if(i2 > _box.length)
            i2 = _box.length;

        if(i1 > i2)
        {
            var t:int = i1;
            i1 = i2;
            i2 = t;
        }

        _box.textFlow.interactionManager = new EditManager();
        try
        {
            _box.textFlow.interactionManager.selectRange(i1, i2);
        }
        catch (e){}
        _box.textFlow.interactionManager.setFocus();
    }

    public function setDefaultFormat(prop:String, value:Object):void
    {
        _fmt[prop] = value;
    }
}
}
