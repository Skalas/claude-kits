---
name: writing-voice
version: 0.1.0
description: |
  Review and rewrite documents, blog posts, and long-form writing to match
  your personal voice, maintain internal consistency, and strip AI-generated
  patterns. Uses a voice fingerprint at my-voice.md (extracted once from your
  writing samples) to emulate your style accurately.
license: MIT
compatibility: claude-code
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# writing-voice

Review long-form writing — blog posts, essays, technical docs — for three things, in this order:

1. **Internal consistency** inside the document
2. **Voice emulation** matching the user's personal style (from `my-voice.md`)
3. **Anti-AI floor** stripping generic slop patterns

## Pick a mode

On invocation, check `my-voice.md` in this skill's directory.

- If `my-voice.md` still contains `{{UNFILLED}}` markers, run **BOOTSTRAP MODE** first. You cannot emulate a voice that has not been extracted yet.
- If the user passed a document path or inline text, run **REVIEW MODE**.
- If the user explicitly asks to rebuild the fingerprint, run **BOOTSTRAP MODE** again.
- If unclear, ask.

---

## BOOTSTRAP MODE — build the voice fingerprint

Goal: read 3–5 of the user's own writing samples from `samples/` and write a detailed voice profile to `my-voice.md`.

### Steps

1. List files in `samples/`. If fewer than 3 are present, stop and tell the user to drop 3–5 of their own blog posts, essays, or long-form pieces there (plain `.md` or `.txt`). Point them at the skill's `samples/` folder path.
2. Read every sample in full.
3. Analyze the following dimensions. Be specific — quote short phrases from the samples when they illustrate a point.
   - **Sentence length**: average, range, distribution. Short+punchy, long+flowing, or mixed?
   - **Rhythm**: how short and long sentences alternate. One-sentence paragraphs? Fragments?
   - **Paragraph openings**: jump straight in, set context, use a hook, anecdote first?
   - **Punctuation habits**: em dashes, parenthetical asides, semicolons, ellipses, lists vs. prose.
   - **Vocabulary level**: casual, academic, technical, mixed. Specific words they reach for.
   - **Recurring phrases and verbal tics**: constructions they use repeatedly.
   - **Transitions**: explicit connectors ("however", "so") or implicit (just start the next point)?
   - **Self-reference**: do they use "I"? How often? In what moves?
   - **Humor / tone**: dry, earnest, ironic, blunt, warm. Cite examples.
   - **Openings and closings**: how pieces start and end. Any pattern?
   - **Opinions**: state positions plainly, hedge, lean into mixed feelings?
   - **Formatting habits**: headings, bullets, bold, code. When and how much.
4. Write the profile to `my-voice.md` using the template structure already there. Replace every `{{UNFILLED}}` marker. Add short quoted examples under each section where possible — concrete examples beat abstract descriptions.
5. Tell the user what changed, show the path to `my-voice.md`, and offer to refine any section.

---

## REVIEW MODE — three passes on the document

Read `my-voice.md` first. Then read the target document in full. Apply the passes in order.

### Pass 1 — Internal consistency

Check the document against itself, not against voice.

- **Terminology**: same concept, same word. Flag places where the doc switches between synonyms for the same thing (e.g. "user"/"customer"/"client", "endpoint"/"route"/"handler", "agent"/"assistant"/"bot").
- **Casing and formatting**: product names, acronyms, code identifiers — consistent casing and styling throughout.
- **Tense and person**: pick one and stick with it. Flag drift (e.g. essay shifts from "I" to "we" to "you" mid-section without reason).
- **Tone drift**: sections that are noticeably more formal or casual than the rest.
- **Heading hierarchy**: levels used consistently. No jumps from H2 to H4.
- **List parallelism**: bullets in a list share grammatical form.
- **Claims and numbers**: internal contradictions. If the intro says "three reasons", make sure there are three.

Report findings as a short list of specific line references. Propose fixes but do not apply them yet — the user may want to approve changes before the voice and anti-AI passes reshape the prose.

### Pass 2 — Voice emulation

Using `my-voice.md`, rewrite sections that drift from the user's voice. Rules:

- Match the user's sentence-length distribution, not a generic "vary sentences" rule.
- Replace vocabulary that sits above or below the user's normal register.
- Preserve recurring phrases and verbal tics where they fit — they are signal, not noise.
- Keep the user's punctuation habits, even if unusual. Don't normalize toward a textbook.
- Don't add structure the user wouldn't. If they rarely use H3s or bullets, don't introduce them.
- Don't sand off opinions. If the user states positions plainly, keep them plain.
- Don't rewrite passages that already sound like the user. Unnecessary edits are worse than no edits.

### Pass 3 — Anti-AI floor

Apply these patterns as a last pass to catch slop the first two passes missed.

- **Inflated significance**: "stands as a testament", "marks a pivotal moment", "underscores the importance" → delete or rewrite plain.
- **Superficial -ing tails**: sentences ending in "highlighting / ensuring / reflecting / fostering..." → drop the tail or turn it into a clause.
- **Promotional tone**: "vibrant", "rich", "groundbreaking", "seamlessly", "nestled", "in the heart of" → cut or specify.
- **Vague attribution**: "experts say", "industry observers note", "many argue" → name a source or remove.
- **Copula avoidance**: "serves as / stands as / functions as / represents" → use "is".
- **Rule of three**: forced triplets that inflate the sentence → cut to the real point.
- **Em dash overuse**: more than one per paragraph on average → swap most for commas, periods, or parentheses.
- **Boldface in running prose**: remove unless scanning-critical.
- **Title Case In Headings** → sentence case.
- **Emojis in headings or bullet openers** → remove.
- **Filler phrases**: "in order to" → "to"; "at this point in time" → "now"; "due to the fact that" → "because"; "has the ability to" → "can".
- **Generic positive closers**: "exciting times ahead", "the future looks bright", "a step in the right direction" → replace with something specific or drop.
- **Knowledge-cutoff / chatbot artifacts**: "as of my last update", "hope this helps", "certainly!", "let me know if..." → delete.
- **Negative parallelism**: "it's not just X, it's Y" and tailing negations ("no guessing", "no wasted motion") → rewrite as a regular clause.
- **Persuasive authority tropes**: "at its core", "the real question is", "fundamentally" → cut the framing, state the point.
- **Signposting**: "let's dive in", "here's what you need to know" → delete, just make the point.
- **Curly quotes** (" … ") → straight quotes (" ... ").

### Output

Present in this order:

1. **Consistency findings** — bullet list, line references, proposed fixes.
2. **Voice-drift rewrites** — before/after for each section that needed a real rewrite. Do not fabricate drift where there isn't any.
3. **Anti-AI fixes** — grouped by pattern; short diff blocks.
4. **Final revised document** — the full rewritten doc, ready to paste.
5. **Self-audit** — prompt yourself: "what still sounds off?" Answer in 2–3 bullets, then revise once more if the answer isn't "nothing".

## Notes

- If `my-voice.md` contradicts what you see in the live document, trust the document (voices evolve) and flag the discrepancy so the user can refresh the fingerprint.
- If the user provides fresh samples inline with the request, prefer those for this review — and offer to rerun BOOTSTRAP MODE if they want the fingerprint updated.
- Never invent biographical facts, quotes, or citations. If the document has a gap that a human author would fill from memory, flag it, don't fabricate.
