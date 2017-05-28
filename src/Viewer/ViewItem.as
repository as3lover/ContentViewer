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

public class ViewItem extends Sprite
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

    public function ViewItem(obj:Object)
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
            _fileName = View.folder + obj.fileName;
        }

        _x = obj.x;
        _y = obj.y;
        _scaleX = obj.scaleX;
        _scaleY = obj.scaleY;
        _rotation = obj.rotation;
        _index = obj.index - 1;
        _motion = obj.motion;

        _startTime = obj.startTime;
        _stopTime = obj.stopTime;
        _showDuration = obj.showDuration;
        _hideDuration = obj.hideDuration;

        View.board.addChild(this);
    }

    public function load():void
    {
        parent.swapChildren(this, parent.getChildAt(_index));
        motion = _motion;
        show(1);
        if(_fileName)
        {
            dispatchEvent(complete);
            View.loader.LoadBitmap(_fileName, this);
        }
        else
        {
            trace(_text);
            View.text.show(_text, after, false, _formats, false);
        }
    }

    private function after():void
    {
        bitmap = View.text.getBitmaap(QUALITY);
        _lines = View.text.lines;
        setTimeout(dispatchEvent, 1, complete);
    }

    public override function set alpha(alpha:Number):void
    {
        super.alpha = alpha;

        if(alpha == 0)
            visible = false;
        else
            visible = true;
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
        alpha = percent;

        if(_type == TEXT)
        {
            setState();
            showTypeEffect(percent);
            return;
        }

        if(percent == 1)
        {
            setState();
            return;
        }

        for (var field:String in _startProps)
        {
            setProp(field, 1-percent);
        }
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
