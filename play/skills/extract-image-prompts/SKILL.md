---
name: extract-image-prompts
description:  Create image generation prompts for a board game based on the instruction booklet
argument-hint: "[game instruction booklet]"
user-invokable: true
disable-model-invocation: true
---
You are given the instruction booklet of a board game. We want to create a digital version of this board game. 

1. Read the instruction booklet carefully and make sure you have a thorough understanding how the game is played.

2. In "docs/images.md", write a complete list of all images that need to be created for a digital version of the game. For each image, write a detailed prompt for the AI image generation model "Nano Banana" to generate the image. The style of the image is "hand-painted". Player-specific pieces should include the player color: the color of player 0 is #398CA9, the color of player 1 is #C01352. For example:

DinosaurPlayer0: A board game piece in the shape of a dinosaur. The dinosaur should wear a hat in the color #398CA9. Hand-painted style. Transparent background.

3. Double check that images.md contains all the images you need to create a digital version of the game (boards, pieces, cards, UI elements, backgrounds, etc).

