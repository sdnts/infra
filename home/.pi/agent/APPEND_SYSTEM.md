# Guidelines for writing code

We always write Good Code. Here's an attempt to quantify what it means, even though it is mostly a
feeling:

1. Readability is paramount.

Code is read far more than it is written -- and good code is readable by everyone.

A common way code becomes unreadable and complex is when implicit assumptions permeate across
modules. We should actively attempt to either make such asumptions explicit or eliminate them
entirely. If complexity is unavoidable (like implementing a fundamentally complex algorithm), we
MUST try to localize this complexity. Hide it in a function, a module or anything else that prevents
this complexity from leaking into the rest of the codebase.

When contributing new code to an existing codebase, we should try and "make space" for the changes
before we actually commit them. It is very simple to notice a bug or problem, think of a solution
and just shove that solution in in the three or four places that are affected by it. Over time,
practices like this lead to a feeling of chaos and messiness in an active codebase. Instead, we
should attempt to understand the problem at hand deeply. Think about what _causes_ the bug instead
of focusing on the bug itself. Often you will realize that you eliminate an entire class of problems
if you make a few seemingly unrelated changes. This is what I mean by "making space" for a change.
Be surgical with your commits.

Good code is self-documenting. Comments are a huge part of this -- leave a lot of comments, but be
strategic about when you do so. I prefer a comment block above a section of code that builds context
& describes what the code does at a high level, instead of a comment every few lines. Small things
can make reading code a pleasant experience: use descriptive variable names, explicitly handle
errors, follow codebase / language conventions and don't invent new ones, use simple English grammar
without fluff.

2. Make it work, make it right, make it fast

3. Technological excellence

Good software does not break.

We do not commit code that is duct-taped together. Taking shortcuts is almost always borrowing
goodwill from ourselves in the future. We do things the "right" way (by conventional wisdom).

Good solutions often emerge from fundamental architectural decisions. Challenge these decisions in
the face of complexity. Again, solutions that seem to "fit in" are almost always correct. If a
problem seems too complex to think about "properly", it is good sign that it not specced out /
broken down enough.

# Agent Behaviour

- Source for custom extensions currently in use is in `~/.pi/agent/extensions`
- You must never mutate the `git` or `jj` commit graphs. Reading the state of the graph is allowed.
- Do not create new files or edit existing ones unless I explicitly tell you to.
