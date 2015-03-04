package;

import luxe.Input;
import luxe.Rectangle;
import luxe.Text;
import luxe.Vector;
import luxe.Scene;
import luxe.Visual;
import luxe.Timer;
import components.SnakeHead;
import components.HeadCollider;
import components.Collider;

import phoenix.Batcher;
import phoenix.BitmapFont;
import luxe.Color;


class Main extends luxe.Game
{

    var playing:Bool;
    var score:Int;

        // Timer for making snake move
    var timer:Timer;

        // size and position of game borders
    var bounds:Rectangle;
        // Padding for each side
    var padding:Rectangle;
        // columns in grid
    var gridx:Int;
        // rows in grid
    var gridy:Int;
        // Calculated by bounds/grid
    var cell:Vector;

        // Snake's head
    var snake:Visual;
        // List of snake's body blocks
    var snakeBodies:Array<Visual>;
    var snakeBodiesMove:Array<Vector>;

    var menuScene:Scene;


    var welcomeText:Text;
    var scoreText:Text;


    override function config(config:luxe.AppConfig):luxe.AppConfig
    {
        trace(config.runtime);
        if(config.runtime.window != null) {
            if(config.runtime.window.width != null) {
                config.window.width = Std.int(config.runtime.window.width);
            }
            if(config.runtime.window.height != null) {
                config.window.height = Std.int(config.runtime.window.height);
            }
        }
        config.window.resizable = false;




        if(config.runtime.grid != null) {
            if(config.runtime.grid.x != null) {
                gridx = Std.int(config.runtime.grid.x);
            }else{
                gridx = 15;
            }

            if(config.runtime.grid.y != null) {
                gridy = Std.int(config.runtime.grid.y);
            }else{
                gridy = 15;
            }
        }

        padding = new Rectangle(10,10,10,10);
        if(config.runtime.padding != null) {
            padding.x = Std.parseFloat(config.runtime.padding.left);
            padding.y = Std.parseFloat(config.runtime.padding.top);
            padding.w = Std.parseFloat(config.runtime.padding.right);
            padding.h = Std.parseFloat(config.runtime.padding.bottom);
        }

        bounds = new Rectangle(padding.x,padding.y,config.window.width - padding.w*2,config.window.height - padding.h*2);
        if(config.runtime.boardSize != null) {
            var bw:Float = Std.parseFloat(config.runtime.boardSize.w);
            var bh:Float = Std.parseFloat(config.runtime.boardSize.h);
            if(bw < 0.1) bw = 0.1;
            if(bh < 0.1) bh = 0.1;
            if(bw > 1) bw = 1;
            if(bh > 1) bh = 1;

            bounds.x = padding.x + config.window.width*(1-bw)/2;
            bounds.y = padding.y + config.window.height*(1-bh)/2;
            bounds.w = config.window.width*bw - padding.w*2;
            bounds.h = config.window.height*bw - padding.h*2;
        }

        return config;
    }

    override function ready()
    {
        menuScene = new Scene('menu');

        initGame();

        Luxe.events.listen('hit.item', function(e:CollisionEvent){
            e.two.destroy(true);

            score += 1;
            updateScoreText();

            placeItem();
            placeSnake();
        });

        Luxe.events.listen('hit.snake', function(e:CollisionEvent){
            gameOver();
        });

        Luxe.events.listen('move', function(_)
        {
            // Move every snake body (only body)
            // snakeBodiesMove = new Array<Vector>();
            var lastV:Vector = new Vector().copy_from(snake.pos);

            for(i in 1...snakeBodies.length)
            {
                snakeBodiesMove[i].copy_from(snakeBodies[i-1].pos);
            }
            snakeBodiesMove[0].copy_from(snake.pos);

            for(i in 1...snakeBodies.length)
            {
                snakeBodies[i].pos.copy_from(snakeBodiesMove[i]);
            }

        });

    } //ready

    override function onkeyup( e:KeyEvent )
    {

        if(e.keycode == Key.escape && !playing)
        {
            quit2();
        }
        else if(e.keycode == Key.escape && playing)
        {
            quit1();
        }

        if(e.keycode == Key.enter && !playing)
        {
            play();
        }

    } //onkeyup

    override function update(dt:Float)
    {
        
    } //update



    function initGame():Void
    {
        snakeBodies = new Array<Visual>();
        snakeBodiesMove = new Array<Vector>();


        cell = new Vector(bounds.w/gridx, bounds.h/gridy);

        playing = false;
        score = 0;

        initSnake();


        welcomeText = new Text({
            bounds: new Rectangle(0,100,Luxe.screen.w, 100),
            align: center,
            point_size: 16,
            text: 'Press ENTER to start\ncontrol with ARROWS',
            batcher: Luxe.renderer.batcher,
            scene: menuScene,
        });
        
        scoreText = new Text({
            bounds: new Rectangle(0, Luxe.screen.h/4, Luxe.screen.w, Luxe.screen.h),
            align: center,
            point_size: 160,
            text: '0',
            color: new Color(0.4,0.4,0.4,0.3),
            scene: menuScene
        });

        drawGrid();
    }

