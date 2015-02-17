
package components;

import luxe.Component;
import luxe.Vector;


class Mover extends Component
{

    var direction:Vector;

    override function init():Void
    {
        direction = new Vector();
        Luxe.events.listen('move', function(e:Vector){
            moveIt();
        });
    } // init

    override function onfixedupdate(rate:Float):Void
    {

    } // onfixedupdate

    function moveIt():Void
    {
        entity.pos.add(e)
    }

}
