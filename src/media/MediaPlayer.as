/**
 * Created by Morteza on 12/2/2017.
 */
package media
{
public interface MediaPlayer
{
    function load(file:String):void

    function pausePlay():Boolean
    function pause():void
    function resume():void
    function play(seconds:Number):void
    function stop():void
    function reset():void

    function set percent(percent:Number):void
    function get percent():Number

    function set volume(volume:int):void
    function get volume():int

    function volumeUp():void
    function volumeDown():void

    function set time(seconds:Number):void
    function get time():Number

    function get total():Number

    function set loaded(loaded:Boolean):void
    function get loaded():Boolean

    function set playing(value:Boolean):void
    function get playing():Boolean

    function setMain(Main:ContentViewer):void
    function set progressText(txt:String):void
    function set progressPercent(p:Number):void
    function startAnimation():void
    function showVolume(vol:Number):void
}
}
