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

Class diagram [here](http://www.plantuml.com/plantuml/uml/XLRRRkCs47tNL_2nRU8KwAER1dlP03MGlG3sja2B8g2aiJGDDIHuYUEq-VUEE58a1LdtnIRFa4EUCnVgJOZQnzIPmkdgJZUWdD77MaTG_nIgCZe4rNZjMgp2nTPv58Cw2n0t7Q__xlj-XeHHHidnvW7LTIq33vszp-1JeSYo3uzD6vNTA_6vNii-NZmwK9Ks1ce5z-2FZE-zxa1PKXrq9VZ0cnbjZ2srKK5kPZ34dnaTprFHgXg3BitaEHGAgCwtA1WKYf_Blw6AnLCnK5oj_hqQmHPh6CPyTcnj7OgYi0EWaTJbvHuDN5trofnjTsztrrkrLjUKEfwpm15ucl52hHBovElceoPMppCGiMCw3ExwmPz_CLGbxu5Y1aO3kseWRgEeovecodYUM0Vq4IZnvAd80XlOPttx2wxNexrGdQrnZn1KlbSnII5AJ3TZLW6fCH0j2JMrGk9TLC6ImKYXFu0jDnXY3zR9wuYMFg0sWV7-dzcnfUE56tOrMpooUG47ilOHtgKOBJ4iW-pS4hooePUeF-StRTA9r7mgPZnNgn-oIiLp2MGwO_gB-iA_iiJP61aHvokM3lT76T_68LokliZ338ugCButLiSCTYpaXyc0931s3S-Q_SC5zgKrbDcd_eojJJGK4qFZNW6Qbq2kQHawdS898PQbALGb-QKG19ffz3Ifb71g4Ti3ngeLaNGLyHu40GxyO9JGt-eODUFrpkOakZRG0SLyl_3Us00ruwMr9XDfRJ9rXdlz4bNgboknljvUba4UJbvKyuJPsV7IbA9rN3B32dRsWeccMisaqnvKQFctLkLHQMEcZMETX7Db7VIXeORXW1qQxSsHJyfXbhPrCJdDJOzt7LhaEmgk69hxv96AhJIxYqKpqsM8dYyz4PE8tBAqblRO93-Jbt6cLTs9QT3tzJnap35HYekOYGSqDLlcXY7IU1l0iEJl-oMpB0yIWFKarndf3XZWsxDGaWlRl1VgL-BE72bWd-uR6inB-7EACpn0_Bq5sjbhqgMPdgPyBvdrwREpp-NrnuPgU3ZLFYQoosgPjzvfpNhzh1CxYbPXvpmVoIiRBD5WF9wpGJUDXoRNyO-LxPmLDie_K6ZH1LvIGZm0qEGwv3JaOpaLxO4u7-QsIfCQ0cS9bEPrBVXy5jKvYLfiEBNZoi0zc74jXjvMgAb9BlDCQbwQySaCupX-yH32gs5qOdbRPPABUDte4in9_UNmBFv4UBnQVcg6YoNUFqijHa84Dqj7Omyts66SGScvbn1VzZu_Ai_OsVqqdRqyxrjD3KnqHpEp-YfKPFA_BvIG-0R17Jp4qZuC7FUMub2mF1oFwzUC_J7W8sIduyPl-ELdTEePlrgFZ-nFctdF24vNBELSGHsUYtpP7P1SYbzOEdaLxoHga-aJtsPf4dz7c-9ImlEPp1_r0oTR16B1ksKvdn9KoBqW_bGaLAkhATEdzws6CZMDFFtojJT1bvVkhb47hvq3FtmTdScNffmsfUBCYre1yOf5XHZRo5Kh0zhVZBFQwyFp18r9VMUFyCucgiDimsOqeQKmRNqDJfqRX1XfY1ZZ3HVubJptouOssjbTR34e3BrT3L-hviYu5jhdganHoVFDgFEs3Ag4okPFUCXl8LMWCAfM3z-YiexrZBZuI6SjmnsIqrvtgl4skGsru56-H7ygtW0nD_CV)

This project is not yet ready to accept code contributions, but it will be open to them in the future. In the meantime, feel free to [open an issue](https://github.com/sasha-pavlov/pomdate/issues), or send me an email at [src@aspavlov.com]() :)

## Attributions

Notification sound: ['*1 - xylophone.wav*' by 14G_Panska_Niklova_Michaela](https://freesound.org/people/14G_Panska_Niklova_Michaela/sounds/422137/)