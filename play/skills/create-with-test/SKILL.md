---
name: create-with-test
description:  Create new feature that makes a given unit test pass
argument-hint: "[unit tests]"
user-invokable: true
disable-model-invocation: true
---
# Implement a New Feature with a Test

1. The given unit tests specify the expected behavior of the new feature. Use vscode's built-in test-runner tool execute/runTests or the runTests mcp server to run the unit tests and analyze the output carefully.

2. Analyze the existing code carefully. Before you write code, think about the shortest, simplest, most efficient way to implement the feature. Avoid code duplication.

3. Implement the feature.

4. Run the unit test again and carefully analyze the output. Repeat until all unit tests are passing.