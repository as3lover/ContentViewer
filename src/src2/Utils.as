/**
 * Created by Morteza on 4/4/2017.
 */
package src2
{
import com.greensock.TweenLite;
import com.greensock.TweenMax;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;


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

    public static function drawRect(object:Object, x:int, y:int, width:int, height:int, color:int = 0x333333, lineWidth:Number = 0, lineColor:uint = 0x0):void
    {
        if(lineWidth)
            object.graphics.lineStyle(lineWidth, lineColor);
        if(color == -1)
            object.graphics.endFill();
        else
            object.graphics.beginFill(color);
        object.graphics.drawRect(x, y, width, height);
        object.graphics.endFill();
    }

    public static function removeItemAtIndex(list:Array, index:int):void
    {
        list.splice(index, 1);
    }

    public static function removeObjectFromArray(list:Array, item:Object):Boolean
    {
        if(!list)
            return false;

        var length:int = list.length
        for (var i: int = 0; i < length; i++)
        {
            if (list[i] == item)
            {
                removeItemAtIndex(list, i)
                return true;
            }
        }

        return false;
    }

    public static function toast(obj:DisplayObject, showDuration:Number = .3, fixDuration:Number = 1, hideDuration:Number = .75):void
    {
        TweenLite.killTweensOf(obj);

        if(obj.visible == false)
        {
            obj.alpha = 0;
            obj.visible = true;
        }

        TweenLite.to(obj, showDuration, {alpha:1, onComplete:t});

        function t():void
        {
            TweenLite.to(obj, hideDuration, {delay:fixDuration, alpha:0, onComplete:v});
        }

        function v():void
        {
            obj.visible = false;
        }
    }

    public static function zoomToast(obj:DisplayObject, duration:Number = .5):void
    {
        if(obj.visible)
                return;

        TweenLite.killTweensOf(obj);
        TweenMax.killTweensOf(obj);

        obj.alpha = 0;
        obj.visible = true;
        obj.scaleX = obj.scaleY = .5;

        TweenLite.to(obj, duration, {scaleX:1.5, scaleY:1.5, onComplete:v});

        function v():void
        {
            obj.visible = false;
        }

        TweenMax.to(obj, duration/3, {alpha:.85, onComplete:t});
        function t():void
        {
            TweenMax.to(obj, duration/3, {delay:duration/3, alpha:0});
        }
    }

    public static function traceObject(obj:Object, t:String =''):void
    {
        for(var i:String in obj)
        {
            if(obj[i] is Number || obj[i] is String || obj[i] is int || obj[i] is uint || obj[i] is Boolean)
            {
                trace(t,i,obj[i])
            }
            else if(obj[i] is Array)
            {
                trace(t,i,'Array:')
                traceArray(obj[i], t+'\t');
            }
            else
            {
                trace(t,i);
                traceObject(obj[i], t+'\t')
            }
        }
    }

    public static function traceArray(list:Array, t:String=''):void
    {
        for(var i:int=0; i<list.length; i++)
        {
            if(list[i] is Array)
            {
                trace(t,i,'Array:');
                traceArray(list[i], t+'\t');
            }
            else if(list[i] is Number || list[i] is String || list[i] is int || list[i] is uint || list[i] is Boolean)
            {
                trace(t, i, list[i]);
            }
            else
            {
                trace(t,'Object:');
                traceObject(list[i], t+'\t')
            }
        }
    }

    public static function sortArrayByField(list:Array, field:String):void
    {
        var len:int = list.length;
        for(var i:int=0; i<len-1; i++)
        {
            for(var j:int=len-1; j>i; j--)
            {
                if(list[j][field] < list[j-1][field])
                    Utils.swap(list, j, j-1);
            }
        }
    }

    public static function swap(list:Array, i:int, j:int):void
    {
        var temp:Object = list[i];
        list[i] = list[j];
        list[j] = temp
    }

    public static function copyArray(list:Array):Array
    {
        if(list)
            return [].concat(list);
        else
            return [];
    }

    public static function shuffle(list:Array):Array
    {
        list.sort(randomize);
        return list;
    }

    private static function randomize (a:*,b:*):int
    {
        return (Math.random() > .5 ) ? 1 : -1;
    }

    public static function objectToBitmap(obj:DisplayObject, width:int=-1, height:int=-1):Bitmap
    {
        if(width == -1)
                width = obj.width;
        if(height == -1)
                height = obj.height;

        var bitmapData:BitmapData = new BitmapData(width, height, true, 0x00000000);
        bitmapData.draw(obj);
        return new Bitmap(bitmapData);
    }
}
}