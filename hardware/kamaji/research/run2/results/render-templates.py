import json

from jinja2 import Environment
from jinja2.exceptions import TemplateError

MESSAGES_STRING_ARGS = json.load(open('/tmp/run2/apply-template.json'))['messages']

MESSAGES_DICT_ARGS = json.loads(json.dumps(MESSAGES_STRING_ARGS))
for m in MESSAGES_DICT_ARGS:
    for tc in m.get('tool_calls') or []:
        tc['function']['arguments'] = json.loads(tc['function']['arguments'])

TEMPLATES = [
    ('pre-fix  (every local chat_template.jinja)', '/tmp/run2/templates/hf-google-prefix.jinja'),
    ('post-fix (google main, after 2026-07-15)', '/tmp/run2/templates/hf-google-main.jinja'),
]

SHAPES = [
    ('arguments as JSON string (raw OpenAI)', MESSAGES_STRING_ARGS),
    ('arguments as mapping (mlx_lm deserializes)', MESSAGES_DICT_ARGS),
]


def render(src, messages):
    env = Environment()
    env.policies['json.dumps_kwargs'] = {'ensure_ascii': False}

    def raise_exception(message):
        raise TemplateError(message)

    env.globals['raise_exception'] = raise_exception
    return env.from_string(src).render(
        messages=messages, add_generation_prompt=True,
        enable_thinking=True, tools=None)


for label, path in TEMPLATES:
    src = open(path).read()
    for shape, messages in SHAPES:
        print('== %s | %s' % (label, shape))
        try:
            out = render(src, messages)
            print('   ', repr(out[-190:]))
        except TemplateError as e:
            print('    RENDER ERROR:', e)
        except Exception as e:
            print('    ERROR:', type(e).__name__, e)
        print('')
