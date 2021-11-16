Class=require'class'
push = require 'push'
require'Paddle'
require'Ball'
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
servingPlayer=1
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243


PADDLE_SPEED = 200
---------------------------------------------------------------------------------------
--                                                                                   --
--                                 LOAD                                              --
--                                                                                   --
----------------------------------------------------------------------------------------
function love.load()


    love.graphics.setDefaultFilter('nearest', 'nearest')
		math.randomseed(os.time())
    -- more "retro-looking" font object we can use for any text
    smallFont = love.graphics.newFont('font.ttf', 8)
  	scoreFont = love.graphics.newFont('font.ttf', 32)
    -- set LÖVE2D's active font to the smallFont obect
    love.graphics.setFont(smallFont)

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        })

				player1=Paddle(10,30,5,20)
				player2=Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-30,5,20)

				ball=Ball(VIRTUAL_WIDTH/2-2,VIRTUAL_HEIGHT/2-2,4,4)

				--Game State
				gameState='start'
end

--Players initial scores
player1Score=0
player2Score=0
---------------------------------------------------------------------------------------
--                                                                                   --
--                               UPDATE                                              --
--                                                                                   --
----------------------------------------------------------------------------------------


function love.update(dt)
  if gameState=='serve' then
    ball.dy=math.random(-50, 50)
    if servingPlayer==1 then
      ball.dx=math.random(140,200)
    elseif servingPlayer==2 then
      ball.dx=-math.random(140,200)
    end
elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position of collision
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.50
            ball.x = player1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.50
            ball.x = player2.x - 4

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            ball.dx=ball.dx*1.50
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            ball.dx=ball.dx*1.05
        end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

if ball.x<0 then
  servingPlayer=1
  player2Score=player2Score+1
  ball:reset()
  gameState='serve'
end

if ball.x>VIRTUAL_WIDTH then
  servingPlayer=2
  player1Score=player1Score+1
  ball:reset()
  gameState='serve'
end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)


end
---------------------------------------------------------------------------------------
--                                                                                   --
--                                KEY PROMPS                                         --
--                                                                                   --
----------------------------------------------------------------------------------------

function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState='serve'

        elseif gameState=='serve'then
            game='serve'
        else
            gameState = 'start'

            ball:reset()
        end
    end
end

---------------------------------------------------------------------------------------
--                                                                                   --
--                                 DRAW                                              --
--                                                                                   --
----------------------------------------------------------------------------------------
function love.draw()
-- begin rendering at virtual resolution
    push:apply('start')
    love.graphics.clear(25, 100, 0, 0)
--Game title drawing
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
--Score drawing
		love.graphics.setFont(scoreFont)
		love.graphics.print(tostring(player1Score),VIRTUAL_WIDTH/2-50,VIRTUAL_HEIGHT/3)
		love.graphics.print(tostring(player2Score),VIRTUAL_WIDTH/2+30,VIRTUAL_HEIGHT/3)
--Drawing Paddles
		player1:render()
		player2:render()
--Drawing Ball
		ball:render()
--Displaying FPS
	DisplayFPS()
    -- end rendering at virtual resolution
    push:apply('end')
end

function DisplayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0,255,0,255)
	love.graphics.print('FPS: '..tostring(love.timer.getFPS()),10,10)
end
