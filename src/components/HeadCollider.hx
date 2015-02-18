
package components;

import luxe.Component;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Circle;
import luxe.collision.shapes.Polygon;
import luxe.collision.CollisionData;
import luxe.collision.Collision;
import luxe.Entity;

class HeadCollider extends Collider
{

    public var coldata:CollisionData;

    var items:Array<Entity>;
    var snake:Array<Entity>;
    var otherComponent:Collider;




    override function init():Void
    {
        super.init();
    } // init


    override function update(rate:Float):Void
    {
        super.update(rate);

        items = new Array<Entity>();
        Luxe.scene.get_named_like('item', items);

        snake = new Array<Entity>();
        Luxe.scene.get_named_like('snake', snake);

        for(t in snake)
        {
            // Test if they collide!
            otherComponent = cast(t.get('collider'), Collider);
            coldata = Collision.test(shape, otherComponent.shape);
            
            if(coldata != null)
            {
                Luxe.events.fire('hit.snake');
            }
        }
        for(t in items)
        {
            // Test if they collide!
            otherComponent = cast(t.get('collider'), Collider);
            coldata = Collision.test(shape, otherComponent.shape);
            
            if(coldata != null)
            {
                Luxe.events.fire('hit.item', {one:entity, two:t});
            }
        }
    }

}

typedef CollisionEvent = {
    var one:Entity;
    var two:Entity;
}
