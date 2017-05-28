/**
 * Created by Morteza on 5/27/2017.
 */
package Viewer
{
import flash.display.Sprite;

public class Board extends Sprite
{
    public function Board()
    {
        x = 20;
        y = 20;
        graphics.beginFill(0xff0000);
        graphics.drawRect(0,0, 600, 337);
        graphics.endFill();
        width = 900;
        scaleY = scaleX;
    }
}
}
