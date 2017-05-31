/**
 * Created by Morteza on 4/4/2017.
 */
package src2
{


import fl.text.TLFTextField;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;


public class Utils
{
    public function Utils()
    {
    }

    //convert time format to Number data type
    public static function timeToSec(t:Object):Number
    {
        if (t is Number)
            return Number(t);
        else if (t is String)
        {
            var parts:Array=new Array(3);
            parts=t.split(":",3);
            if (parts[1]==undefined)
                return Number(parts[0]);
            else if (parts[2]==undefined)
                return Number(parts[0])*60+Number(parts[1]);
            else
                return Number(parts[0])*3600+Number(parts[1])*60+Number(parts[2]);
        }
        else
        {
            trace("time type is wrong!");
            return 0;
        }
    }


    /////////////////////// milli Sec to String
    public static function timeFormat(milliSeconds:Number):String
    {
        var t:int = milliSeconds;
        if (t < 1 * 60 * 60 * 1000)
        {
            return addZero(t / 1000 / 60) + " : " + addZero(t / 1000 % 60);
        }
        else
        {
            return String(int(t / 1000 / 60 / 60)) + " : " + addZero(t / 1000 % 3600 / 60)+ " : " + addZero(t / 1000 % 60);
        }
    }

    /////////////// addZero
    public static function addZero(num:Number):String
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

    public static function drawRect(object:Object, x:int, y:int, width:int, height:int, color:int = 0x333333):void
    {
        object.graphics.beginFill(color);
        object.graphics.drawRect(x, y, width, height);
        object.graphics.endFill();
    }

    public static function textBoxToBitmap(textBox, quality:Number = 3):Bitmap
    {
        if(textBox.textWidth < 1 || textBox.textHeight < 1)
        {
            textBox.text = 'متن پیش فرض';
            trace('ERRORR متنی وجود ندارد')
        }

        var x:Number = textBox.x;
        var y:Number = textBox.y;
        var border:Boolean = textBox.border;
        var scale:Number = textBox.scaleX;
        var parent:Object;
        var index:int;
        if(textBox.parent)
        {
            parent = textBox.parent;
            index = parent.getChildIndex(textBox);
        }
        textBox.scaleX = textBox.scaleY = scale * quality;
        textBox.y = 0;
        textBox.x = - (textBox.width - textBox.textWidth * quality);
        textBox.border = false;

        var padding:int = 50;
        textBox.x += padding;

        var sprite:Sprite = new Sprite();
        sprite.addChild(textBox);

        var snapshot:BitmapData = new BitmapData(padding + textBox.textWidth * quality, padding + textBox.textHeight * quality, true, 0x00000000);
        snapshot.draw(sprite, new Matrix());

        //var bit:Bitmap = new Bitmap(snapshot);
        var bit:Bitmap = new Bitmap(trimAlpha(snapshot));
        bit.smoothing = true;

        textBox.scaleX = textBox.scaleY = scale;
        textBox.border = border;
        textBox.x = x;
        textBox.y = y;
        if(parent)
            parent.addChildAt(textBox, index);

        bit.scaleX = bit.scaleY = 1/quality;
        return bit;
    }

    public static function trimAlpha(source:BitmapData):BitmapData
    {
        var notAlphaBounds:Rectangle = source.getColorBoundsRect(0xFF000000, 0x00000000, false);
        var trimed:BitmapData = new BitmapData(notAlphaBounds.width, notAlphaBounds.height, true, 0x00000000);
        trimed.copyPixels(source, notAlphaBounds, new Point());
        return trimed;
    }


    public static function removeItemAtIndex(list:Array, index:int):void
    {
        list.splice(index, 1);
    }

    ///////////////////
    public static function StringToBitmap(text:String, color:uint=0xffffff, font:String="B Yekan", size:int=14 ,width:int= 260, height:int=35):Bitmap
    {
        var fmt:TextFormat = new TextFormat();
        fmt.color = color;
        fmt.font = font;
        fmt.size = size * 3;
        fmt.leftMargin = 0;
        fmt.align = TextFormatAlign.LEFT;

        var txt:TLFTextField = new TLFTextField() ;
        txt.defaultTextFormat = fmt;
        txt.width = 1000;
        txt.height = 1000;
        txt.wordWrap = true;
        txt.multiline = true;
        txt.embedFonts = true;
        txt.condenseWhite = true;
        txt.autoSize = TextFieldAutoSize.RIGHT;
        txt.text = text;
        txt.cacheAsBitmap = true;

        var sprite:Sprite = new Sprite();
        sprite.addChild(txt);
        var snapshot:BitmapData = new BitmapData(txt.textWidth, txt.textHeight, true, 0x00000000);
        snapshot.draw(sprite, new Matrix());
        var bit:Bitmap = new Bitmap(snapshot);
        bit.smoothing = true;

        sprite.removeChild(txt);
        sprite.addChild(bit);

        bit.scaleX = bit.scaleY = 1/3;

        return bit;
    }

}
}