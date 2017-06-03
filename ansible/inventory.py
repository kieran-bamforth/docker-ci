#!/usr/bin/env python

import argparse
import boto3
import json
import subprocess

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--host')
    args = parser.parse_args()

    if args.list:
        cf = boto3.client('cloudformation')
        stack = cf.describe_stacks(StackName='docker-ci')
        outputs = stack.get('Stacks')[0].get('Outputs')
        jenkins_ip = filter(lambda output: output.get('OutputKey') == 'JenkinsIp', outputs)[0]
        print(json.dumps({ "jenkins": [ jenkins_ip.get('OutputValue') ] }))

    if args.host:
        print(json.dumps({}))
