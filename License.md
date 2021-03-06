# Open Source Anti-Piracy License

Originally Written: `August 7th, 2019`
<br>
Last Modified: `November 29th, 2019`

This is a custom license written by *Alexis Evelyn* (the developer of *Codename: Sweet Tea*). This license is based off of GPL 3, but has been modified for my needs.

### License Restrictions

This license **must** be included with the source code and the source code **must** be publicly available with a reasonable way to find the source code associated with that executable. This means, don't hide the source code from others (I had to deal with tracking down the source code to a router because the company wanted to make it as hard to find as possible while still following the legal requirements to publish the code).
*  Putting the url to the source code in the game's about section will suffice (providing that the about section is easily accessible to the consumer and the url can easily be visited).
* The url to the source code does not have to be inside the game itself, so long as their is a reasonable way to find the source code.

* The game itself has to remain the same license as the original game's license, however, mods (separate from the game's source code) can be released under any license (including All Rights Reserved).

* The game cannot be sublicensed. Mods can be licensed however the mod developer wants.

* Custom servers/bots can be licensed however the developer wants (providing that the server/bot is only based on the game code and does not substantially copy the game's code).

### Reason For License

The reason why I am creating a license is to allow people to use my source code for multiple reasons.
  1. The source code is available to make modding the game easier (who wants to reverse engineer the executable when they don't have to).
  2. The source code provides transparency, so the consumers can review the code and see what the game does (including any security/efficiency flaws that can be brought to my attention).
  3. The game can be ported to other platforms, so long as the account authentication is not removed/disabled.
  4. The consumer can play their own customized version of the game.
  5. The server code can be used to help with the creation of custom servers.
  6. Bots can be made from the client code (say to test AI deep learning)
  7. The code can be used in educational environments (say to teach how to make games).

### Porting

Any game that has been modified/ported **must** make very clear the game is not an official build (official meaning that the original developer, *Alexis Evelyn*, or her business, did not build it). Just putting "Unofficial" in the name of the game will suffice (providing people can easily see it). The game's name can also be changed or added onto so long as it distinguishes the game from an official build. The name change applies to the place where a user can retrieve a copy of the modified game (e.g. on a download page) as well as in game.

Those who port/modify the game to other platforms can charge for their work. The source code still has to be released with this license. If there is a substantial reason the source cannot be released, the person porting the game **must** contact me and explain the situation. After investigating, if I deem the reason to not disclose the source to be legitimate, then I will authorize the game to not have to disclose the source code.

### Monetary Charging

In game items provided by a server can be charged for. The server owner is responsible for all transactions and refunds (if any). The server is not allowed to take away items from the user if the server did not provide the items in the first place (because the inventory is shared between multiplayer and single player). The only exception is despawning items after the player's death (client will handle if items should drop, so player can override this, say if they wanted to play casually).
*  It is not recommended (but not forbidden) to provide paid for items for a limited time (this includes limited uses). The client can choose to ignore removing the item (as it handles the inventory). If the server owner wishes to go down this route, server-side checks **must** be in place to prevent use of the item.

* Charging access to worlds (or the server as a whole) is allowed, but not recommended. If I find a substantial number of consumers complain about world access charges, I reserve to right to remove allowing charging.

* Mods (separate from the game's source code) can be charged for and mods do not have to have their source code released.

### Other

Bots are allowed in the game so long as the server owner allows the bot. The server owner has to explicitly allow the bot (that can be done by just allowing all bots, except banned bots).

An educational setting (such as a school) can request free accounts for their students to use with the class. Educational environments are also the only ones allowed to remove/replace the account authentication system (say if they wanted their own or if the wanted to improve the authentication system).

People can use this license (either unmodified or modified) in their own projects if they want to. Just change the name in the license from *Alexis Evelyn* to the name of the copyright holders.

### Warranties

The game comes with no warranty and I am not held liable for any damages caused by the game (this includes mods).

Those who modify/port the game can release their own warranties if they wanted to.

### Changes In License

This license **must** remain unchanged, except by *Alexis Evelyn*. Also, this license can change at any time without Alexis notifying anyone.

I, *Alexis Evelyn*, reserve the right to change the license how I see fit. The updated license will only apply to newer versions of the game (to prevent people from being concerned about the license changing on an existing version of the game).


# Reason For the Paid Account System

It appears that the only reasonable way to prevent Man In The Middle (MiTM) attacks between client and server is to use a third party server (third party as in not the consumer or server owner). As a result of preventing the MiTM attacks, I might as well provide a licensed based subscription where consumers pay me for a license to use the game instead of paying for a separate copy of the game on every platform they want it on (say if someone wants to download the game on Steam and GameJolt, they only have to pay once per account).

This paid authentication system also allows for bans to be more feasible as the person who has been banned will have to spend money every time they try to circumvent the ban.

I worked very hard on this game, so I would like to be paid for my work so I can afford to continue working on the game and other cool projects.

Having a paid authentication system allows me to release the source code as now the game itself doesn't cost money, but the license to use the game does.

Yes, I know that some private users will remove the auth system to pirate the game. This would happen regardless of if the game was open source. However, most users will be more than willing to pay for the game and at least with the source code available, pirating the game has less of a risk of downloading viruses (providing the pirate knows how to compile source code). I am not really concerned about a few pirates here and there, only that I don't have my income stolen from me to the point where I cannot afford to continue my work.

In that, if I see someone who released a pirated version of the game (especially without the source code), then I may take legal action, but that is up for me to decide (on a case-by-case basis).

I guess the best way to explain it is, I only care about the money to the point where I can live comfortably. My goal is not to make the most money possible, just make enough money, so I can continue doing what I enjoy and I can retire when I want.


# Reason For Other Decisions

I also care about educating others on game development, so I am allowing educational environments (e.g. schools) to have free access to the game without having to fork over tons of money to do so. So long as this is not abused, I will keep education use free.

When I go to buy a game, I get excited when there are mods available (so when I finish the base game, I can add replay value to the game). I allow the game (client and server) to be modded for this reason.

I allow charging for certain custom additions to the game, so people can be motivated to provide more value to the game than already exists in the base game.

I also allow custom servers/bots because I like the idea of customizing the game beyond what the game itself can already do. I am also a fan of automation (when I get bored with a base game or find a certain task tedious).
