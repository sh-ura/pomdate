# pomdate
Pomodoro timer for Playdate

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [pomdate](#-pomdate-)
  - [Status](#-status-)
  - [Install](#-install-)
  - [Develop](#-develop-)
  - [Attributions](#-attributions-)

<!-- /code_chunk_output -->


## Status

MVP complete in `main` branch. Useable.
Lacks pausing and snoozing - to be added soon.

## Install

1. Install [Playdate SDK v1.12.3](https://sdk.play.date/1.12.3/)
2. Clone this repo
3. Compile `app`, ex. from the `pomdate` project root:
```
pdc --main -sdkpath <PATH_TO_SDK> ./app/main.lua ./app/main.pdx
```
4. Open the Playdate Simulator. From `File` > `Open...` open `app/main.pdx`.

The app is now useable in the simulator, if you would like to use it as a desktop app. For running it on the Playdate:

1. Plug your Playdate into your computer and press the lock button twice to unlock it.
2. `Device` > `Upload Game to Device` will install `pomdate` on the Playdate.

## Develop

Class diagram [here](http://www.plantuml.com/plantuml/uml/ZLRDSjqs3zthARZyFj_OYoxTz4uQ9zFU6Jlfr4uNxNGob0H9h2cIGuB-IUjtBqX8bAxgk5s9E229WmDGv9k0qcCSTULaSojx44xBnrOYY3yhqMWPWkYzT8DgmjcryueTOXS03oFD_z__awMCGXv5HuidLBOj3poCzYw3JvKm5a5urGyeR2Tup_DpNaUJvmr48xM6Li0T-4V2Eoz74DQ84SOQVA35XFRQrbABmCoq2lWjeNCyWLQqAiXQBpk7Ie1fCukAG4xnO_q7D5WzLLEAfwT_xMTmK2rCOugDWsr3LLLs0gGoulNhJcdOxvCofm6JUEVYlOaZcQX68alsJHhyzZj1JVGU36PWTbHYrmDU8sj7YaMJyMnO1-OAJ2JZgShoQUYIUZdy-VdihyHeMzKf22Apg4gYfRgPJgaiKo2JI5b3GcTI58O0MgUwHnv_nechQy_oC8Djz1ALDOHtsahCuAXCUBSub65OZJrPVVTmfbBNJ1tq8SMujj5mdoHeNij0lmLok_BGoHXURBzrrt6gN5UkyGATJ39ogKZYebPKIHnP1_IoGV7fy5x320O9pKc52siwrKSFBMLNMwiptWpGtB8hQHDDyxm6X3cPMe7WilUqWz8jUTOEwfsyo-S06XgyI5EAmZiZHo2Bc2hJPqt2TPu7xSH1VBUVAUue7nDKalKm2RiW7oEMuvk3i9MqlB6bJhyUJ0iFNvUV92_CZsIVU-y7RwER_oLCzFicnLyasncBrr_pDLdVdw7Pi7s94WTbEeNTWfw8InMmC7mR4QrviTQayayUGdXMPCUUBVEatgMiGR_8b8DlgIxm2RCkPDyfgIUgaNOihP2HWE1MXr7R-qirAbn1qRajHFJlVf4wmj9aTyTc3vZ2NWpIzB08CBi3u2TEZesysKj9SnARb6Tmc_0DF61j7wQSEsjmEbmqN6AcMMnu2EeBf31bwJPImRUTa8pI1pzQhxvG3AdNPpuusP3SQvLbc0_fvdGhuo9Itzpn7_MMYxguFX2FVxgqVBGHZsL-jIh5bNoW5aKmL9Jnlvy9JcuZnGoU47ObZUp15p4AGlTUe9Gr4CFzdlLH9g0qJUg6PQMOhy5qIP4dRLx0LDv0OFhcNnp3VEuv_UJc4KyWYl50WRPRhR6bFV-zxGfJbe7Nhy5zlY7MDqCBTUnxlZpvAS0Go-9kUt7lfNFW9s5s_0pXYCkXdPQmTc1enj7VHTkUwJOQfB-ShTRB-s8ehMD0Bn7Ufeiqh1OSPfSY3PUbpy5nT4oDqoXQp0mNV95373r5sZ9JuA22K27vnVJOqO-4IqxxbQWZYZ3Og5j2dRTr43KqDh_lWA2WKWif58ESdZ8yZ_H4TVI28ot3hJ9EUZcAFlqW3cO0hxW9lwdUWA7SzDy0)

This project is not yet ready to accept code contributions, but it will be open to them in the future. In the meantime, feel free to [open an issue](https://github.com/sasha-pavlov/pomdate/issues), or send me an email at [src@aspavlov.com]() :)

## Attributions

Notification sound: ['*1 - xylophone.wav*' by 14G_Panska_Niklova_Michaela](https://freesound.org/people/14G_Panska_Niklova_Michaela/sounds/422137/)