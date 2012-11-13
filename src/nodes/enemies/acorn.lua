local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'
local game = require 'game'

return {
    name = 'acorn',
    hit_sound = 'acorn_growl',
    die_sound = 'acorn_crush',
    position_offset = { x = 0, y = 4 },
    height = 20,
    width = 20,
    damage = 1,
    hp = 1,
    tokens = 1,
    tokenTypes = { -- p is probability ceiling and this list should be sorted by it, with the last being 1
        { item = 'coin', v = 1, p = 0.95 },
        { item = 'health', v = 1, p = 1 }
    },
    animations = {
        dying = {
            right = {'once', {'1,1'}, 0.25},
            left = {'once', {'1,2'}, 0.25}
        },
        default = {
            right = {'loop', {'4-5,1'}, 0.25},
            left = {'loop', {'4-5,2'}, 0.25}
        },
        attack = {
            right = {'loop', {'9-10,1'}, 0.25},
            left = {'loop', {'9-10,2'}, 0.25}
        },
        dyingattack = {
            right = {'once', {'2,1'}, 0.25},
            left = {'once', {'2,2'}, 0.25}
        }
    },
    enter = function( enemy )
        enemy.direction = math.random(2) == 1 and 'left' or 'right'
        enemy.maxx = enemy.position.x + 24
        enemy.minx = enemy.position.x - 24
    end,
    attack = function( enemy )
        enemy.state = 'attack'
        enemy.jumpkill = false
        Timer.add(5, function() 
            if enemy.state ~= 'dying' and enemy.state ~= 'dyingattack' then
                enemy.state = 'default'
                enemy.maxx = enemy.position.x + 24
                enemy.minx = enemy.position.x - 24
                enemy.jumpkill = true
            end
        end)
    end,
    die = function( enemy )
        if enemy.state == 'attack' then
            enemy.state = 'dyingattack'
        else
            sound.playSfx( "acorn_squeak" )
            enemy.state = 'dying'
        end
    end,
    update = function( dt, enemy, player, level )
        if enemy.state == 'dyingattack' then return end

        local rage_velocity = 1

        -- Gravity
        enemy.velocity.y = enemy.velocity.y + game.gravity * dt
        if enemy.velocity.y > game.max_y then
            enemy.velocity.y = game.max_y
        end

        if enemy.state == 'attack' then
            rage_velocity = 4
         end
     
        if enemy.state == 'attack' then
            if enemy.position.x > player.position.x then
                enemy.direction = 'left'
            else
                enemy.direction = 'right'
            end
        
        else
            if enemy.position.x > enemy.maxx then
                enemy.direction = 'left'
            elseif enemy.position.x < enemy.minx then
                enemy.direction = 'right'
            end
        end
        if math.abs(enemy.position.x - player.position.x) < 2 then
            -- stay put
        elseif enemy.direction == 'left' then
            enemy.velocity.x = 20 * rage_velocity
        else
            enemy.velocity.x = -20 * rage_velocity
        end
        enemy.position.x = enemy.position.x - (enemy.velocity.x * dt)
        enemy.position.y = enemy.position.y + (enemy.velocity.y * dt)

        if enemy.position.y > level.boundary.height
                             and enemy.state ~= 'dying'
                             and enemy.state ~= 'dyingattack' then
            enemy:hurt()
        end
    end
}