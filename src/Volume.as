/**
 * Created by Morteza on 6/4/2017.
 */
package
{
import flash.display.Sprite;

import src2.Utils;

public class Volume extends Sprite
{
    private var _bar:Sprite;

    public function Volume()
    {
        visible = false;

        var w:int = 80;
        var h:int = 40;
        var n:int = 5;

        x = ContentViewer.W - 5 - w;
        y = ContentViewer.H - 5 - h;

        var back:Sprite = new Sprite();
        back.alpha = .3;
        addChild(back);

        var Mask:Sprite = new Sprite();
        addChild(Mask);

        var wt:Number = w/n;
        for(var i:int = 0; i<n ; i++)
        {
            Utils.drawRect(back, i * wt, h, wt*.8, -h*((n-i)/n), 0xffffff);
            Utils.drawRect(Mask, i * wt, h, wt*.8, -h*((n-i)/n));
        }

        _bar = new Sprite();
        _bar.x = w;
        Utils.drawRect(_bar, 0, h, w, -h, 0xffffff);
        _bar.mask = Mask;
        addChild(_bar);
    }

    public function show(percent:Number):void
    {
        _bar.scaleX = -percent;
        Utils.toast(this);
    }
}
}
