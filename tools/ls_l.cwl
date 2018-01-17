#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: ubuntu:artful-20171019
  - class: InlineJavascriptRequirement

class: CommandLineTool
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 500
    ramMax: 500
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1


inputs:
  - id: INPUT
    type: File
    inputBinding:
      position: 0

outputs:
  - id: OUTPUT
    type: File
    outputBinding:
      glob: $(inputs.INPUT.nameroot + ".ls")

stdout: $(inputs.INPUT.nameroot + ".ls")
      
baseCommand: [ls, -l]
