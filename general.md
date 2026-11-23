# Memory, docs and comments
The "memory/" folder holds what agents need to know about the project (store memories only there and reference each file in this document). Memory, this document and code comments describe the code as it is now. Git history tells how it got there.
- Write only what lasts and isn't obvious from the code: what the next agent would get wrong without it. Most tasks need no new memory. A detail of one place belongs in a comment there.
- Don't write about incidents (accidents, bugs you fixed, outdated builds), dates, versions, what the code used to do or how you changed it.
- When your change makes something wrong, fix or remove it. When you edit a section, cut what is no longer relevant. Shorter is better.

# Fast, efficient, elegant code
Write fast, efficient, elegant code. Keep code short, simple and easy to reason about.
Avoid small, trivial functions. Avoid functions you only call once (unless there is a good reason).

# Descriptive naming
Prefer long, descriptive names over short ones that don't convey fully what they do.
For function names, prefer verb phrases over nouns (e.g. "findNodeToReuse" instead of "reusableNode").

# LiveTime Programming Language
LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation (never spaces).

# Compile
Check your code with "livetime check", build with "livetime build".

# LiveTime bugs
Work around them until they are fixed:
- A lambda that returns a struct doesn't copy it: `Pos[] heads = selections.map(.head)` shares the objects, and assigning a struct field changes it in place (`s.head = x` is `s.head.assign(x)`). Copy with a loop (`heads.add s.head` clones).

If you find a bug in the LiveTime compiler, add it to this list in lib/core/general.md. Append a test that reproduces it to /Users/heiko/Projects/LiveTime3/src/compiler.livetime.test and add a task to the LiveTime3 project. The task should include removing any workaround in the codebase and the bug's entry in general.md.

# LiveTime pitfalls
- Only files directly in `src/` are compiled, not files in subfolders.
- In `.livetime/targets.lc`, values of `Common` override those of a target.
- Library files are merged alphabetically: a file that adds to a unit (`unit html`) and sorts before the unit's own file breaks it. Start it with `global static class html`.
- Bundles are strict mode: assigning to an undeclared variable throws (use `window.x` in `js` bodies).
- If the app stays empty, run `node --check dist/pb_public/main-v<N>.js`.
- Arguments continued on the next line need a trailing comma.
- Continued parameters must align under the first parameter, otherwise they become the body.
- A comment on an indented line below a member variable becomes its body (the variable turns into a function): put comments above it.
- `switch` cases can't list several values.
- `switch` on `dynamic` needs a cast: `switch (string)message.type`.
- `(dynamic[])(expr).field` casts `(expr)`: assign to a `dynamic` variable first.
- Functions that call themselves need a return type.
- A parameter named like a CSS property (`icon`) is passed as that style in shorthand (`div icon`): use another name.
- An argument whose last name equals a parameter's name is passed as that parameter (`textIn(selection.to, p)` passes `to`): use labels.
- `row`, `column`, `span` and static class names (`file`, `data`, `storage`, `html`, `system`, `app`) can't be variable names.
- Lambdas have implicit parameters (`it`) that hide outer variables: don't name locals `it`.
- Inside `onClick:`, `.` is the event: name the loop variables a handler needs.
- In a one-line lambda, `if c then a; b` puts `b` into the `if`.
- A lambda argument that starts with the name of a function variable (`onClick:close; save`) passes that variable: call it with `close()`.
- Stored lambdas are objects: `js` bodies call them with `.invoke(...)`.
- Function types have no async variant: to await a lambda, take a `stored void()` parameter and `await (dynamic)run()`.
- A `void()` assigned to a field drops the Promise of an async lambda.
- `@` in template literals of `js` bodies escapes identifiers: write `"\x40scope/package"`.
- `inline js` functions are inlined, not emitted: JavaScript can't call them.
- Inline members of event types must be `inline js` with `this.`.
- An `interface` of a browser type (`DragEvent`) gets its methods on the browser's prototype, replacing them: declare them `inline js`. A class of that name hides the browser's.
- `inline` functions substitute their argument expressions: assigning to a field of a parameter changes nothing.
- `list.includes(x)` on objects throws if `x` is null.
- A struct read from a list is a copy: change items in `for s in list` or assign the copy back.
- A method redeclared in a subclass extends the base method (the base runs first); with `override` it replaces it.
- `object.fromYaml` uses YAML 1.2 (`yes` is a string) and returns plain objects unless a mapping is tagged with a class name.

Add new pitfalls to this list in lib/core/general.md.