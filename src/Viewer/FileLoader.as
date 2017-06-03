/**
 * Created by Morteza on 5/27/2017.
 */
package Viewer
{

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.setTimeout;

import src2.Utils;

public class FileLoader
{
    private var _stop:Boolean;
    private var _loading:Boolean;
    private var _list:Array;
    private var main:ContentViewer;

    public function FileLoader(Main:ContentViewer)
    {
        main = Main;
    }


    public function load(path:String):void
    {
        _stop = false;

        main.progress.text = 'Connecting...';
        main.progress.percent = 0;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onLoaded);
        function onLoaded(e:Event):void
        {
            if(_stop)
                    return;

            afterLoad(JSON.parse(e.target.data));
        }

        loader.load(new URLRequest(path));
    }

    private function afterLoad(object:Object):void
    {
        if(_stop)
            return;

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
               main.board.color = obj as uint;
                continue;
            }

            if(i == 'back')
            {
               main.board.back = String(main.folder + obj as String);
                continue;
            }

            var item:Item = new Item(obj, main);
            list.push(item);

        }

        var n:int = 0;
        setTimeout(loadItem, 4);
        main.progress.text = 'Loading Contents...';

        function loadItem():void
        {
            if(_stop)
                return;

            main.progress.percent = n/list.length;
            if(n < list.length)
            {
                item = Item(list[n]);
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
            if(_stop)
                return;

            item.removeEventListener(Event.COMPLETE, after);
            loadItem();
        }

        function finish():void
        {
            if(_stop)
                return;

            main.animation.list = list;
            loadSound();
        }

        function loadSound():void
        {
            if(_stop)
                return;

            if(sound)
                main.sound.load(main.folder + sound);
        }

    }

    public function loadBitmap(path:String, func:Function, change:Boolean = false):void
    {
        if(_stop)
            return;

        if(_loading)
        {
            if(!_list)
                _list = new Array();
            _list.push([path,func,change]);
            return;
        }

        _loading = true;

        //var time:int = getTimer();

        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedFile);

        loader.load(new URLRequest(path));
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);

        function onError(event:IOErrorEvent):void
        {
            trace('Can Not Load File:', path);
            func(null)
        }

        function loadedFile (event:Event):void
        {
            var bit:Bitmap = Bitmap(LoaderInfo(event.target).content);
            //trace('loadedFile', getTimer() - time);
            onComplete(bit);
        }

        function onComplete(bit:Bitmap)
        {
            if(_stop)
                return;

            if(change)
            {
                ChangeBit(bit)
            }
            bit.smoothing = true;
            func(bit);
            _loading = false;

            if(_list && _list.length)
            {
                loadBitmap(_list[0][0],_list[0][1],_list[0][2]);
                Utils.removeItemAtIndex(_list, 0);
            }
        }
    }

    private function ChangeBit(bit:Bitmap):void
    {
        bit.scaleX = .5;
        bit.scaleY= .5;
        bit.x = -bit.width/2;
        bit.y = -bit.height/2;
    }

     public function stop():void
    {
        _stop = true;
    }
}
}
