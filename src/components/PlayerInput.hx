
package components;

import luxe.Component;
import luxe.Input;

class PlayerInput extends Component
{

    public var left:Bool    = false;
    public var right:Bool   = false;
    public var up:Bool      = false;
    public var down:Bool    = false;

    override function init():Void
    {
        Luxe.input.bind_key('left', Key.left);
        Luxe.input.bind_key('right', Key.right);
        Luxe.input.bind_key('up', Key.up);
        Luxe.input.bind_key('down', Key.down);
    }

    override function update(dt:Float):Void
    {
        updateKeys();
    }


    function updateKeys():Void
    {
        left  = Luxe.input.inputdown('left');
        right = Luxe.input.inputdown('right');
        down  = Luxe.input.inputdown('down');
        up    = Luxe.input.inputdown('up');

        if(left && right)
        {
            left = right = false;
        }
        if(up && down)
        {
            up = down = false;
        }
    }


}
