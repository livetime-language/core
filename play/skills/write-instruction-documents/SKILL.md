---
name: write-instruction-documents
description:  Write instructions for an AI agent, split up into several independent, self-contained 500 word documents
argument-hint: "[game instruction booklet]"
user-invokable: true
disable-model-invocation: true
---
You are given the rules of a game that should be implemented by an AI agent. The whole game is too complex for an AI agent to implement in one go. Your task is to write step by step instructions for an AI agent to implement the game. The instructions should be split up into several, independent, self-contained documents (instructions/step01.md, instructions/step02.md, ...). Each document should be about 500 words long and contain all information needed for that step. The goal of each individual document should be a working version that can be tested.

For example:
In step01.md, create the initial setup of the game and draw the game board.
In step02.md, implement a simple version of the game loop. The goal is a playable game that implements the very basic rules.
In step03.md and step04.md, implement the remaining rules and features of the game step by step.

Make sure each document is independent and completly self-contained. The AI agent that implements step02.md is only given step02.md and nothing else. The document must contain ALL information the AI agents needs to implement the step. Repeat information from previous steps if needed.

The instructions of each document should result in a working version of the game that can be tested. At the end of each document, write instructions to write several unit tests. Write a list of test cases to verify that the implementation of that document is correct. Each test case should be a simple, concrete scenario that can be easily implemented as a unit test.

The instructions should be as simple and concise as possible. Do not write too much information in a single instruction, split it up instead. The instructions should be clear and easy to understand for an AI agent.