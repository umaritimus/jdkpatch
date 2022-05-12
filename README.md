# jdkpatch

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with jdkpatch](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with jdkpatch](#beginning-with-jdkpatch)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

jdkpatch puppet module assists in deploying JDK patches for the PeopleSoft installation

## Setup
### Setup Requirements

Ensure that prior to execution of jdkpatch, you define the jdk_patches hash in you dpk hiera following psft_patches format, e.g.

```yaml
---
jdk_patches:
  27838191: "//share/patches/27838191 - Oracle JDK 11/p27838191_110000_MSWIN-x86-64.zip"
```

### Beginning with jdkpatch

To use jdkpatch puppet module, add references to jdkpatch into your dpk profile or call it ad-hoc using

```cmd
puppet.bat apply -e "include jdkpatch"
```

## Limitations

Currently, jdkpatch only works on windows

## Development

Please submit a PR to contribute new functionality or a fix.
