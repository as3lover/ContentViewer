/**
 * Created by Morteza on 5/27/2017.
 */
package Viewer
{
import avmplus.finish;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.getTimer;
import flash.utils.setTimeout;

public class FileLoader
{

    public function FileLoader()
    {
    }

    public function load(path:String):void
    {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onLoaded);
        function onLoaded(e:Event):void
        {
            afterLoad(JSON.parse(e.target.data));
        }

        loader.load(new URLRequest(path));
    }

    private function afterLoad(object:Object):void
    {
        View.reset();

        var obj:Object;
        var number:int;
        var sound:String;
        var list:Array = new Array();
        for(var i:String in object)
        {
            obj = object[i];

            if(i == 'time')
            {
                continue;
            }

            if(i == 'number')
            {
                continue;
            }

            if(i == 'sound')
            {
                sound = obj as String;
                continue;
            }

            if(i == 'topics')
            {
                trace('topic', obj);
                continue;
            }

            if(i == 'snapList')
            {
                continue;
            }

            if(i == 'color')
            {
                trace('color', obj as uint);
                continue;
            }

            var item:ViewItem = new ViewItem(obj);
            list.push(item);
        }


        var n:int = 0;
        setTimeout(load, 1);
        var timer:Number = getTimer();
        var timer2:Number;

        function load():void
        {
            if(n < list.length)
            {
                item = ViewItem(list[n]);
                n++;
                item.addEventListener(Event.COMPLETE, after);
                item.load();
            }
            else
            {
                finish();
            }
        }

        function after(event:Event):void
        {
            timer2 = getTimer();
            trace(timer2 - timer);
            timer = timer2;

            item.removeEventListener(Event.COMPLETE, after);
            load();
        }

        function finish():void
        {
            View.animation.list = list;
            View.animation.play(0);
        }


        /*
        trace('loaded time', time)
        Main.loadedTime = time;
        Main.animationControl.loadItems();
        Main.animationControl.number = number;
        Main.changed = false;
        if(sound)
        {
            if (sound)
            {
                if(sound == 'file.voice')
                {
                    trace('new Sound:', FileManager.itemsFolder + '/' + sound);
                    sound = FileManager.itemsFolder + '/' + sound;
                }

                Main.timeLine.sound = sound;
            }
        }
        */
    }

    public function LoadBitmap(path:String, item:ViewItem):void
    {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);

        loader.load(new URLRequest(path));
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);

        function onError(event:IOErrorEvent):void
        {
            trace('Can Not Load File:', path);
            item.bitmap = null;
        }

        function onComplete (event:Event):void
        {
            var bit:Bitmap = Bitmap(LoaderInfo(event.target).content);
            bit.scaleX = .5;
            bit.scaleY= .5;
            bit.x = -bit.width/2;
            bit.y = -bit.height/2;
            bit.smoothing = true;
            item.bitmap = bit;
        }
    }
}
}
