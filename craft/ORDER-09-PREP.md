# ORDER-09 amber buttons — status before change

**Verified:** 2026-09-02T01:47Z
**Tribe stance:** KEEP GOING (Rosa + Daddy G)

## Pre-change inventory
- Solid `bg-amber-500/600`: **26 occurrences** (9 in `<button>` elements)
- Status dots/semantic amber: **17** (leave unchanged)
- Button backgrounds (to convert): 9 (see below)
- `--color-primary` in use: `hsl(35 50% 28%)` (brown)
- `--color-mule-primary` (new): `#C68A4E` + hover `#B57A3F`
- Tailwind: v4 (confirmed `@import "tailwindcss"` in index.css)

## Files to change
1. `src/index.css` (add token + utility)
2. Button sites:
   - PropertyHistoricalsPage.tsx:209 (`bg-amber-500`)
   - PropertyInfrastructurePage.tsx:400, 444, 519, 612 (`bg-amber-600`)
   - MaintenanceHistoryPage.tsx:668, 689 (`bg-amber-500`)
   - StaffViewPage.tsx:125 (`bg-amber-500`)

## Safe backup plan
- `.bak` files beside each edit
- Record exact changes here
- Verify counts after
- Ship as real `.md` file first

## Worktree state difference
- Spec expects clean `main` branch → reality is 274 dirty files on `desk/iris/order-01-invisible-text`
- Will edit in place (cannot safely checkout)
- PR will open from current branch

**Per Rosa:** "trust the process. stick to pack." Executing safe, surgical edits now.