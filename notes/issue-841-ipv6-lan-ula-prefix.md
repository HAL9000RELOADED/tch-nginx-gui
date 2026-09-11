# Issue #841 — "IPv6 no longer assigned on LAN"

Upstream: https://github.com/Ansuel/tch-nginx-gui/issues/841 (still OPEN, never closed by a commit)

Reported repeatedly on TG789MYRvac v2, TG789vac v2, DGA4130, across GUI 9.4.97 -> 9.6.65 (2019-2023).

## Workaround (confirmed working, not a code fix)

```sh
uci set network.globals.ula_prefix=auto
sh /rom/etc/uci-defaults/12_network-generate-ula
```

Forces regeneration of the IPv6 ULA prefix by re-running the uci-defaults
script that normally only fires on first boot / after a factory reset.
Source: comment by FrancYescO, confirmed by the issue reporter, 2019-10-02.

## Why this can't be patched from tch-nginx-gui itself

`12_network-generate-ula` lives under `/rom/etc/uci-defaults/` — part of the
stock Technicolor base firmware (squashfs, read-only), not one of the files
this repo overlays. Confirmed by full-history search:

```
git log --all -S'ula_prefix'   # zero hits, ever
git grep -in 'ula' <tree>      # zero real hits (only false positives:
                                # "particular", "modular", "regular", "calculate")
```

The repo doesn't own or hook uci-defaults execution, so the bug is upstream
in Technicolor's firmware image, out of scope for a GUI-file patch. It could
be worked around permanently by shipping tch-nginx-gui's own init/uci-defaults
script that checks/regenerates `network.globals.ula_prefix` on boot, but
nobody has added one.

## Related IPv6 commits in this repo (full history, none reference #841)

All predate the issue (opened 2019-10-02); none touch `ula_prefix`; none is a
post-hoc fix for this bug.

| commit    | date       | subject |
|-----------|------------|---------|
| 78b85782  | 2018-07-15 | Update 8.6.3 STABLE — "Fix #77 other issue if ipv6 is enabled" |
| c0ec0859  | 2019-01-20 | fix typo that cause internet modal to not open when in IPv6 |
| f23ad8a6  | 2019-02-19 | webui: actually fix ipv6 for TIM isp |
| 4b0e6b57  | 2019-09-06 | webui: pppoe IPv6 (#802) |
| e9550d85  | 2019-09-09 | web: fix some errors with ipv6 (WAN forms + LAN status light in 005_LAN.lp) |
| a70ac032  | 2019-09-10 | web: generalize ipv6 addrs and prefix code (shared WAN prefix helper) |
| 009744fa  | 2019-09-11 | remove useless defs expose concentrator and ipv6 |
| 53607576  | 2019-09-22 | web: small fix to ipv6 |

Open question (unresolved, no direct evidence either way): the Sept 6-22 2019
cluster of WAN/LAN ipv6 refactor commits lands 10 days before the first
"it used to work, now it doesn't" report. Timing is suggestive of a
regression, but none of these diffs touch `network.globals.ula_prefix` or the
uci-defaults generation path — they're display/WAN-prefix code, not LAN ULA
assignment. Not confirmed as the cause.

## Verification commands used

```sh
git fetch upstream
git log upstream/master --oneline -i --grep='ipv6'
git log --all -S'ula_prefix' --oneline
git log upstream/master --oneline --grep='841'
gh api repos/Ansuel/tch-nginx-gui/issues/841/timeline --paginate \
  --jq '.[] | select(.event=="referenced" or .event=="cross-referenced" or .event=="closed")'
```
