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
Future work will be asset-related and not greatly effect functionality.

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

### Replace notification sound

1. Create and export your sound according to [playdate specs for sound **samples**](https://sdk.play.date/1.13.1/Inside%20Playdate.html#M-sound).
2. Name your sound 'notif.wav' and place it in 'pomdate/app/assets/sound'
3. Compile and run the app as per the installation instructions above.

Note that some samples may sound significantly different, even *bad*, on the playdate hardware.

## Develop

Class diagram [here](http://www.plantuml.com/plantuml/uml/VLRVRzis47xNNy77hOupO8zU5lJ70in0sWwmkm4hYeAIpj8j52cGHplkblzz9vvaMccI5vlyxdZaz_7knDU1jAVOcQBNrPrkGFL67sjDeFujL6Lq2Ahnkc-n2fURtgCOr280hJls_-77OOOMIKQnvyKZgkjQ1Xuwjq_WGw6iunWUcvQKsoc9kLh9EdQU0gXA6mErWZtu8-CxhpjGpgeEkX9yuCMCDiQLsgWW9pCOw1T6f_qKELLZqAN9aKEXmDRf50M3Gl5Z-GzKL3mK8yNbyh_h2MonXd7CUrFhwb0KRfnhjEhgQeS6hgy7OHQRxPljpKQjr8sD7Sy3QGAU9hnGIy8EV61WEmm-Vs6eYjw3fGHC1bxP06rer7BXeqruchWUx7kmCKs2TUwREFKw1Xb5EuwPKjBRm6wGEnrujPe25AfpDUuGWahdBB8o8y68dRQw0JzZER8OGl21Rp4GOtNqcj3Ptr2RmF3md_XrxBQsWRBhn6QE2fEtaSXPHcKm17OMldTVMDq1pm9vj8teDMpvfpPn89wJKd9InCXybf_vOckmNwwJACMf01AtK_BBhV2KxybPpaLYHF9xQHtXxYZZhpHUNrzVfc429qqOtncdAO4O_XWkfsQmTCu8rZKyRNRtbpXK5MDpVcF9VHXstBXeny8Ap7dSGe1KpZ9C6I33QSV9n_MFwpBdqNFbFAzYqKNgH6ecGwz4q8SiQSJSJJO7fAeLHNL5k0T1OCWP6GvPmvfe8irulNLi-RI-CT219U7pphYPWelGkcZg10zYHrkfNw_5-cGdojo4Z-myA_oCkVFjKpsnX5nEemS7UyH4srgTIQSzgD3oRwtAezB6v8Le0sbRGRXGhWUlIIuxO8T6UtFadL9QI8Uxp45JV-HLXnRvZ88FeSzZyaXHAttnSjRtT1d8yw4pCRcHhoojipjiefydADEgxiGqwljqtZBMCr5BipkJ26XgjfmRnfl6hm4CI_vkS64xZak2NC2K5qzM1OPDMWlr4_VE76t0eJpMTZJFuO-Hpl00z5SBTkjkh2vD_egbSybiI9-jErNVtsjRm_tpLVDGPBBpQZblozbdjJhfn878AUnwprkoPuCb6gJZ1HjqqtXeKjt_LBckTy96-NiRMkm3kvH01m2RGuUKXhoj2gqxMCw7SrkbhHelpbbGclrQy6alMwSaQh5f8T3Im1xCv8jXiALGxwMnplDCQbvQ-GiP9ZtAGmXFNcClbZTL8ZcxhrjTWdbHVzayYPy9JqTBNwdnO97NvzGQa43GdwMZSOTRx93EeDZtZo4-x3vzX4xOOZ-VZb-gTwss3MIwOawiFWaLcQHWBr4K4iyGtC8zbUv-vBXpbiQ2vU6qtU0pzSU0to057HS-5_SMG-uPlpkFtpYUDkSz8_IwOYdF5TJXLEJpxe2sZyGPi9TFw9tSMZPzuDDyRpBww2BD9Rmua_czlkTa8x0iU3SlvvS45N9pukdne9QlyfCeVzzgA6FJo3j17auPkhhgxnfryBhlmSlpIItaKIgxvLJCKPWRMFQOLOXnZHorCg3zxJIhlJwS9cXC3EIPoLiNRHtE5gmd4peRyjAduDZrShHC8uandN26Z--dUKEhJvwAMWmAms1NurFN71dNGlj2bP6KVBuPxRqhWogXSkcr3mm5j1Ke9DNgyPqgVgmduUmzprg6ExIzzhfJZNUnNziMF98U8lnSl0RBtCp_)

This project is not yet ready to accept code contributions, but it will be open to them in the future. In the meantime, feel free to [open an issue](https://github.com/sasha-pavlov/pomdate/issues), or send me an email at [src@aspavlov.com]() :)

## Attributions

Notification sound: ['*1 - xylophone.wav*' by 14G_Panska_Niklova_Michaela](https://freesound.org/people/14G_Panska_Niklova_Michaela/sounds/422137/)