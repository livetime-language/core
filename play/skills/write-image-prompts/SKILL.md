---
name: write-image-prompts
description:  Write image generation prompts for a board game based on the instruction booklet
argument-hint: "[game instructions, rules and images]"
user-invokable: true
disable-model-invocation: true
---
# Analyze
You are given the instructions of a board game. We are creating a digital version of this board game. Analyze the given instruction booklet, rules, and images thoroughly. Make sure you have a deep understanding of the game and all its components.

# Write
In "docs/images.md", write a complete list of all images that need to be created for a digital version of the game. The image name should be short and contain only letters and the number of the player if it's a player piece. For each image, write a very detailed prompt for the AI image generation model "Nano Banana" to generate the image. 

- Include the perspective. Make sure all images have the same perspective.
- Include the shape. Make sure all images that need to have the same shape have the same shape.
- The style of the image should be "hand-painted".
- Player-specific pieces should include the player color: the color of player 0 is #398CA9, the color of player 1 is #C01352. 

For example:
DinosaurPlayer0: A board game piece in the shape of a dinosaur. The dinosaur should wear a hat in the color #398CA9. Hand-painted style. Transparent background.

# Check
3. Double check that images.md contains all the images you need to create a digital version of the game (boards, pieces, cards, buttons, UI elements,backgrounds, etc).
