/**
 * Created by Morteza on 5/27/2017.
 */
package Viewer
{

import SpriteSheet.PackLoader;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
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
    private var sheets:Object;
    private var p:Sprite;
    private var allbitmaps:Object = new Object();

    public function FileLoader(Main:ContentViewer)
    {
        main = Main;
        sheets = new Object();
    }

    public function loadText(path:String, after:Function):void
    {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onLoaded);
        function onLoaded(e:Event):void
        {
            after(e.target.data);
        }

        loader.load(new URLRequest(path));
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
                var topicsList:Array = [];
                for(var str:String in obj)
                {
                    var quizObject:Object = {text:obj[str].text, time:obj[str].time};

                    if(obj[str].id)
                    {
                        quizObject.quiz = obj[str].quiz;
                        quizObject.id = obj[str].id;
                        var score:Object = Client.load('quiz_score_' + quizObject.id);
                        if(score == null)
                            quizObject.score = -1;
                        else
                            quizObject.score = score;
                    }

                    topicsList.push(quizObject);
                }

                Utils.sortArrayByField(topicsList, 'time');
                main.topics = topicsList;
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
        main.progress.text = 'Loading Contents';

        function loadItem():void
        {
            if(_stop)
                return;

            main.progress.percent = (n/list.length);
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

        if(PackLoader.exist(path))
        {
            PackLoader.load(path, onComplete)
            return;
        }

        //var time:int = getTimer();

        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedFile);

        loader.load(new URLRequest(path));
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);

        function onError(event:IOErrorEvent):void
        {
            trace('Can Not Load File:', path);
            if(!p)
            {
                p = new Sprite();
                p.graphics.beginFill(0);
                p.graphics.drawRect(0,0,100,100);
            }
            onComplete(Utils.objectToBitmap(p));
        }

        function loadedFile (event:Event):void
        {
            var bit:Bitmap = Bitmap(LoaderInfo(event.target).content);
            //trace('loadedFile', getTimer() - time);
            onComplete(bit);
        }

        function onComplete(bit:Bitmap):void
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

    public function loadSheet(_fileName:String, setBitmap:Function, b:Boolean, pos:Object, sheetNum:int, id:int):void
    {
        if(sheets['s' + String(sheetNum)])
        {
            crop(sheets['s' + String(sheetNum)]);
        }
        else if(allbitmaps['s'+String(sheetNum)+'id'+String(id)])
        {
            setBitmap(new Bitmap(allbitmaps['s'+String(sheetNum)+'id'+String(id)]));
        }
        else
        {
            loadBitmap(main.folder + String(sheetNum) + '.png', loaded)
        }

        function loaded(bit:Bitmap)
        {
            var sheet:Sprite = new Sprite();
            sheet.addChild(bit);

            var mask:Shape = new Shape();
            mask.graphics.beginFill(0);
            mask.graphics.drawRect(0,0,500,500);

            sheet.addChild(mask)

            sheet.mask = mask;

            sheets['s' + String(sheetNum)] = sheet;
            crop(sheet);
        }

        function crop(sheet:Sprite):Bitmap
        {
            sheet.mask.width = pos.w;
            sheet.mask.height = pos.h;

            Bitmap(sheet.getChildAt(0)).x = - pos.x;
            Bitmap(sheet.getChildAt(0)).y = - pos.y;

            sheet.mask = sheet.mask;

            var bit:Bitmap = Utils.objectToBitmap(sheet, pos.w, pos.h);
            ChangeBit(bit);
            bit.smoothing = true;
            allbitmaps['s'+String(sheetNum)+'id'+String(id)] = bit.bitmapData;
            setBitmap(bit);
        }
    }

    public function loadedSheet(sheetNum:int):Boolean
    {
        if(sheets['s' + String(sheetNum)])
                return true
        else
                return false;
    }
}
}