    function clearEverything()
    {
        Luxe.scene.empty();

        welcomeText.destroy();
        scoreText.destroy();

    }

    function gameOver(){
        quit1();
        clearEverything();
        initGame();
    }

    function quit1():Void
    {
        playing = false;

        resetTimer();

        welcomeText.visible = true;
        scoreText.visible = false;

    } // quit1

    function quit2():Void
    {
        Luxe.shutdown();   
    } // quit2

    function play():Void
    {
        placeItem();

        playing = true;

        initTimer();

        welcomeText.visible = false;
        scoreText.visible = true;

    } // play









    function initSnake(){
        snake = new Visual({
            name: 'snakeHead',
            pos: new Vector(
                Math.round(gridx/2)*cell.x - cell.x/2 + padding.x,
                Math.round(gridy/2)*cell.y - cell.y/2 + padding.y
            ),
            color: new Color().rgb(0x33ff33),
            geometry: Luxe.draw.circle({
                x:0, y:0, r: cell.x/2-2,
                start_angle: 35,
                end_angle: 325
            }
            ),
            // scene: gameScene
        });
        snake.add( new SnakeHead({name:'head'}));
        snake.add( new HeadCollider({
            name:'collider',
            hitbox:new Rectangle(-cell.x*0.5/2, -cell.y*0.5/2, cell.x*0.5, cell.y*0.5),
        }));
        snakeBodies.push(snake);
        snakeBodiesMove.push(new Vector(snake.pos.x, snake.pos.y));


            // First body ball
        addSnakeBody(snake.pos.x, snake.pos.y + cell.y);
        addSnakeBody(snake.pos.x, snake.pos.y + cell.y*2);
        addSnakeBody(snake.pos.x, snake.pos.y + cell.y*3);
    }



    function initTimer():Void
    {
        timer = new Timer(Luxe.core);
        timer.schedule(0.16, function(){ Luxe.events.fire('move', {
            cell: cell,
            bounds: bounds,
            gridx: gridx,
            gridy: gridy
        }); }, true );
    }

    function resetTimer():Void
    {
        timer.reset();
    }

    function drawGrid():Void
    {
        Luxe.draw.rectangle({
            x: bounds.x, y: bounds.y,
            w: bounds.w, h: bounds.h,
            color: new Color().rgb(0x665544),
        });


        // ||||||||
        for(i in 1...gridx){
            Luxe.draw.line({
                p0: new Vector(i*cell.x + bounds.x, bounds.y),
                p1: new Vector(i*cell.x + bounds.x, bounds.y+bounds.h),
                color: new Color(0.2,0.15,0.1,0.5)
            });
        }

        // ________
        for(i in 1...gridy){
            Luxe.draw.line({
                p0: new Vector(bounds.x, i*cell.y + bounds.y),
                p1: new Vector(bounds.x+bounds.w, i*cell.y + bounds.y),
                color: new Color(0.2,0.15,0.1,0.5)
            });
        }
    }







    function updateScoreText():Void
    {
        scoreText.text = '${score}';
    }

    function randomVectorOnGrid():Vector{
        var vec:Vector = new Vector(
            (Math.floor( Math.random()*gridx )+1) *cell.x - cell.x/2 ,
            (Math.floor( Math.random()*gridy )+1) *cell.y - cell.y/2 
        );
        return vec;
    }







    function placeItem()
    {
        var color:Color = new Color().rgb( Math.floor( Math.random()*0xDDDDDD + 0x222222) );
        var item:Visual = new Visual({
            name:'item',
            name_unique: true,
            geometry:Luxe.draw.box({
                x: -cell.x/2 + padding.x, y: -cell.y/2 + padding.y,
                w: cell.x, h: cell.y
            }),
            color: color,
            pos: randomVectorOnGrid()
        });
        item.add(new Collider({
            name:'collider',
            hitbox: new Rectangle(-cell.x/2, -cell.y/2, cell.x*0.8, cell.y*0.8)
        }));

    }


    function placeSnake()
    {
        var lastPos:Vector = snakeBodies[snakeBodies.length-1].pos;
        addSnakeBody(lastPos.x, lastPos.y);
    }

    function addSnakeBody(x:Float, y:Float)
    {
        var snakeBody:Visual = new Visual({
            name:'snake',
            name_unique: true,
            geometry:Luxe.draw.circle({
                x: 0, y: 0,
                r: cell.x/2 * 0.9
            }),
            color: new Color().rgb(0x66ff66),
            pos: new Vector(x, y),
        });
        snakeBody.add(new Collider({
            name:'collider',
            hitbox: new Rectangle(-cell.x*0.8/2, -cell.y*0.8/2, cell.x*0.8, cell.y*0.8)
        }));

        snakeBodies.push(snakeBody);
        snakeBodiesMove.push(new Vector(snakeBody.pos.x, snakeBody.pos.y));
    }











} //Main

typedef VectorInt = {
    var x:Int;
    var y:Int;
}

typedef MoveEvent = {
    var gridx:Int;
    var gridy:Int;
    var cell:Vector;
    var bounds:Rectangle;
}
