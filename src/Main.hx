package;

import Enemy;

import luxe.Input;
import luxe.Rectangle;
import luxe.Text;
import luxe.Vector;
import luxe.Scene;
import luxe.Timer;

import phoenix.Batcher;
import phoenix.BitmapFont;
import luxe.Color;


class Main extends luxe.Game
{

    var playing:Bool;
    var score:Int;
    var timer:Timer;


    var bounds:Rectangle;
    var grid:Vector;
    var cell:Vector;


    var snake:Entity;


    var menuScene:Scene;
    var gameScene:Scene;


    var welcomeText:Text;
    var scoreText:Text;


    override function config(config:luxe.AppConfig):luxe.AppConfig
    {
        config.window.width = 400;
        config.window.height = 400;
        config.window.resizable = false;
                
        return config;
    }

    override function ready()
    {
        menuScene = new Scene('menu');
        gameScene = new Scene('menu');

        initGame();

        Luxe.events.listen('enemy.damaged', function(e:EnemyEvent){
            if(!playing) return;
            if(e.enemy.collider.hit == false) return;
            score += pointsDamage;
            updateScoreText();
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
        bounds = new Rectangle(0,0,Luxe.screen.w,Luxe.screen.h);
        grid = new Vector(20,20);
        cell = new Vector(bounds.x/grid.x, bounds.y/grid.y);

        playing = false;
        score = 0;

        snake = new Entity({
            name: 'snake',
            pos: new Vector(Math.floor(grid.x/2*cell.x), Math.floor(grid.y/2*cell.y)),
            size: new Vector(cell.x,cell.y),
            color: new Color().rgb(0xFFFFFF),
            geometry: Luxe.draw.circle({
                x:0, y:0, r:cell.x/2,
                color: new Color().rgb(0x33ff33)
            }),
            scene: gameScene
        });
        snake.add(new components.PlayerInput({name:'input'}));
        snake.add(new components.Mover({name:'mover'}));


        welcomeText = new Text({
            bounds: new Rectangle(0,100,Luxe.screen.w, 100),
            align: center,
            point_size: 16,
            text: 'Press ENTER to start\ncontrol with ARROWS',
            batcher: Luxe.renderer.batcher,
            scene: menu,
        });
        
        scoreText = new Text({
            bounds: new Rectangle(10, 10, Luxe.screen.w-10, 30),
            align: left,
            point_size: 24,
            text: 'SCORE: 0',
            scene: gameScene
        });

        initTimer();
    }

    function initTimer():Void
    {
        timer = new Timer();
        timer.schedule(0.2, function(){ Luxe.events.fire('move', ); }, true });
    }

    function resetTimer():Void
    {
        timer.reset();
    }

    function updateScoreText():Void
    {
        scoreText.text = 'SCORE: ${score}';
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
        playing = true;

        welcomeText.visible = false;
        scoreText.visible = true;

    } // play



} //Main
