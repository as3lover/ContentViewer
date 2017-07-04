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
    
    private static const complete:Event = new Event(Event.COMPLETE);
    private static const IMAGE:String = 'image';
    private static const TEXT:String = 'text';
    private var _typeEffect:Boolean;
    private var _startProps:Object;
    private static const distance:int = 100;

    private var _mask:TextMask;
    private var _bitmap:Bitmap;
    private var _lines:int;
    public var _number:int;
    private var main:ContentViewer;
    private var _showPercent:Number;
    private var _hidePercent:Number;

    public function Item(obj:Object, Main:ContentViewer)
    {
        main = Main;
        
        super.visible = false;
        alpha = 0;

        _time  = -100;
        _type = obj.type;
        if(_type == TEXT)
        {
            _lines = obj.lines;
            _typingEndTime = obj.typingEndTime;
            if(_typingEndTime != -1)
            {
                _mask = new TextMask();
                addChild(_mask);
            }
        }

        _fileName = main.folder + obj.fileName;

        _x = obj.x;
        _y = obj.y;
        _scaleX = obj.scaleX;
        _scaleY = obj.scaleY;
        _rotation = obj.rotation;
        _index = obj.index;
        _motion = obj.motion;
        _number = obj.number;
        if(obj.startTime == 0)obj.startTime = 0.01;
        _startTime = obj.startTime;
        _stopTime = obj.stopTime;
        _showDuration = obj.showDuration;
        _hideDuration = obj.hideDuration;

        main.board.addChild(this);

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
    }

    public function load():void
    {
        setState();

        if(parent)
        {
            try
            {
                parent.swapChildren(this, parent.getChildAt(_index));
            }
            catch (e)
            {
                if(_index >= parent.numChildren)
                    _index = parent.numChildren-1;
                else if(_index < 1)
                    _index = 1;

                parent.swapChildren(this, parent.getChildAt(_index));
            }
        }
        else
            return;

        motion = _motion;

        main.loader.loadBitmap(_fileName, setBitmap, true);
    }


    public override function set alpha(alpha:Number):void
    {
        if(super.alpha == alpha)
                return;

        super.alpha = alpha;

        if(alpha == 0)
            visible = false;
        else
            visible = true;
    }

    public override function set visible(vis:Boolean):void
    {
        if(vis == visible)
                return;

        super.visible = vis;

        if(!vis)
        {
            main.animation.remove(this);
            //trace('remove', _number);
        }
        else
        {
            main.animation.add(this);
            //trace('add', _number);

        }
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

        bitmap.x = -bitmap.width/2;
        bitmap.y = -bitmap.height/2;

        setTimeout(dispatchEvent,4,complete);
    }
    ///////////////////////////
    ///////////////////////////
    ///////////////////////////
    ///////////////////////////

    public function set time(time:Number):void
    {
        if(time == _time)
                return;

        //main.add(_number);

        _time = time;

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
        if(_showPercent == percent)
            return;

        _showPercent = percent;
        _hidePercent = -1;

        setProps(percent);
        //main.add('show ' + String(int(percent*100)) +' '+ String(int(alpha*100)) +' '+ String(visible));

    }

    private function hide(percent:Number = 1):void
    {
        //main.add('hide' + String(percent));

        if(_hidePercent == percent)
            return;

        _showPercent = -1;
        _hidePercent = percent;

        if(percent == 1)
        {
            alpha = 0;
        }
        else
        {
            setState();
            alpha = 1 - percent;
        }
    }

    private function setProps(percent:Number = 1):void
    {
        setState();

        if(percent == 1)
        {
            alpha = percent;
            mask = null;
            return;
        }

        if(_type == TEXT)
        {
            if(_typeEffect)
            {
                alpha = 1;
                showTypeEffect(percent);
                return;
            }
            else
            {
                mask = null
            }
        }

        for (var field:String in _startProps)
        {
            setProp(field, 1-percent);
        }

        alpha = percent;

    }

    private function setProp(prop:String, percent:Number):void
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

            case Consts.fade:
                break;

            default:
                trace('no motion', type);
                break;
        }
    }

    public function get startTime():Number
    {
        return _startTime;
    }

    public function get stopTime():Number
    {
        return _stopTime;
    }

    public function inTime(time:Number):Boolean
    {
        if(time < _startTime || _stopTime + _hideDuration > time)
            return false;
        else
            return true;
    }
}
}
