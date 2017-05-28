/**
 * Created by Morteza on 4/10/2017.
 */
package texts
{
import fl.text.TLFTextField;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class Text extends Sprite
{



    public static function sprite(text:String, color:uint=0x000000, font:String="B Yekan", size:int=16 ,width:int= 260, height:int=35):Sprite
    {
        var fmt:TextFormat = new TextFormat();
        fmt.color = color; // رنگ فونت
        //fmt.color = 0x532108; // رنگ فونت
        fmt.font = font; // نوع فونت
        fmt.letterSpacing = -0;
        fmt.size = size * 3;
        //fmt.lineSpacing = 19;
        //fmt.leading = 0;  //فاصله بین خطوط
        fmt.leftMargin = 0;
        fmt.align = TextFormatAlign.LEFT; //راست چین
        //fmt.align = "justify";
        //fmt.align = "right";

        var txt:TLFTextField = new TLFTextField ;
        txt.defaultTextFormat = fmt;
        //txt.border = true;
        txt.width = 1000;
        txt.height = 1000;
        txt.wordWrap = true;
        txt.multiline = true;
        txt.embedFonts = true;
        //txt.backgroundColor = 0xcccccc;
        txt.condenseWhite = true;
        txt.selectable = false;

        txt.autoSize = TextFieldAutoSize.RIGHT;
        txt.text = text;
        txt.cacheAsBitmap = true;

        var sprite:Sprite = new Sprite();
        sprite.addChild(txt)
        if(txt.textWidth <1 || txt.textHeight < 1)
        {
            txt.text = 'متن پیش فرض'
            trace('ERRORR متنی وجود ندارد')
        }
        var snapshot:BitmapData = new BitmapData(txt.textWidth, txt.textHeight, true, 0x00000000);
        snapshot.draw(sprite, new Matrix());
        var bit:Bitmap = new Bitmap(snapshot);
        bit.smoothing = true;

        sprite.removeChild(txt);
        sprite.addChild(bit);

        if(bit.width > width)
        {
            bit.width = width;
            bit.scaleY = bit.scaleX;
        }

        if(bit.height > height)
        {
            bit.height = height;
            bit.scaleX = bit.scaleY;
        }

        if(bit.width < width)
            bit.x = (width - bit.width)/2;
        else if(bit.height < height)
            bit.y = (height - bit.height)/2;

        return sprite;
    }

    public static function TextBox(text:String, color:uint=0x000000, font:String="B Yekan", size:int=16 ,width:int= 260, height:int=35):void
    {
        var fmt:TextFormat = new TextFormat();
        fmt.color = color; // رنگ فونت
        fmt.font = font; // نوع فونت
        fmt.letterSpacing = -0;
        fmt.size = size;
        //fmt.lineSpacing = 19;
        //fmt.leading = 0;  //فاصله بین خطوط
        fmt.leftMargin = 0;
        fmt.align = TextFormatAlign.LEFT; //راست چین
        //fmt.align = "justify";
        //fmt.align = "right";

        var txt:TLFTextField = new TLFTextField ;
        txt.defaultTextFormat = fmt;
        //txt.border = true;
        txt.width = 1000;
        txt.height = 1000;
        txt.wordWrap = true;
        txt.multiline = true;
        txt.embedFonts = true;
        //txt.backgroundColor = 0xcccccc;
        txt.condenseWhite = true;
        txt.selectable = false;

        txt.autoSize = TextFieldAutoSize.RIGHT;
        txt.text = text;
        txt.cacheAsBitmap = true;
    }
}
}
