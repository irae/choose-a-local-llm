#!/usr/bin/env python3
"""make-replay-models.py — write the pinned pi model config for T1.1.

Research run 2. Copies the owner's `~/.pi/agent/models.json` and adds one
extra entry for the replay arm, pointing at the local llama-server. The
owner's own file is never modified: the copy lands wherever the argument
says, under /tmp.

The extra entry mirrors the LM Studio entry the failing run used, with
two deliberate differences: the provider is llama-server, and thinking is
requested through the chat template, because Gemma's template reads
`enable_thinking` and nothing else.

Usage: make-replay-models.py <output-path>
Environment: MODEL_ID, DECLARED_CONTEXT, PORT
"""

import json
import os
import sys

source = os.path.expanduser('~/.pi/agent/models.json')
target = sys.argv[1]

model_id = os.environ['MODEL_ID']
declared_context = int(os.environ['DECLARED_CONTEXT'])
port = os.environ['PORT']

config = json.load(open(source))

entry = {
    'id': model_id,
    'contextWindow': declared_context,
    'maxTokens': 16384,
    'name': 'Gemma 4 12B (llama-server replay arm, research run 2)',
    'description': (
        'Research run 2 T1.1 only. Same GGUF as the published llama config, '
        'declared window matched to the LM Studio arm so pi compacts at the '
        'same point. Never publish a measurement from this entry.'
    ),
    'reasoning': True,
    'compat': {
        'supportsDeveloperRole': False,
        'supportsReasoningEffort': False,
        'thinkingFormat': 'chat-template',
        'chatTemplateKwargs': {
            'enable_thinking': {'$var': 'thinking.enabled'},
        },
    },
    'thinkingLevelMap': {
        'off': 'off',
        'minimal': None,
        'low': 'low',
        'medium': 'medium',
        'high': 'high',
        'xhigh': None,
        'max': None,
    },
}

provider = config['providers']['llama']
provider['baseUrl'] = 'http://127.0.0.1:%s/v1' % port
provider['models'] = [m for m in provider['models'] if m['id'] != model_id]
provider['models'].append(entry)

json.dump(config, open(target, 'w'), indent=2)
print('wrote %s with entry %s' % (target, model_id))
