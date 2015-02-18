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

    var menuScene:Scene;


    var welcomeText:Text;
    var scoreText:Text;


    override function config(config:luxe.AppConfig):luxe.AppConfig
    {
        config.window.width = 500;
        config.window.height = 500;
        config.window.resizable = false;
                
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

        Luxe.events.listen('move', function(_){
            for(i in snakeBodies)
            {
                
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

        Luxe.scene.empty();

        snakeBodies = new Array<Visual>();

        bounds = new Rectangle(0,0,Luxe.screen.w,Luxe.screen.h);
        gridx = 15;
        gridy = 15;
        cell = new Vector(bounds.w/gridx, bounds.h/gridy);
        trace('cell = ${cell}');

        playing = false;
        score = 0;

        initSnake( );


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

    function gameOver(){
        quit1();
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
                Math.round(gridx/2)*cell.x - cell.x/2,
                Math.round(gridy/2)*cell.y - cell.y/2
            ),
            color: new Color().rgb(0x33ff33),
            geometry: Luxe.draw.circle({
                x:0, y:0, r: cell.x/2-2,
                start_angle: 35,
                end_angle: 325
            }
            // geometry: Luxe.draw.box({
            //     x:-cell.x/2, y:-cell.y/2,
            //     w: cell.x, h:cell.y
            // }
            ),
            // scene: gameScene
        });
        snake.add( new SnakeHead({name:'head'}));
        snake.add( new HeadCollider({
            name:'collider',
            hitbox:new Rectangle(-cell.x/2, -cell.y/2, cell.x, cell.y),
        }));
        snakeBodies.push(snake);


            // First body ball
        addSnakeBody(snake.pos.x, snake.pos.y + cell.y);
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
                x: -cell.x/2, y: -cell.y/2,
                w: cell.x, h: cell.y
            }),
            color: color,
            pos: randomVectorOnGrid()
        });
        item.add(new Collider({
            name:'collider',
            hitbox: new Rectangle(-cell.x/2, -cell.y/2, cell.x, cell.y)
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
                r: cell.x/2
            }),
            color: new Color().rgb(0x66ff66),
            pos: new Vector(x, y + cell.y),
        });
        snakeBody.add(new Collider({
            name:'collider',
            hitbox: new Rectangle(-cell.x/2, -cell.y/2, cell.x, cell.y)
        }));

        snakeBodies.push(snakeBody);
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
