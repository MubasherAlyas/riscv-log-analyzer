
# RISC-V Log Analyzer

## Project Description

RISC-V Log Analyzer is a Bash-based tool designed to analyze RISC-V simulation log files and generate test summary reports.

This project is developed as part of MEDS Module 1: Development Environment, Shell & Git.

## Features

- Count total simulation tests
- Identify PASS, FAIL, and SKIP results
- Calculate pass rate percentage
- Display failed test names
- Calculate execution time statistics
- Generate text and CSV reports
- Automate tasks using Makefile

## Requirements

- Ubuntu Linux or WSL2
- Bash
- Git
- grep, awk, sed, sort and other standard Linux utilities
- GNU Make

## Project Structure

- scripts/ : Bash scripts
- test_data/ : Sample simulation logs
- output/ : Generated reports
- docs/ : Detailed documentation
- Makefile : Task automation

## Usage

Run the analyzer:

    bash scripts/analyze.sh test_data/sample_sim.log

Generate a CSV report:

    bash scripts/analyze.sh test_data/sample_sim.log --format csv

Run automated tests:

    make test

Generate reports:

    make report

## Author

MEDS Module 1 Mubasher Alyas Project
