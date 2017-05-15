#!/usr/bin/env python3

import argparse
import json
import logging
import math
import os
import sys
import urllib
import urllib.request
import uuid

#from types import SimpleNamespace

SCRATCH_DIR = '/mnt/SCRATCH'
SLURM_CORE = 8
SLURM_MEM = 50000

class AttributeDict(dict): 
    __getattr__ = dict.__getitem__
    __setattr__ = dict.__setitem__


def fetch_text(url):
    split = urllib.parse.urlsplit(url)
    scheme, path = split.scheme, split.path

    if scheme in ['http', 'https']:# and self.session is not None:
        try:
            resp = urllib.request.urlopen(url)
            if resp.status == 200:
                read = resp.read()
                if hasattr(read, "decode"):
                    return read.decode("utf-8")
                else:
                    return read
            else:
                sys.exit('bad response: %s' %url)    
        except Exception as e:
            raise RuntimeError(url, e)
    elif scheme == 'file':
        try:
            with open(urllib.request.url2pathname(str(path))) as fp:
                read = fp.read()
            if hasattr(read, "decode"):
                return read.decode("utf-8")
            else:
                return read
        except (OSError, IOError) as e:
            if e.filename == path:
                raise RuntimeError(unicode(e))
            else:
                raise RuntimeError('Error reading %s: %s' % (url, e))
    else:
        raise ValueError('Unsupported scheme in url: %s' % url)
    return


def generate_runner(job_json_file, queue_data, runner_text):
    runner_template = json.loads(runner_text, object_hook=lambda d: AttributeDict(**d))
    for attr, value in queue_data.items():
        if attr == 'db_cred':
             setattr(runner_template.db_cred, 'path', value)
        else:
            try:
                hasattr(runner_template, attr)
                setattr(runner_template, attr, value)
            except KeyError:
                continue
    setattr(runner_template, 'thread_count', '8')
    with open(job_json_file, 'w') as f_open:
        json.dump(runner_template, f_open, sort_keys=True, indent=4)

    return


def generate_slurm(job_slurm_file, queue_data, slurm_template_text):

    for attr, value in queue_data.items():
        print(attr, value)
        slurm_template_text = slurm_template_text.replace('${xx_'+attr+'_xx}', value)

    with open(job_slurm_file, 'w') as f_open:
        f_open.write(slurm_template_text)
    return


def setup_job(queue_item):
    job_json_file = '/'.join((queue_item['job_creation_uuid'], 'cwl', queue_item['input_bam_gdc_id'] + '_alignment.json'))
    job_slurm_file = '/'.join((queue_item['job_creation_uuid'], 'slurm', queue_item['input_bam_gdc_id'] + '_alignment.sh'))
    json_uri = '/'.join((queue_item['runner_job_base_uri'], job_json_file))

    runner_json_template_text = fetch_text(queue_item['runner_json_template_uri'])
    slurm_template_text = fetch_text(queue_item['slurm_template_uri'])

    slurm_core = SLURM_CORE # will eventually be decided by cwl engine at run time per step
    slurm_mem_megabytes = SLURM_MEM # make a model
    slurm_disk_gigabytes = math.ceil(10 * (int(queue_item['input_bam_file_size']) / (1000**3))) #use readgroup, will eventually be decided by cwl engine at run time per step
    queue_item['slurm_core'] = str(slurm_core)
    queue_item['slurm_mem_megabytes'] = str(slurm_mem_megabytes)
    queue_item['slurm_disk_gigabytes'] = str(slurm_disk_gigabytes)

    runner_cwl_branch = ''
    queue_item['runner_cwl_branch'] = runner_cwl_branch
    runner_cwl_repo = ''
    queue_item['runner_cwl_repo'] = runner_cwl_repo
    runner_job_branch = ''
    queue_item['runner_job_branch'] = runner_job_branch
    runner_job_cwl_uri = json_uri
    queue_item['runner_job_cwl_uri'] = runner_job_cwl_uri
    runner_job_repo = ''
    queue_item['runner_job_repo'] = runner_job_repo
    runner_job_slurm_uri = ''
    queue_item['runner_job_slurm_uri'] = runner_job_slurm_uri


    generate_runner(job_json_file, queue_item, runner_json_template_text)
    generate_slurm(job_slurm_file, queue_item, slurm_template_text)
    return


def main():
    parser = argparse.ArgumentParser('make slurm and cwl job')
    # Logging flags.
    parser.add_argument('-d', '--debug',
        action = 'store_const',
        const = logging.DEBUG,
        dest = 'level',
        help = 'Enable debug logging.',
    )
    parser.set_defaults(level = logging.INFO)

    parser.add_argument('--queue_json',
                        required=True
    )

    args = parser.parse_args()
    queue_json = args.queue_json

    job_creation_uuid = str(uuid.uuid4())

    cwl_dir = '/'.join((job_creation_uuid, 'cwl'))
    slurm_dir = '/'.join((job_creation_uuid, 'slurm'))

    if not os.path.exists(job_creation_uuid):
        os.makedirs(job_creation_uuid)
        os.makedirs(cwl_dir)
        os.makedirs(slurm_dir)
    else:
        sys.exit(job_creation_uuid + ' exists. Exiting.')

    with open(queue_json, 'r') as f:
        queue_dict = json.loads(f.read())
    for queue_item in queue_dict:
        queue_item['job_creation_uuid'] = job_creation_uuid
        setup_job(queue_item)
    return


if __name__=='__main__':
    main()
