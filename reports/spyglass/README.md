# SpyGlass Review Summary

The public repository intentionally omits raw SpyGlass logs and the generated `.prj` file.
The reviewed results are documented in `docs/SpyGlass_Waiver_Report.pdf`.

| Goal / Report | Generated | Waived | Reported | Applied Waivers |
|---|---:|---:|---:|---:|
| Lint / lint_rtl | 7 | 4 | 3 | 3 |
| CDC Verify | 58 | 5 | 53 | 4 |
| CDC Verify Struct | 50 | 1 | 49 | 1 |
| Clock / Reset Integrity | 11 | 2 | 9 | 1 |

The lint run generated three informational messages and four actionable findings. The four findings are covered by three reviewed waiver definitions because the same clock-divider rule applies to both RX and TX divider instances.
