#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard:092d034713aff237cf07ef28c22a46a113d1a59dc7ec6d71beb72295044a46f8
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 32768
    ramMax: 32768
    tmpdirMin: 1000
    tmpdirMax: 1000
    outdirMin: 1000
    outdirMax: 1000

class: CommandLineTool

inputs:
  - id: AMPLICON_INTERVALS
    type: File
    inputBinding:
      prefix: AMPLICON_INTERVALS=
      position: 10
      separate: false

  - id: CUSTOM_AMPLICON_SET_NAME
    type: ["null", string]
    inputBinding:
      prefix: CUSTOM_AMPLICON_SET_NAME=
      position: 11
      separate: false

  - id: CLIP_OVERLAPPING_READS
    type: string
    default: "true"
    inputBinding:
      prefix: CLIP_OVERLAPPING_READS=
      position: 12
      separate: false

  - id: COVERAGE_CAP
    type: long
    default: 200
    inputBinding:
      prefix: COVERAGE_CAP=
      position: 13
      separate: false

  - id: INPUT
    type: File
    format: "edam:format_2572"
    inputBinding:
      prefix: INPUT=
      position: 14
      separate: false

  - id: METRIC_ACCUMULATION_LEVEL
    type:
      type: array
      items: string
      inputBinding:
        prefix: METRIC_ACCUMULATION_LEVEL=
        position: 15
        separate: false
    default:
      - "ALL_READS"
      - "LIBRARY"
      - "SAMPLE"
      - "READ_GROUP"

  - id: MINIMUM_BASE_QUALITY
    type: long
    default: 20
    inputBinding:
      prefix: MINIMUM_BASE_QUALITY=
      position: 16
      separate: false

  - id: MINIMUM_MAPPING_QUALITY
    type: long
    default: 20
    inputBinding:
      prefix: MINIMUM_MAPPING_QUALITY=
      position: 17
      separate: false

  - id: NEAR_DISTANCE
    type: long
    default: 250
    inputBinding:
      prefix: NEAR_DISTANCE=
      position: 18
      separate: false

  - id: OUTPUT
    type: string
    inputBinding:
      prefix: OUTPUT=
      position: 19
      separate: false

  - id: PER_BASE_COVERAGE
    type: ["null", File]
    inputBinding:
      prefix: PER_BASE_COVERAGE=
      position: 20
      separate: false

  - id: PER_TARGET_COVERAGE
    type: ["null", File]
    inputBinding:
      prefix: PER_TARGET_COVERAGE=
      position: 21
      separate: false

  - id: REFERENCE_SEQUENCE
    type: File
    format: "edam:format_1929"
    inputBinding:
      prefix: REFERENCE_SEQUENCE=
      position: 22
      separate: false
    secondaryFiles:
      - .fai

  - id: SAMPLE_SIZE
    type: long
    default: 10000
    inputBinding:
      prefix: SAMPLE_SIZE=
      position: 23
      separate: false

  - id: TARGET_INTERVALS
    type: File
    inputBinding:
      prefix: TARGET_INTERVALS=
      position: 24
      separate: false

  - id: VALIDATION_STRINGENCY
    default: STRICT
    type: string
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      position: 25
      separate: false

  - id: java_xmx
    default: 32G
    type: string
    inputBinding:
      position: -10
      prefix: -Xmx
      separate: false

outputs:
  - id: METRIC_OUTPUT
    type: File
    outputBinding:
      glob: $(inputs.OUTPUT)

arguments:
  - valueFrom: "-jar"
    position: -9

  - valueFrom: "/usr/local/bin/picard.jar"
    position: -8

  - valueFrom: "CollectTargetedPcrMetrics"
    position: -7

baseCommand: [java]
