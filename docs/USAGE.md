
# RISC-V Log Analyzer — Usage Guide

## 1. Overview

The RISC-V Log Analyzer is a Bash-based tool for analyzing RISC-V simulation test logs.

It extracts test results, calculates pass rates, identifies failing tests, and reports execution-time statistics.

## 2. Requirements

- Linux or WSL Ubuntu
- Bash
- GNU grep
- GNU awk
- sed
- Git
- Make

## 3. Installation

Clone the repository or open the project directory.

```bash
cd riscv-log-analyzer
make setup
```

## 4. Analyze a Log File

```bash
./scripts/analyze.sh test_data/sample_pass.log
```

## 5. Command-Line Options

| Option | Description |
|---|---|
| --help | Display usage instructions |
| --format text | Generate a text report |
| --format csv | Generate CSV output |
| --output PATH | Save output to a file |
| --verbose | Enable detailed processing information |

## 6. Examples

Text analysis:

```bash
./scripts/analyze.sh test_data/sample_fail.log
```

CSV analysis:

```bash
./scripts/analyze.sh test_data/sample_pass.log --format csv
```

Save report:

```bash
./scripts/analyze.sh test_data/sample_pass.log --output output/report.txt
```

Verbose mode:

```bash
./scripts/analyze.sh test_data/sample_pass.log --verbose
```

## 7. Makefile Commands

```bash
make setup
make all
make test
make report
make clean
make help
```

## 8. Exit Codes

| Code | Meaning |
|---|---|
| 0 | No failed tests |
| 1 | One or more tests failed |
| 2 | Invalid arguments or input file |

## 9. Output Files

Generated reports are saved in the output directory.

These files are ignored by Git, except for .gitkeep.

## 10. Troubleshooting

If permission is denied:

```bash
chmod +x scripts/*.sh
```

If the script reports a syntax error:

```bash
bash -n scripts/analyze.sh
```

If a dependency is missing:

```bash
make setup
```