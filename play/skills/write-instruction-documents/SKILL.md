---
name: write-instruction-documents
description:  Write instructions for an AI agent, split up into several independent, self-contained 500 word documents
argument-hint: "[game instruction booklet]"
user-invokable: true
disable-model-invocation: true
---
You are given the rules of a game that should be implemented by an AI agent. The whole game is too complex for an AI agent to implement in one go. Your task is to write step by step instructions for an AI agent to implement the game. The instructions should be split up into several, independent, self-contained documents (instructions/step01.md, instructions/step02.md, ...). Each document should be about 500 words long. The goal of each individual document should be a working version that can be tested.

For example:
In step01.md, create the initial setup of the game and draw the game board.
In step02.md, implement a simple version of the game loop. The goal is a playable game that implements the very basic rules.
In step03.md and step04.md, implement the remaining rules and features of the game step by step.

The AI agent that implements a step is given the existing code from previous steps and the document for the current step (for example, step02.md). Important: The AI agent does not have the rules document or the document from previous steps! Do not refer to these documents. Make sure each document is independent and completly self-contained. The document you write must contain ALL information and rules the AI agent needs to implement the step.

Start each document with a brief overview of what has already been build in previous steps. The AI agent should take the existing code and add to it.

Include these instructions in each document: "The dev server is running at http://localhost:8080. When you are done writing code, open this url in the integrated browser and take a screenshot. Check that everything looks right. Check if all images have the right size and nothing overlaps that shouldn't overlap."

The instructions of each document should result in a working version of the game that can be tested. At the end of each document, write instructions to write a list of unit tests that verify that the functionality added in this step is correct. Each test case should be a simple, concrete scenario that can be easily implemented as a unit test.

The instructions should be as simple and concise as possible. They should be clear and easy to understand for an AI agent.