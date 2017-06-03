/**
 * Created by Morteza on 4/4/2017.
 */
package src2
{


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

    public static function removeItemAtIndex(list:Array, index:int):void
    {
        list.splice(index, 1);
    }

    public static function removeObjectFromArray(list:Array, item:Object):Boolean
    {
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

}
}