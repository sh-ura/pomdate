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

Class diagram [here](http://www.plantuml.com/plantuml/uml/XLRRRkCs47tNL_2nRIu5-kXkZTtD1gY1PBU0lItGeWWeQInDGv44BxwapRztn95CANNI9ujdoE6SCuSqt_iWNOYTAgoi7cK3mYfvh6K0yNSXAYMz5usJjiNANw-jGmw82mzXrT7yRxxjHwWny5Uqj7X0PLtpXuFEx1BuN0XjA8V3fWt2R0NdN2nu7KqU4uXAAWMrW1su8-5R9piGHeiEkXASfyM4DigKKWdFbIdquKT2n_r4CA96BqkLC_j2WAvJ5GM1JF5B-HTKeNWk1efNL_yiHx356ePlsZkqflP5KPW1aAZ5ktTRLB1SzifSh3SVDhThiH2tEdOqze4sfM722t4LaGPVL_TIatgEW80TqI5mqt_yyIT1LNGET4Z06A1K3OHrO7L9qwWJdWR6Whu77MdmN2I15MoJlds1YyKOBqHdQjmYU97gAh8KO_zJEQVUSmaqfAACfbO4GhYzLxGEjqV-VWX3hRQ-Jfy9hAEJ0OqcVAkC30diKFjFEO2QOUmQ6ZNRmpNslXeyzhdVOssY7fn4qBYMWUOba0pDdrP6_wP1fxvagjnvTa66laio5izPfOZvVApt6AgMHP9Lm1qm0jJK8KXTxJdA42JXzSOa3zmgw427L9-_KSP3JNXfZ4f4MXDLdU1UlwWhyTEIesVFLkR6V7ZdcPKpPgRR9yC4OyalmmnAzeA99ADCf9CEX6-beuhBev1AvOMeVP2w0dyfZ8M-DReXs6E7IZfrf9rIc_dCNkUawSJJgdsBL2FZWg1fJleIeUMJVZqxoRBqmL7HcHXtv86aDNgBJNGJUGadMjKZXmPzp_kGC4j4TPZrZ3EWgYao3GoTnWSFYYI_wQTCNEwv0OiiruMM7H10rPDGx8LrMWlrcRuJH-snj_jA3-4v_2M62UuX_DQ2tfXRBKkLx-LK5uzw-spCwNZzlj8r75u_DSz59Zi_BTDx9yzPB4uwKQ9W17RMqPOqiy4I5ORZ9GLaqpXeqZd-lZATDSn6k8FsBLfFKqe8Um2TK_jaGzgMh6ZsclmmZLLIYw5nHeEGDAy5b_RITJ9HYqqBFbmfs84QvwBlOuN8T_JSPtpcFyOGZ7xJOTJ7NnnuVxQDbYCVgaHorgyxMO9wKt_UdCK_4JwLzWcb6WgBj7vYBK9y03knepBxE-mmJA1exKk8YjtzAbM44tQncmyR2FssDwtK3MIw74wilZ8L7gHaRr5a4gyGtC0XbEOmSDmQ7OO3Iv_ZTlsSyNxq-0GfwR3mjRntwFETyRDn-4Jvf9hU6TxAYgISAYZzwP3FRmVKDWPom8x_5H-vQpdqcQhvRqZ9eubXBk7bHEPxUI2p1T0aU3S_pcy9okJE4yzEfvUC9teAg9hbahKOhzxvgsLyjlIF2ehqsNjm_CFls-S9xt_vHkneuefIJIQFBvWNiDV6F05BGd3MfZOQNYoOck__JPLvpeN8aVD_zZMKiMdu7SJlFePOCVlOYBsJre8RDBlWDoTlcyzbpa9aGDECsNMXJCCrLmgaknj7jPFxqm2LYZwGnl2nVnFvoO8LXvByFYyz1yVEScbCOnJaLE4CNx8SyzkzFiqKeKKlqFTnCRnRrP5moRGlHHc3uBSCeTQPqeiIAfCUyq2GnzvT64GhXrSfpoCz0ywUwwIbVqHjfPETQ9o9TgLRSCZ-_A5u3vgugNy1)

This project is not yet ready to accept code contributions, but it will be open to them in the future. In the meantime, feel free to [open an issue](https://github.com/sasha-pavlov/pomdate/issues), or send me an email at [src@aspavlov.com]() :)

## Attributions

Notification sound: ['*1 - xylophone.wav*' by 14G_Panska_Niklova_Michaela](https://freesound.org/people/14G_Panska_Niklova_Michaela/sounds/422137/)