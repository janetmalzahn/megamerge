# megamerge

_v. 1.50_

A Stata package for exhaustive 1:1 record linkage on name variables.

## Description

**megamerge** performs up to 16 sequential 1:1 merges in decreasing orders of specificity to match records with names. It's designed for situations where you need to link datasets using name variables (first, last, middle, suffix) but exact matches aren't always possible due to:

- Nicknames (Bob vs Robert)
- Hyphenated or multi-part last names
- Missing middle names or suffixes
- Name changes (maiden names, etc.)
- Data entry variations

Each merge phase tries progressively looser matching criteria, ensuring observations are matched on the most specific information available before falling back to less specific matches.

## Installation

```stata
* Install the github package if you haven't already
net install github, from("https://haghish.github.io/github/")

* Install megamerge
github install janetmalzahn/megamerge
```

To update to the latest version:
```stata
github update megamerge
```

## Requirements

- Stata 15.1 or higher
- Both master and using datasets must have variables: `first`, `last`, `middle`, `suffix`
- Name variables must be string type

## Quick Start

```stata
* Load your master dataset
use master_data.dta, clear

* Merge with using dataset on state and district
megamerge state district using using_data.dta
```

After running, your dataset will have two new variables:
- `merge_code` - indicates which merge phase matched each observation (see table below)
- `matched` - summary indicator (1=unmatched from master, 2=unmatched from using, 3=matched)

## Syntax

```stata
megamerge varlist using filename [, options]
```

### Options

| Option | Description |
|--------|-------------|
| `trywithout(var)` | Try an additional merge without the specified variable from varlist |
| `messy` | Keep all intermediate variables created by megamerge |
| `keepmerges(codes)` | Only perform the merges corresponding to the listed codes |
| `omitmerges(codes)` | Skip the merges corresponding to the listed codes |
| `verbose` | Show detailed output for each merge phase (default shows progress bar) |

## Merge Codes

Each matched observation receives a `merge_code` indicating how it was matched:

| Code | Merge Variables |
|------|-----------------|
| 0 | varlist + first + last + middle + suffix |
| 1 | varlist + first + last + suffix |
| 2 | varlist + first + last + middle |
| 3 | varlist + first + last + middle initial |
| 4 | varlist + first + last |
| 5 | varlist + last word of last name + first |
| 6 | varlist + first word of last name + first |
| 7 | varlist + last + first initial |
| 8 | varlist + last + nickname-standardized first name |
| 9 | varlist + first part of hyphenated last + first initial |
| 10 | varlist + second part of hyphenated last + first initial |
| 11 | varlist + last name (no spaces/hyphens) + first initial |
| 12 | varlist + middle appended to last |
| 13 | varlist + last appended to middle |
| 14 | varlist + last only |
| 15 | varlist (minus trywithout var) + last + first |

### Unmatched Codes

| Code | Description |
|------|-------------|
| 100 | Unmatched observations from master |
| 101 | Omitted duplicate observations from master |
| 200 | Unmatched observations from using |
| 201 | Omitted duplicate observations from using |

## Examples

```stata
* Basic merge on state and district
megamerge state district using data2.dta

* Try an additional round without the district variable
megamerge state district using data2.dta, trywithout(district)

* Only perform exact match and last+initial match
megamerge state district using data2.dta, keepmerges(0 7)

* Skip nickname matching
megamerge state district using data2.dta, omitmerges(8)

* Show detailed output for each merge phase
megamerge state district using data2.dta, verbose
```

## What's New in v1.50

- **Progress bar** - Visual progress indicator during merge (use `verbose` for detailed output)
- **Input validation** - Clear error messages for missing variables, invalid options, and data type issues
- **Unit test suite** - Comprehensive tests for all components
- **Bug fix** - Fixed issue when all observations match before completing all merge phases

## How It Works

Each phase of megamerge:

1. Specifies the variables to merge on for that phase
2. Appends previously omitted duplicates back to the unmatched pool
3. Generates any special variables needed (nicknames, name parts, etc.)
4. Separates duplicate observations (which cannot be 1:1 matched)
5. Performs a 1:1 merge on the specified variables
6. Records the merge code for matched observations
7. Separates unmatched observations for the next phase

Since merges are 1:1, observations that are not unique on the merge variables are set aside as duplicates and given another chance in subsequent phases with different matching criteria.

## Author

**Janet Malzahn**
Stanford Graduate School of Business
jmalzahn@stanford.edu

## License

MIT
