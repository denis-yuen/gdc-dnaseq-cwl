#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard:6a031f4df1907fd13a58c9351855008b9dd8c5793560cb0d81ba4196d31dc88b
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 15000
    ramMax: 15000
    tmpdirMin: $(Math.ceil(1.1 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil(1.1 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil(1.1 * inputs.input.size / 1048576))
    outdirMax: $(Math.ceil(1.1 * inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: CREATE_INDEX
    type: string
    default: "true"
    inputBinding:
      prefix: CREATE_INDEX=
      separate: false

  - id: INPUT
    type: File
    format: "edam:format_2572"
    inputBinding:
      prefix: INPUT=
      separate: false

  - id: TMP_DIR
    default: .
    type: string
    inputBinding:
      prefix: TMP_DIR=
      separate: false

  - id: VALIDATION_STRINGENCY
    default: STRICT
    type: string
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      separate: false

outputs:
  - id: OUTPUT
    type: File
    format: "edam:format_2572"
    outputBinding:
      glob: $(inputs.INPUT.basename)
    secondaryFiles:
      - ^.bai

  - id: METRICS
    type: File
    outputBinding:
      glob: $(inputs.INPUT.basename + ".metrics")

arguments:
  - valueFrom: $(inputs.INPUT.basename)
    prefix: OUTPUT=
    separate: false

  - valueFrom: $(inputs.INPUT.basename + ".metrics")
    prefix: METRICS_FILE=
    separate: false

baseCommand: [java, -jar, /usr/local/bin/picard.jar, MarkDuplicates]
