Please review and condense the project memory: the files in the "memory/" folder and their index in AGENTS.md. The goal is a shorter memory that is still correct.

Keep only what lasts and isn't obvious from the code: what the next agent would get wrong without it. Most tasks need no memory.

For every file:
- Check each statement against the code. Update what is outdated, remove what is wrong or refers to code that no longer exists.
- Remove what is obvious from the code: descriptions of what a function does, lists of names, step-by-step flows.
- Remove what has become irrelevant: incidents, dates, versions, what the code used to do, how something was changed, plans.
- Remove duplicates: keep a fact in the one file where an agent would look for it, and link to it from the others. Remove facts that AGENTS.md or a code comment already states.
- Keep what is not in the code: reasons for decisions, constraints, pitfalls, how to test.
- Put each issue on its own line. Prefer short sentences.

Split files that cover several topics, merge files that are too small to stand alone, and keep the index in AGENTS.md short and up to date. Don't change any code.

When you are done, report the word count of the memory before and after (`wc -w memory/*.md`) and list what you removed or changed that the user might want to keep.
