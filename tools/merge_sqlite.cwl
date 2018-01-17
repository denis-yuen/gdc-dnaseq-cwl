#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/merge_sqlite:32bf383b197503e795278332d3c8bd5944f736f25ebaedb25a3a104252c3b76f
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: |
      ${
      var req_space = 0;
      for (i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(2 * (req_space / 1048576));
      }      
    tmpdirMax: |
      ${
      var req_space = 0;
      for (i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(2 * (req_space / 1048576));
      }      
    outdirMin: |
      ${
      var req_space = 0;
      for (i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(req_space / 1048576);
      }      
    outdirMax: |
      ${
      var req_space = 0;
      for (i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(req_space / 1048576);
      }

class: CommandLineTool

inputs:
  - id: source_sqlite
    format: "edam:format_3621"
    type:
      type: array
      items: File
      inputBinding:
        prefix: "--source_sqlite"

  - id: task_uuid
    type: string
    inputBinding:
      prefix: "--task_uuid"

outputs:
  - id: destination_sqlite
    format: "edam:format_3621"
    type: File
    outputBinding:
      glob: $(inputs.task_uuid + ".db")

  - id: log
    type: File
    outputBinding:
      glob: $(inputs.task_uuid + ".log")

baseCommand: [/usr/local/bin/merge_sqlite]
