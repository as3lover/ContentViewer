/**
 * Created by Morteza on 5/2/2017.
 */
package items
{
import flash.display.Sprite;

import src2.Utils;

public class TextMask extends Sprite
{
    public function TextMask()
    {
        addLine();
        alpha = 0;
    }

    private function addLine():void
    {
        var s:Sprite = new Sprite();
        Utils.drawRect(s, 0, 0, 200, 40);
        addChild(s)
    }

    public function update(x:int,y:int,w:int,h:int,lines:int, percent:Number):void
    {
        while(numChildren < lines)
            addLine();
        
        while (numChildren> lines)
            removeChildAt(0);
        
        this.x = x;
        this.y = y;
        
        var s:Sprite;
        var p:Number;
        for(var i:int=0; i<lines; i++)
        {
            s = getChildAt(i) as Sprite;
            p = 1/lines;
            if(percent <= p * i)
            {
                s.width = 0;
            }
            else
            {
                s.y = i*(h/lines);
                s.height = h/lines;

                if( percent >= (i+1)*p)
                {
                    s.x = 0;
                    s.width = w;
                }
                else
                {
                    p = percent - p*i;
                    p = p * lines;
                    s.width = p * w;
                    s.x = w - s.width;
                }
            }
        }
    }
}
}
