
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

class Collider extends Component
{

    public var shape:Shape;

    var drawer:ShapeDrawerLuxe;

    override public function new(_options:ColliderOptions)
    {
        super(_options);

        shape = Polygon.rectangle(
            _options.hitbox.x /2,
            _options.hitbox.y /2,
            _options.hitbox.w /2,
            _options.hitbox.h /2
        );
    }

    override function init():Void
    {
        drawer = new ShapeDrawerLuxe();

    } // init


    override function update(rate:Float):Void
    {
        shape.position = entity.pos;

        // drawer.drawPolygon( cast shape, new Color().rgb(0xff0000), true );
    }

}

typedef ColliderOptions = {
    > luxe.options.ComponentOptions,

    var hitbox:Rectangle;
}
