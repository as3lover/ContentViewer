/**
 * Created by Morteza on 4/19/2017.
 */
package texts {
import fl.text.TLFTextField;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextFormat;


import src2.Button;
import src2.Utils;

public class TextEditor extends Sprite
{
    private var _textBox:TextBox;
    private var _function:Function;
    protected var cancel:Button;
    private const formatProps:Array = ['font', 'color', 'size', 'letterSpacing', 'leading', 'bold'];
    private var _fmt:TextFormat;
    private var _format:Array;
    private const props:int = formatProps.length;


    public function TextEditor(x:int, y:int, width:int, height:int, color:uint=0xcccccc)
    {
        visible = false;
        this.x = x;
        this.y = y;
        Utils.drawRect(this, 0, 0, width, height, color);

        _textBox = new TextBox();
        _textBox.x = 10;
        _textBox.y = 10;
        _textBox.width = width - 80;
        _textBox.height = height - 20;
        _textBox.text = 'متن نمونه';
        _textBox.editable = true;
        _textBox.color = 0x000000;
        _textBox.background = 0xbbbbbb
        addChild(_textBox);


        var ok:Button = new Button('ثبت', 0, 0, 40);
        ok.addEventListener(MouseEvent.CLICK, onOk);
        ok.x = _textBox.x + _textBox.width + 10;
        ok.y = 10;
        addChild(ok)

        cancel = new Button('لغو', 0, 0, 40);
        cancel.addEventListener(MouseEvent.CLICK, onCancel)
        cancel.x = ok.x;
        cancel.y = ok.y + ok.height + 5;
        addChild(cancel)
    }

    public function onCancel(event:MouseEvent):void
    {
        hide();
        if(!_format)
            _function('');
    }

    private function onOk(event:MouseEvent):void
    {
        if(_function != null)
                _function(_textBox.text);
        hide();
    }

    public function register()
    {
        onOk(null);
    }

    public function hide():void
    {
        visible = false;
    }

    public function show(text:String = '', func:Function = null, numberMode:Boolean = false, formats:Array = null, toEdit:Boolean = true):void
    {
        _textBox.text = text;
        _format = formats;

        if(formats)
        {
            this.formats = formats;
        }
        else
            _textBox.numberMode = numberMode;

        visible = toEdit;
        _function = func;
        if(toEdit == false)
        {
            func();
            return;
        }

        _textBox.setFocus(_textBox.box.text.length,  _textBox.box.text.length);
    }



    public function get bitmap():Bitmap
    {
        return _textBox.bitmap;
    }

    public function set text(text:String):void
    {
        _textBox.text = text;
    }

    public function set color(color:uint):void
    {
        _textBox.color = color;
    }

    public function getBitmaap(quality:Number):Bitmap
    {
        return _textBox.getBitmap(quality);
    }

    public function set formats(list:Array):void
    {
        var len:int = list.length;
        var format:TextFormat = new TextFormat();

        for(var i:int=0; i<len; i++)
        {
            for(var p:String in list[i].format)
            {
                format[p] =  list[i].format[p];
            }

            if(list[i].index1 < 0)
            {
                list[i].index1 = 0;
            }

            if(list[i].index2 > _textBox.box.length)
            {
                list[i].index2 = _textBox.box.length;
            }

            _textBox.box.setTextFormat(format, list[i].index1, list[i].index2);
        }
    }



    public function get formats():Array
    {
        var formats:Array = new Array();
        var f1:TextFormat = new TextFormat();
        var f2:TextFormat
        var _box:TLFTextField = _textBox.box;
        var length:int = _box.length;

        for(var i:int=0; i<length; i++)
        {
            f2 = _box.getTextFormat(i, i+1);

            if(formatCompare(f1,f2))
            {
                formats[formats.length-1].index2 = i+1;
            }
            else
            {
                var obj:Object = new Object();
                obj.size = f2.size;
                obj.font = f2.font;
                obj.color = f2.color;
                obj.leading = f2.leading;
                obj.letterSpacing = f2.letterSpacing;
                obj.bold = f2.bold;
                formats.push({format:obj, index1:i, index2:i})
            }
            f1 = f2
        }

        return formats;
    }


    private function formatCompare(f1:TextFormat, f2:TextFormat):Boolean
    {
        for(var i:int=0; i<props; i++)
        {
            if(f1[formatProps[i]] != f2[formatProps[i]])
                return false
        }

        return true;
    }

    public function  getFormats(i1:int=-1,i2:int=-1):Array
    {
        var formats:Array = new Array();
        var f1:TextFormat = new TextFormat();
        var f2:TextFormat;
        var box:TLFTextField = _textBox.box;
        var i:int;
        var length:int;

        if(i1 == -1)
        {
            i = i1;
            length = i2;
        }
        else
        {
            length = box.length;
            i = 0
        }

        for(i; i<length; i++)
        {
            f2 = box.getTextFormat(i, i+1);

            if(formatEquals(f1,f2))
            {
                formats[formats.length-1].index2 = i+1;
            }
            else
            {
                var obj:Object = new Object();
                obj.size = f2.size;
                obj.font = f2.font;
                obj.color = f2.color;
                obj.leading = f2.leading;
                obj.letterSpacing = f2.letterSpacing;
                obj.bold = f2.bold;
                formats.push({format:obj, index1:i, index2:i})
            }
            f1 = f2
        }

        return formats;
    }

    public function  setFormatss(i:int,i2:int, prop:String, value:Object,box:TLFTextField):void
    {
        trace('setFormats', prop, i,i2);
        var formats:Array=new Array();
        var lastFormat:Object = {};
        var f1:TextFormat = new TextFormat();
        var f2:TextFormat;


        for(i; i<i2; i++)
        {
            f2 = box.getTextFormat(i, i+1);

            if(formatEquals(f1,f2))
            {
                trace(true)
                lastFormat.index2 = i+1;
            }
            else
            {
                trace(false);
                if(lastFormat.format)
                    formats.push(lastFormat);

                f2[prop] = value;
                lastFormat = {format:f2, index1:i, index2:i};
            }
            f1 = f2
        }

        for(i=0; i<formats.length; i++)
        {
            box.setTextFormat(formats[i].format,  formats[i].index1,  formats[i].index2);
        }
    }

    private function formatEquals(f1:TextFormat, f2:TextFormat):Boolean
    {
        for(var i:int=0; i<props; i++)
        {
            if(f1[formatProps[i]] != f2[formatProps[i]])
            {
                trace(formatProps[i],f1[formatProps[i]] , f2[formatProps[i]])
                return false
            }
        }
        return true;
    }


    public function getSize():Number
    {
        return getProp('size') as Number;
    }

    public function getFont():String
    {
        return getProp('font') as String;
    }

    public function getLeading():Number
    {
        return getProp('leading') as Number;
    }

    public function getSpace():Number
    {
        return getProp('letterSpacing') as Number;
    }

    public function getColor():uint
    {
        return getProp('color') as uint;
    }

    public function getBold():Boolean
    {
        return getProp('bold') as Boolean;
    }

    public function getProp(prop:String):Object
    {
        var format:TextFormat;

        var i1:int = _textBox.box.selectionBeginIndex;
        var i2:int = _textBox.box.selectionEndIndex;

        if(i1 == i2)
        {
            if(_textBox.box.length > 0)
            {
                i1 = _textBox.box.caretIndex;
                if(i1 < _textBox.box.length - 2)
                {
                    i2 = i1+1;
                }
                else if (i1 > 0)
                {
                    i2 = i1;
                    i1--;
                }
                else
                {
                    i1 = 0;
                    i2 = 1;
                }
            }
            else
            {
                i1 = 0;
                i2 = 0;
            }
        }
        else if(i1+1 < i2)
        {
            i1++;
        }

        if(i2>_textBox.box.length)
            i2 = _textBox.box.length;

        format = _textBox.box.getTextFormat(i1, i2);

        return format[prop];
    }

    public function get fmt():TextFormat
    {
        return _textBox.box.defaultTextFormat;
    }



    public function setColor(color:uint):void
    {
        setTextFormat('color', color);
    }

    public function setLeading(value:Number):void
    {
        setTextFormat('leading', value);
    }

    public function setSpace(value:Number):void
    {
        setTextFormat('letterSpacing', value);
    }

    public function setSize(value:Number):void
    {
        setTextFormat('size', value);
    }

    public function setFont(font:String):void
    {
        setTextFormat('font', font);
    }

    public function setBold(bold:Boolean):void
    {
        setTextFormat('bold', bold);
    }

    private function setTextFormat(prop:String, value:Object):void
    {
        _textBox.setDefaultFormat(prop, value);
        trace('setTextFormat',prop,value)
        var _box:TLFTextField = _textBox.box;
        var i1:int = _box.selectionBeginIndex;
        var i2:int = _box.selectionEndIndex;

        if(i1 == i2)
        {
            i1 = 0;
            i2 = _box.length;
        }

        var list:Array = getSomeFormat(i1,i2);
        trace('list.length',list.length)
        for (var i:int=0; i<list.length; i++)
        {
            list[i].format[prop] = value;
        }
        setSomeFormat = list;
        _box.wordWrap = true;
    }

    private function getSomeFormat(i:int, length:int):Array
    {
        trace('getSomeFormat', i, length);

        var formats:Array = new Array();
        var f1:TextFormat = new TextFormat();
        var f2:TextFormat
        var _box:TLFTextField = _textBox.box;

        for(i; i<length; i++)
        {
            f2 = _box.getTextFormat(i, i+1);

            if(formatCompare(f1,f2))
            {
                formats[formats.length-1].index2 = i+1;
            }
            else
            {
                var obj:Object = new Object();
                obj.size = f2.size;
                obj.font = f2.font;
                obj.color = f2.color;
                obj.leading = f2.leading;
                obj.letterSpacing = f2.letterSpacing;
                obj.bold = f2.bold;
                formats.push({format:obj, index1:i, index2:i+1})
            }
            f1 = f2
        }

        return formats;
    }


    private function set setSomeFormat(list:Array):void
    {
        trace('set format')
        var len:int = list.length;
        var format:TextFormat = new TextFormat();

        for(var i:int=0; i<len; i++)
        {
            for(var p:String in list[i].format)
            {
                format[p] =  list[i].format[p];
            }

            if(list[i].index1 < 0)
            {
                list[i].index1 = 0;
            }

            if(list[i].index2 > _textBox.box.length)
            {
                list[i].index2 = _textBox.box.length;
            }

            trace('set text format', list[i].index1, list[i].index2)

            _textBox.box.setTextFormat(format, list[i].index1, list[i].index2);
        }
    }

    public override function set visible (value:Boolean):void
    {
        super.visible = value;
    }


    public function get lines():int
    {
        return _textBox.box.numLines;
    }

}
}




