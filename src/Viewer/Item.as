/**
 * Created by Morteza on 5/27/2017.
 */
package Viewer
{
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.setTimeout;

import items.TextMask;

import src2.Consts;

public class Item extends Sprite
{
    private var _type:String;
    private var _text:String;
    private var _formats:Array;
    private var _typingEndTime:Number;
    private var _fileName:String;

    private var _x:Number;
    private var _y:Number;
    private var _scaleX:Number;
    private var _scaleY:Number;
    private var _rotation:Number;
    private var _index:int;
    private var _motion:String;

    private var _startTime:Number;
    private var _stopTime:Number;
    private var _showDuration:Number;
    private var _hideDuration:Number;
    
    private var _time:Number;
    

    public static const QUALITY:Number = 2;
    private static const complete:Event = new Event(Event.COMPLETE);
    private static const IMAGE:String = 'image';
    private static const TEXT:String = 'text';
    private var _typeEffect:Boolean;
    private var _startProps:Object;
    private static const distance:int = 100;

    private var _mask:TextMask;
    private var _bitmap:Bitmap;
    private var _lines:int;
    private var _number:int;

    public function Item(obj:Object)
    {
        visible = false;
        _time  = -100;
        _type = obj.type;
        if(_type == TEXT)
        {
            _text = obj.text;
            _formats = obj.formats;
            _typingEndTime = obj.typingEndTime;
            if(_typingEndTime != -1)
            {
                _mask = new TextMask();
                addChild(_mask);
            }
        }
        else
        {
            _fileName = Main.folder + obj.fileName;
        }

        _x = obj.x;
        _y = obj.y;
        _scaleX = obj.scaleX;
        _scaleY = obj.scaleY;
        _rotation = obj.rotation;
        _index = obj.index;
        _motion = obj.motion;
        _number = obj.number;

        _startTime = obj.startTime;
        _stopTime = obj.stopTime;
        _showDuration = obj.showDuration;
        _hideDuration = obj.hideDuration;

        Main.board.addChild(this);
    }

    public function load():void
    {
        setState();

        if(parent)
            parent.swapChildren(this, parent.getChildAt(_index));
        else
            return;

        motion = _motion;

        if(_fileName)
        {
            dispatchEvent(complete);
            Main.loader.loadBitmap(_fileName, setBitmap, true);
        }
        else
        {
            Main.text.show(_text, after, false, _formats, false);
            /*
            if(LocalObject.exist(Main.projectPath, String(_number)+'bit'))
            {
                LocalObject.load(Main.projectPath, String(_number)+'bit',bitmapLoaded)
            }
            else
            {
                Main.text.show(_text, after, false, _formats, false);
            }
            */
        }

        function bitmapLoaded(bit:Bitmap):void
        {
            _bitmap = bit;
            LocalObject.load(Main.projectPath, String(_number)+'lines',linesLoaded)
        }

        function linesLoaded(lines):void
        {
            _lines = int(lines);
            after(_bitmap, _lines);
        }
    }


    private function after(bit:Bitmap = null, lines:int = 1):void
    {
        if(!bit)
        {
            bitmap = Main.text.getBitmaap(QUALITY);
            _lines = Main.text.lines;

            //LocalObject.save(Main.projectPath, String(_number) + 'bit', _bitmap);
            //LocalObject.save(Main.projectPath, String(_number) + 'lines', _lines);
        }
        else
        {
            bitmap = bit;
            _lines = lines;
        }



        setTimeout(dispatchEvent, 4, complete);
    }

    public override function set alpha(alpha:Number):void
    {
        super.alpha = alpha;

        if(alpha == 0)
            visible = false;
        else
            visible = true;
    }

    private function setBitmap(bit:Bitmap):void
    {
        bitmap = bit;
    }

    public function set bitmap(bitmap:Bitmap):void
    {
        _bitmap = bitmap;

        if(bitmap)
            addChild(bitmap);

        if(_type == IMAGE)
            dispatchEvent(complete);
        else
            bitmap.scaleY = bitmap.scaleX = 1.15;

        bitmap.x = -bitmap.width/2;
        bitmap.y = -bitmap.height/2;
    }
    ///////////////////////////
    ///////////////////////////
    ///////////////////////////
    ///////////////////////////

    public function set time(time:Number):void
    {
        if(time == _time)
                return;

        if(_type == TEXT)
        {
            if(_typingEndTime == -1)
            {
                _typeEffect = false;
            }
            else
            {
                _showDuration = _typingEndTime - _startTime;
                _typeEffect = true;
            }
        }

        if(time < _startTime)
        {
            hide();
        }
        else if (time < _startTime + _showDuration)
        {
            show((time - _startTime) / _showDuration);
        }
        else if (time < _stopTime)
        {
            show();
        }
        else if(time < _stopTime + _hideDuration)
        {
            hide((time -_stopTime) / _hideDuration)
        }
        else
        {
            hide();
        }
    }

    private function show(percent:Number = 1):void
    {
        setProps(percent);
    }

    private function hide(percent:Number = 1):void
    {
        if(percent == 1)
        {
            visible = false;
        }
        else
        {
            setProps();
            alpha = 1 - percent;
        }
    }

    private function setProps(percent:Number = 1):void
    {
        if(_type == TEXT)
        {
            setState();
            alpha = percent;
            showTypeEffect(percent);
            return;
        }

        if(percent == 1)
        {
            setState();
            alpha = percent;
            return;
        }

        for (var field:String in _startProps)
        {
            setProp(field, 1-percent);
        }

        alpha = percent;
    }

    function setProp(prop:String, percent:Number):void
    {
        this[prop] -= percent * (this[prop] - _startProps[prop]);
    }

    public function setState():void
    {
        rotation = _rotation;
        scaleX = _scaleX;
        scaleY = _scaleY;
        x = _x;
        y = _y;
    }

    public function showTypeEffect(percent:Number):void
    {
        if(!_typeEffect || percent == 1)
        {
            mask = null;
            return;
        }

        alpha = 1;

        if(!_mask)
        {
            _mask = new TextMask();
            addChild(_mask);
        }

        _mask.update(_bitmap.x, _bitmap.y, _bitmap.width, _bitmap.height, _lines, percent);

        mask = _mask;
    }

    public function set motion(type:String):void
    {
        if(_motion == type)
            return;

        _startProps = new Object();
        _motion = type;


        switch (type)
        {
            case Consts.upToDown:
                _startProps.y = _y - distance;
                break;

            case Consts.downToUp:
                _startProps.y = _y + distance;
                break;

            case Consts.leftToRight:
                _startProps.x = _x - distance;
                break;

            case Consts.rightToLeft:
                _startProps.x = _x + distance;
                break;

            case Consts.rightUp:
                _startProps.x = _x + distance;
                _startProps.y = _y - distance;
                break;

            case Consts.leftUp:
                _startProps.x = _x - distance;
                _startProps.y = _y - distance;
                break;

            case Consts.rightDown:
                _startProps.x = _x + distance;
                _startProps.y = _y + distance;
                break;

            case Consts.leftDown:
                _startProps.x = _x - distance;
                _startProps.y = _y + distance;
                break;

            case Consts.zoom:
                _startProps.scaleX = _scaleX / 3;
                _startProps.scaleY = _scaleY / 3;
                break;

            case Consts.rotate:
                _startProps.rotation = _rotation + 180;
                break;
        }
    }
}
}
