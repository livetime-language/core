---
name: create-with-test
description:  Create new feature that makes a given unit test pass
user-invokable: true
argument-hint: "[test function]"
---
# Implement a New Feature with a Test

1. The given unit tests specifies the expected behavior of the new feature. Use the vscode's build-in tool (execute/runTests) or the runTests tool to run the given unit tests and analyze the output carefully.

2. Analyze the code carefully. Before you write code, think about the shortest, simplest, most efficient way to implement the new feature. Then implement the new feature.

3. Run the unit test again and carefully analyze the output. Repeat steps 1-3 until all unit tests are passing.