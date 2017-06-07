/**
 * Created by Morteza on 5/30/2017.
 */
package
{

import flash.net.SharedObject;

public class Client
{
    private static var _obj:SharedObject;
    private static var data:Object;
    private static var address:String;

    public function Client()
    {
    }

    private static function start():void
    {
        _obj = SharedObject.getLocal('RianContentViewerTest102');
        address = ContentViewer.address;

        if(_obj.data[address])
            data = _obj.data[address];
        else
           data = _obj.data[address] = new Object();
    }

    private static function flush():void
    {
        if(!data)
                return;

        _obj.flush();
    }

    public static function save(name:String, newData:Object):void
    {
        if(!data)
            start();

        data[name] = newData;
        flush();
    }

    public static function load(name:String):Object
    {
        if(!data)
            start();

        if(!data[name])
            return null;

        return data[name];
    }

    public static function clear(name:String):void
    {
        if(!data)
            start();

        if(!data[name])
                return;

        delete data[name];
        flush()
    }

    public static function clearAll():void
    {
        if(!data)
            start();

        delete _obj.data[address];
        flush();
    }

}
}
