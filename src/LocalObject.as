/**
 * Created by Morteza on 5/30/2017.
 */
package
{
import com.adobe.images.PNGEncoder;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.net.SharedObject;
import flash.utils.ByteArray;
import flash.utils.getTimer;

public class LocalObject
{
    private static var _obj:SharedObject;
    private static var _bytes:uint = 0;
    private static var _totalBytes:uint = 0;

    public function LocalObject()
    {
    }

    public static function start():void
    {
        _obj = SharedObject.getLocal('ContentDesigner101');
        _obj.clear();
    }

    public static function save(name:String, property:String, data:Object):void
    {
        if(!_obj)
            start();
        if(!_obj.data[name])
        {
            _obj.data[name] = new Object();
        }

        if(!_obj.data[name][property])
        {
            _obj.data[name][property] = new Object();
        }

        if(data is Bitmap)
        {
            _obj.data[name][property].type = 'bitmap';
            _obj.data[name][property].bytes = bitmapToBinary(data as Bitmap);

            _bytes = ByteArray(_obj.data[name][property].bytes).length;
            _totalBytes += _bytes;
            trace('size', int(_bytes/1024), 'KB', 'Total', Number((_totalBytes/1024)/1024), 'MB');
        }
        else
        {
            _obj.data[name][property].type = 'noBitmap';
            _obj.data[name][property].data = data;
        }

        _obj.flush();
    }

    public static function load(name:String, property:String, afterLoad:Function):Boolean
    {
        if(!_obj)
            start();

        if(!exist(name,property))
        {
            afterLoad(null);
            return false;
        }

        if(_obj.data[name][property].type && _obj.data[name][property].type == 'bitmap')
            binaryToBitmap(_obj.data[name][property].bytes, afterLoad);
        else
            afterLoad( _obj.data[name][property].data);

        return true;
    }

    public static function exist(name:String, prop:String):Boolean
    {
        if(!_obj)
            start();

        return(_obj.data[name] && _obj.data[name][prop]);
    }

    private static function binaryToBitmap(bytes:ByteArray, afterLoad:Function):void
    {
        var time:int = getTimer();

        var bit:Bitmap;
        var bmpData:BitmapData;
        var loader:Loader = new Loader();
        loader.loadBytes(bytes);

        loader.contentLoaderInfo.addEventListener(Event.INIT, loaded);
        function loaded(e:Event):void
        {
            var loaderInfo:LoaderInfo = LoaderInfo(e.target);
            bmpData = new BitmapData(loaderInfo.width, loaderInfo.height, true, 0);
            bmpData.draw(loaderInfo.loader);
            bit = new Bitmap(bmpData);
            bit.smoothing = true;
            afterLoad(bit);

            trace('binaryToBitmap', getTimer() - time)
        }

    }

    private static function bitmapToBinary(img:Bitmap):ByteArray
    {
        var time:int = getTimer();

        var x:int = img.x;
        var y:int = img.y;
        var scaleX:int = img.scaleX;
        var scaleY:int = img.scaleY;
        var rotation:int = img.rotation;

        img.x = img.y = img.rotation = 0;
        img.scaleX = img.scaleY = 1;

        var data:BitmapData = new BitmapData(img.width, img.height, true, 0);
        data.draw(img);

        img.x = x;
        img.y = y;
        img.scaleX = scaleX;
        img.scaleY = scaleY;
        img.rotation = rotation;

        trace('bitmapToBinary', getTimer() - time);
        return PNGEncoder.encode(data);
        /*
        var time:int = getTimer();

        var x:int = img.x;
        var y:int = img.y;
        var scaleX:int = img.scaleX;
        var scaleY:int = img.scaleY;
        var rotation:int = img.rotation;

        img.x = img.y = img.rotation = 0;
        img.scaleX = img.scaleY = 1;

        var data:BitmapData = new BitmapData(img.width, img.height, true, 0);
        data.draw(img);
        var encoder:JPGEncoder = new JPGEncoder();
        //var bytes:ByteArray = encoder.encode(data);

        img.x = x;
        img.y = y;
        img.scaleX = scaleX;
        img.scaleY = scaleY;
        img.rotation = rotation;

        trace('bitmapToBinary', getTimer() - time);
        return encoder.encode(data);
        */

    }
}
}
