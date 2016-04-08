===Asteroids===
Re-creating an iconic game while adding my own spin.

=== CONTROLS ===
Ship movement
•	Left/Right arrow keys turn the ship. 
•	Up arrow accelerates the ship.  After release, the ship will glide to a stop due to friction.
Shooting
•	Spacebar is used to shoot bullets as well as use power-ups
Power Ups
•	Use “A” and “D” to shift between powerups.  The powerup UI can be seen in the bottom-left of the
  screen.
•	Destroy asteroids and collect the energy they drop to charge your powerups.
•	The default fire action will switch to whatever powerup is active.  If you have the energy, the 
  powerup will fire instead of bullets.
Restarting
•	When the “Game Over” screen is displayed, press “R” to restart the game.

=== INTERESTING FEATURES ===
- The powerup system.  There are 3 types of powerups and each does something different.  Powerups 
  cost energy, which can be gained by destroying asteroids and collecting the particles from their 
  remains.
  * The Nuke: While it takes a while to charge, it emits a massive shockwave that destroys all 
    asteroids on screen.
  * The Shield: It has 6 levels.  Each shield level will absorb an asteroid collision and drop a 
    shield level.  Being hit without a shield will cause the ship to explode.  A solid shield circle 
    counts for 2 levels.  A rotating dotted shield counts for 1 level.
  * The Laser: A red beam that destroys all asteroids it collides with.  While active, the ship moves 
    more slowly and has rotational dampening.

- Accurate 2d polygon collision.  I did not use circle/AABB collisions, but both methods for them can
  be found in the utilities class for demonstration purposes.  2d polygon collision is quite complex, 
  but I got it to run efficiently enough to retain 60FPS even with hundreds of particles on screen 
  detecting collisions every frame.  Further documentation on how it works can be seen in the Utils class.
  * Polygon-Polygon collision using the separation axis theorem.  It uses vector projection onto planes 
    perpendicular to each side of both polygons.
  * Circle-Polygon collision using my own method.  It detects the point distance of the circle to each 
    side of the polygon.

- Momentum-based 2d elastic collisions.  Asteroids bounce off each other.  The ship bounces off asteroids 
  if shields are up.  Bullets change the velocity of sub-asteroids.  I got it done efficiently enough 
  to handle 100+ asteroids at once (asteroid detection takes n*log(n) collision checks).

- Collision wrapping.  A particle floating off one side will simultaneously be floating in from the 
  opposite.  Collisions for the particle are detected at both positions.  There are no awkward “jumping” 
  or particle ghosting effects.  Be it the player ship, asteroids, or bullets…both collisions and object 
  drawing work as if the game window is an infinitely-tiled 2d plane.

- Particle gravitation.  The energy particles gravitate towards the ship using forces.

- Custom, dynamic UI animation for the powerup GUI.  Circles fill up based on points, smoothly animate 
  between powerup selections, and don’t break when rapidly switching between powerups.

- Infinite level. The game is one big level that continually spawns asteroids at an increasing rate that 
  exponentially scales the difficulty with time.

- Dynamic restarting.  The game can reset an infinite number of times (note, I’m not responsible for 
  processing memory leaks.)
