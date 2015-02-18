
package components;

import luxe.Component;
import luxe.Vector;
import luxe.Visual;
import luxe.Input;
import Main;


class SnakeHead extends Component
{

    public var left:Bool    = false;
    public var right:Bool   = false;
    public var up:Bool      = false;
    public var down:Bool    = false;

    // Final direction of snake
    public var dir:Direction = Up;
    // Undecided direction, updated each frame
    var tmpDir:Direction = Up;

    public var dirVector:Vector;

    var _lVector:Vector;
    var _rVector:Vector;
    var _uVector:Vector;
    var _dVector:Vector;

    override function init():Void
    {

        dirVector = new Vector(0,-1);

        _lVector = new Vector(-1,0);
        _rVector = new Vector(1,0);
        _uVector = new Vector(0,-1);
        _dVector = new Vector(0,1);

        Luxe.events.listen('move', function(e:MoveEvent){
            setDirVector();

            pos.add( new Vector(dirVector.x*e.cell.x, dirVector.y*e.cell.y) );

            if(!e.bounds.point_inside(pos)){
                if(pos.x > e.bounds.x + e.bounds.w){
                    pos.x -= e.bounds.w;
                }else if(pos.x < e.bounds.x){
                    pos.x += e.bounds.w;
                }
                if(pos.y > e.bounds.y + e.bounds.h){
                    pos.y -= e.bounds.h;
                }else if(pos.y < e.bounds.y){
                    pos.y += e.bounds.h;
                }
            }
        });

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

        if(dir == Up || dir == Down){
            if(left){
                tmpDir = Left;
            }
            if(right){
                tmpDir = Right;
            }
        }else if(dir == Left || dir == Right){
            if(up){
                tmpDir = Up;
            }
            if(down){
                tmpDir = Down;
            }
        }

        switch(dir)
        {
            case Up: cast(entity, Visual).rotation_z = 0;
            case Down: cast(entity, Visual).rotation_z = 180;
            case Left: cast(entity, Visual).rotation_z = 270;
            case Right: cast(entity, Visual).rotation_z = 90;
        }
    }

    function setDirVector()
    {
        switch(tmpDir){
            case Up: dirVector.copy_from(_uVector);
            case Down: dirVector.copy_from(_dVector);
            case Left: dirVector.copy_from(_lVector);
            case Right: dirVector.copy_from(_rVector);
        }
        dir = tmpDir;
    }

}

enum Direction{
    Up;
    Down;
    Left;
    Right;
}
