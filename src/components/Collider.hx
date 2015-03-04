
package components;

import luxe.Component;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Circle;
import luxe.collision.shapes.Polygon;
import luxe.collision.ShapeDrawerLuxe;
import luxe.collision.CollisionData;
import luxe.Color;
import luxe.collision.Collision;
import luxe.Entity;
import luxe.Rectangle;
import luxe.Vector;

class Collider extends Component
{

    public var shape:Shape;

    // Remember init options
    var offset:Vector;

    var drawer:ShapeDrawerLuxe;

    override public function new(_options:ColliderOptions)
    {
        super(_options);

        offset = new Vector(_options.hitbox.x, _options.hitbox.y);

        shape = Polygon.rectangle(
            _options.hitbox.x,
            _options.hitbox.y,
            _options.hitbox.w,
            _options.hitbox.h
        );
    }

    override function init():Void
    {
        drawer = new ShapeDrawerLuxe();

    } // init


    override function update(rate:Float):Void
    {
        shape.position = entity.pos;
        // shape.position.x += offset.x;
        // shape.position.y += offset.y;


        drawer.drawPolygon( cast shape, new Color().rgb(0xff0000), true );
    }

}

typedef ColliderOptions = {
    > luxe.options.ComponentOptions,

    var hitbox:Rectangle;
}
