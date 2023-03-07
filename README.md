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

Class diagram [here](http://www.plantuml.com/plantuml/uml/VLRRRkGs37ttL-YntMHIe8_JDDXB0tI0x6w1cMs1BXQ1R7DiDh8aw3ANRVFlfKHxD0wIF5awf2YT8vBMMn-a2t5GbPNDW-n0M2MFhGmW_gr4ewJtedFIzjZugxLro0PnuI6i1lB_uSSqGus1Hz7IuX6LRSi31uFPPV2n4jfG38TT7uJP2ewvNF8wSfu2Y4Og1Qs07RWZuLid1n16Ym666fodnOHsojHI2SydK-Z3BuHE-ubWH8jUrgf4zfK0tUPJL0GonS_rFz24wh4QAIuM_zrCO8yjZ6FQE_IczLLbnhb4BQwljwZWvYO9Sx7UlDlShiLItEeuq9pq3K3JZ5TY4N2WmnEmIOEltmXgedEWGmOc0wti8Am3QqaAHftnF34Mz4VGCK-yDkOxEraPFO-Y7iT4AUkjO9lbJWTUBgS0bHXCYri4B_8vgvCoXQ2M7Tn7dB5Se2P_tIHYNrOViuyxaKkHoN27FX3MHYS36lqRIfLufs-cFP3RYk8Kruda76M2xsC8HXFAWnJOQ7ZgphAbBVwKAYR-9JSvDLcJGclnbUwt1Vtj9cjJdUeWSpdL05yEJUcwZAQK38HmcYz8CDmUUNmVnbkqxLKUPd3IWF2jCZ9a4FqVwOvQ0cjZ56D3HzDkUxZ2L5nZeNrA6wnDr6CvUQ8uHcGW5p4FyxtpSDfWyZ7sQJMEsVDA4SzhbsNWwk1AAT0Rrk-nA1Ynz93r7aFJiu2o2RW3HY2b10yfAP84CWH9UBinERbk5GoW0_FveCnCi0lVcwZQ32Tjesx4hpTiVRR_56xCXtUUbNl1JDb-x5eaOIeYzg1WJvX8tOepwQG3uNlfwCJrKKYboiAfVlobC1RILUgEO8y3AkdKaNRAMS1zxQe4pLsHLkrxf3CodaAVnwIH23rtmwjPjvEr3uuENOZnZToJj4PliOjkdez4gtbWqwZlysbAc2MYEipkZ2EWQiboRXXl6kyzA9ByGt8XEuvBF5_0iiXreUK01D3fMIZAXNLU2-qpzquSjSTK7YizckVmvnZES0_XhnxqnjngMQloxyhdubbAduqvLT_VAzt2uUMgUQmAsNcrd3VZuhDSddIYGC487AoZBScpmneLXkCb6MJNEUXotV_KcC4QPYFSGViUhIUN6i8UG9VGFgSXRIkeLlQQyk7SraWjneip6eGalnvStaktEObwx7hmOQ5W1shoHPzibIZDVvvdNFFSgL_9CEvH3hn_zXejMzurYUJylkva3UfL_NdpB7uXF1qj_uJ6WqLQNr8h8Jw0FKj7PVPtE60uWwArJo4wx2x_SqxOnMu-7NzC7tgfEoXqivbPVM4gFCd1NgF895uWk853gCrXvBWrEem5IyDfk-GpzKUFto45dHQ-5FSEVUaPlnk7tocULESzmrlPa9Jd2af_Al9vTq1jOw0CsF4Vyu5lhPW-qMdc9evtD37C9Rmya_cZF52o1T0a-30lvzS4PN9FY3zMwP7mfZo4ol-jXJfs7JyB-BbKeEjh-z29lPFMWkD7axZWfoZlLbAnH25keCbZLY7AT7pKHe5qTzEiTN9_cg1ICNNs0E_JAy6VBLXD9ZJQbwNFmN6mVBH28uindN26ytDftj1ETWeNUlG2VRAByO6hZeHBfdqfwXW4_xu9jSxKNjJGcFp61u8ywWO41j7ByNNAVgHdmDahdhJq3wYjT78GdJFHhdGF3lc5-dFr5ZHnK_y34dz7c-9ImlEPp1_r0oTR16B1ksKvdn9KoBqW_bGaLAkhATEdzws6CZMDFFtojJT1bvVkhb47hvq3FtmTdScNffmsfUBCYre1yOf5XHZRo5Kh0zhVZBFQwyFp18r9VMUFyCucgiDimsOqeQKmRNqDJfqRX1XfY1ZZ3HVubJptouOssjbTR34e3BrT3L-hviYu5jhdganHoVFDgFEs3Ag4okPFUCXl8LMWCAfM3z-YiexrZBZuI6SjmnsIqrvtgl4skGsru56-H7ygtW0nD_CV)

This project is not yet ready to accept code contributions, but it will be open to them in the future. In the meantime, feel free to [open an issue](https://github.com/sasha-pavlov/pomdate/issues), or send me an email at [src@aspavlov.com]() :)

## Attributions

Notification sound: ['*1 - xylophone.wav*' by 14G_Panska_Niklova_Michaela](https://freesound.org/people/14G_Panska_Niklova_Michaela/sounds/422137/)