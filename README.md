# Overview
Hello!
Here you will find my submission for the Lead Roblox Developer practical. You can find the game here: https://www.roblox.com/games/135315459184123/
Unfortunately, the scope I was able to complete was not what I had hoped for, but I will outline my vision in the game design section below.

# Game Design
The concept for the game is inspired by Nintendogs and Tamagachi games. I used to love playing Nintendogs on my 3DS, and the vision for this prototype was very similar.
The core gameplay revolves around having a pet you need to take care of. In this prototype, there are 3 needs:
- Food (Apple)
- Happiness/Play (Ball)
- Cleanliness (Brush)

In the prototype, need collectibles will spawn every couple of seconds. By hovering over it and click on them, your pet will collect them and restore their needs. To clarify, I really wanted
to add minigames to each of these, allowing the player to interact directly with the fox, but I was unable to do so within the alloted time and had to compromise with this simpler version instead.
The decision to remove player characters was very deliberate; I felt that it did not complement the focus of the game on the pets. I added vertical clamping and modified zoom distances to the camera
to provide a more natural user experience.

Given that the pets needs are critical to the gameplay, as well as designing for the intent of supporting multiple pets in the future, I opted to place information about a pet's current needs and
their name directly above them, providing immediate context and information to players. If the prototype had supported multiple pets, I would ensure only one pet's information was visible at a given time.

Much like in Nintendogs and Tamagachi games, the idea is that you have a digital pet that lives even while offline. To this end, their needs will degrade even while you're offline!
This offline functionality encourages players to revisit the game on a regular basis, boosting retention metrics. In order to address each need, you can start a minigame by interacting with the environment,
such as clicking on a bag of treats to feed them, petting them, clicking on a sponge to clean them and clicking on the door to take them on walks. However, due to the limited timeframe I was unable to
implement these. Completing each minigame will restore each pets needs according to player performance and reward the player with a currency that can be spent. The currency, which I thought might be called
"treats", can be spent in various shops, such as an accessory shop, treats, consumables and even placable objects which pets can interact with!

In Nintendogs, only cats and dogs were available, but I think there's an opportunity to introduce more exotic pets, such as foxes and other mammals. Notably, Roblox players love unboxing
mechanics, such as egg hatching. We could introduce a similar mechanic here, although in order to match the casual, laid-back theme of the game, it would have to bemore subdued than other 
games. Perhaps a system where you select from a random selection of pets reset on a daily basis, much like Nintendogs, to incentivise players to frequently revisit.

Pets are dynamic: they will age and develop unique personalities that will be expressed through interactions with other pets. For example, a pet that is treated well may recieve an "giddy"
trait, causing their exercise need to go down faster. We could explore relationships between pets: one pet may become enemies or rivals with another, whereas two others may become codependant.
Because we don't want to upset players, pets will not die if a player fails to take care of them. However, they may develop negative traits or behaviours.

Social interaction between players and pets is an essential opportunity to take advantage of here: allowing players to interact with their friend's pets with walks, visits to a player's house or communal
environments and offering bonuses to rewards will promote stronger engagement with the game, boosting engagement metrics.

# Art
Being a casual, cosy game, I decided that an environment in a deep forest would be a suitable location, evoking emotions of coziness and wilderness. This provides the player with the
ever-important sense of fantasy, taking care of animals in a secluded, quiet location. I'd also love to add an interior area that pets can freely walk between, with the interior being a cosy cottage house.
Whilst this wasn't in the prototype, we could lean into this further with fantasy elements and pets.
The prototype uses a classic-stud aesthetic that is popular and often works well with laid-back games, but I would be interested in exploring an approach featuring meshes with blocky yet cartoony
proportions, similar to the platformer kit found below. Because the core draw of the game centres around an emotional connection to the pets, making the pets expressive is really important. Sounds, 
art and animation would be essential to this, as well as complex behaviours and interactions that feel natural as opposed to programmed.

https://kenney.nl/assets/platformer-kit

# Code Structure
The code is structured into a single-script format with client and server bootstrappers, with an additional packages and shared folder.
Aside from packages, config and utility modules which should be self-explanatory, the codebase is separated into two distinct categories: services and components.

Services execute behaviour on startup, and encompass abstract logic, such as networking and player data.
Components, on the other hand, are behaviours attached to specific instances in the explorer with tags. They have a lifecycle and are modular. Some components depend on others.
In the near future, its very likely a lot of the component-specific boilerplate will be replaced by the Collections API.
There is code written to validate and rename pets, but adding a frontend for this behaviour was not completed within the timeframe.

Because I don't have a Claude Code subscription, no AI was used in the development of the project.

## Assumptions
For this prototype, I decided to reduce the scope significantly by making assumptions.
- The game is singleplayer
- The player only has 1 pet
- The prototype will inform an MVP in the future

Whilst I made sure that the project was configurable and extensible to the best of my ability, I find that often prototypes are best treated as tools to inform a new project on which a more informed approach can be taken.
