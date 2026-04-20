---
name: generate-images
description: Generate images for a digital board game with given prompts
argument-hint: "[list of prompts]"
user-invokable: true
disable-model-invocation: true
---
For each prompt in the given list of prompts, generate the image with that prompt. Save the generated image as a png in the "media" folder. Use the image name as the filename, for example "media/DinosaurPlayer0.png".
