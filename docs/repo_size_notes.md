# Repository Size Notes

The heaviest files in this repository are large place gallery images inside `assets/places/`.

Examples:

- `assets/places/horton_plains/1.jpg`
- `assets/places/horton_plains/2.jpg`
- `assets/places/ella/2.jpg`
- `assets/places/kandy/cover.jpg`
- `assets/places/unawatuna/cover.jpg`

## Safe Next Cleanup Pass

1. Resize oversized JPG files to mobile-friendly dimensions.
2. Recompress gallery images while preserving visible quality.
3. Keep cover images smaller where possible.
4. If needed later, rewrite Git history only after confirming the repo state and backup plan.

This should reduce clone size and make the repository feel more professional for portfolio and CV review.
