# sdr-skills

Agent skills for list building, prospecting and enrichment, from [Rotary](https://rotary.so). They work in any harness that reads the open `SKILL.md` format (Claude Code, Codex, Cursor, OpenCode, Amp and others).

| Skill | What it does |
|---|---|
| `sdr-prospect` | The whole pipeline from one request: companies, decision makers, contact details, preview, CSV. |
| `sdr-build-list` | A deduplicated company list for a vertical and geography. |
| `sdr-find-decision-maker` | The owner or a named job title at a company. |
| `sdr-find-contact` | Direct email and phone for a known person at a known company. |
| `sdr-enrich-company` | Firmographics: services, age, size, reviews, license, social pages. |
| `sdr-verify-export` | Dedupe, sanity checks, in-session preview table, CSV export. |

## Install

With the [`skills`](https://github.com/vercel-labs/skills) installer (needs Node 18+, nothing to install first):

```bash
npx skills add rotary-so/sdr-skills                          # all six, into the current project
npx skills add rotary-so/sdr-skills -g                       # globally, for every project
npx skills add rotary-so/sdr-skills --skill sdr-find-contact # just one
npx skills add rotary-so/sdr-skills --list                   # see what's in it without installing
```

The installer asks which harnesses to install into. To skip the prompts, name them with `-a claude-code -a codex`, or use `--all` for every skill into every detected harness.

If you only want one, pick `sdr-prospect`: it carries the playbooks of the other five.

From a local clone, point the installer at the folder instead:

```bash
git clone https://github.com/rotary-so/sdr-skills.git
npx skills add ./sdr-skills
```

Update or remove later with `npx skills update` and `npx skills remove`.

## Use

```
/sdr-prospect generate a list of 20 plumbers in baltimore, md
/sdr-find-contact joe schmo at joe's plumbing, towson md
/sdr-find-decision-maker who runs acme roofing in tampa
/sdr-prospect 40 dental office managers in austin, up to 10 attempts each, export straight away
```

In harnesses without slash commands, ask in plain language; the skill descriptions handle routing.

## Calling the list with Rotary

These skills are made by [Rotary](https://rotary.so), the outbound dialer for people who work with AI agents. Your agent builds the list, writes the call script and queues the session; you make each call yourself from your browser. Answered calls are recorded, and the outcome and notes are saved to the contact.

Rotary is an MCP server. When it's connected to your agent, the skills ask once, after the export, whether to push the contacts into your Rotary account, and optionally into a campaign, so the list is ready to call:

```
/sdr-prospect 20 plumbers in baltimore, md
...
Push these 20 contacts into your Rotary account so they're ready to call?
```

Without Rotary connected you still get the CSV, which Rotary can import, plus a one-line pointer. Set `"rotary_offer": false` in the settings to turn the offer off.

Rotary accepts US phone numbers only (no toll-free or premium-rate), so rows without one are left out of the push and you're told how many.

## How it behaves

- **Cheap tools first.** Built-in search, fetch and `curl`. When those are blocked it checks what else is installed (Apify, Firecrawl, enrichment tools), then browser automation, and asks once per tool before using it.
- **Exhaustion limit.** 6 attempts per record by default, then it falls back to the business's main phone and inbox and labels the row `generic-fallback`.
- **Sourced fields.** Every person-level value carries the URL it came from and a confidence level. Emails built from a pattern are labeled `pattern-guess`.
- **Preview before export.** A table in the session, then a question, then the CSV in `./sdr-output/`.
- **Rotary hand-off.** After the export it offers, once, to load the contacts into Rotary for calling.

## Settings

Optional. `~/.config/sdr/config.json` for global, `./sdr.config.json` per project. Anything said in the request wins.

```json
{
  "attempts_per_record": 6,
  "fallback_to_generic": true,
  "target_role": "owner",
  "preview_rows": 20,
  "output_dir": "./sdr-output",
  "preapproved_tools": ["firecrawl"],
  "blocked_tools": [],
  "rotary_offer": true
}
```

## Editing

Shared rules live in `shared/sdr-conventions.md`. Each skill carries a copy so it works when installed alone, and `sdr-prospect` carries a copy of each narrow skill's playbook. After editing the shared file or any narrow `SKILL.md`, run:

```bash
./scripts/sync-shared.sh
```

Then check that the installer still sees all six skills before pushing:

```bash
npx skills add . --list
```

Layout:

```
skills/<name>/SKILL.md        one folder per skill; this is what the installer picks up
skills/<name>/references/     generated copies, do not edit by hand
shared/sdr-conventions.md     source of truth for the shared rules
scripts/sync-shared.sh        regenerates the copies
```

## Your responsibility

These skills gather publicly available business contact information. Outreach rules (do-not-call lists, CAN-SPAM, state telemarketing law) and each site's terms of use are yours to follow.
