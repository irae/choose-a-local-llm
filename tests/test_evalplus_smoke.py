"""Tests for benchmarks/evalplus-smoke.py.

Only the parts that run without a server: the budget rule, and the
padding that `evalplus.evaluate` needs. The generation and the evaluator
call a live server and a venv binary, so they stay out.
"""
import contextlib
import importlib.util
import io
import json
import os
import shutil
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
BENCH = os.path.join(ROOT, "benchmarks")
SCRIPT = os.path.join(BENCH, "evalplus-smoke.py")

_spec = importlib.util.spec_from_file_location("evalplus_smoke", SCRIPT)
smoke = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(smoke)


@contextlib.contextmanager
def environment(**pairs):
    saved = {k: os.environ.get(k) for k in pairs}
    for key, value in pairs.items():
        if value is None:
            os.environ.pop(key, None)
        else:
            os.environ[key] = value
    try:
        yield
    finally:
        for key, value in saved.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value


def budget(**pairs):
    pairs.setdefault("SMOKE_MAX_TOKENS", None)
    with environment(**pairs):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            value = smoke.resolve_budget()
        return value, out.getvalue()


class TheSubsetIsFixed(unittest.TestCase):
    def test_the_four_problems_are_the_ones_the_header_names(self):
        self.assertEqual(smoke.SUBSET,
                         ["HumanEval/53", "HumanEval/45",
                          "HumanEval/34", "HumanEval/129"])

    def test_the_fast_mode_max_tokens(self):
        self.assertEqual(smoke.FAST_MAX_TOKENS, 16384)


class Budget(unittest.TestCase):
    def test_no_override_gives_fast_mode_and_says_so(self):
        value, log = budget()
        self.assertEqual(value, 16384)
        self.assertIn("source=fast-mode", log)
        self.assertIn("max_tokens=16384", log)

    def test_the_override_wins_and_says_where_it_came_from(self):
        value, log = budget(SMOKE_MAX_TOKENS="12345")
        self.assertEqual(value, 12345)
        self.assertIn("source=SMOKE_MAX_TOKENS", log)


class Padding(unittest.TestCase):
    """evalplus.evaluate asserts full coverage, so the samples file pads."""

    def setUp(self):
        self.out = tempfile.mkdtemp(prefix="evalplus-smoke-test-")
        self.addCleanup(shutil.rmtree, self.out)
        self.all_ids = ["HumanEval/%d" % i for i in range(164)]
        self.rows = [
            {"task_id": "HumanEval/53", "solution": "def add(a, b): return a + b"},
            {"task_id": "HumanEval/45", "solution": "def triangle_area(a, h): return a * h / 2"},
            {"task_id": "HumanEval/34", "solution": "def unique(l): return sorted(set(l))"},
            {"task_id": "HumanEval/129", "solution": ""},
        ]

    def write_samples(self):
        # evaluate() stops at the PATH check, after it wrote the samples.
        saved = smoke.shutil.which
        smoke.shutil.which = lambda _name: None
        try:
            with self.assertRaises(SystemExit):
                smoke.evaluate(self.rows, self.all_ids, self.out, "current")
        finally:
            smoke.shutil.which = saved
        path = os.path.join(self.out, "current.smoke.jsonl")
        with open(path) as f:
            return [json.loads(line) for line in f]

    def test_the_samples_file_covers_the_whole_dataset(self):
        rows = self.write_samples()
        self.assertEqual(len(rows), 164)
        self.assertEqual([r["task_id"] for r in rows], self.all_ids)

    def test_the_four_real_answers_are_kept(self):
        rows = {r["task_id"]: r["solution"] for r in self.write_samples()}
        self.assertEqual(rows["HumanEval/53"], "def add(a, b): return a + b")

    def test_every_other_problem_gets_the_stub(self):
        rows = {r["task_id"]: r["solution"] for r in self.write_samples()}
        self.assertEqual(rows["HumanEval/1"], smoke.STUB)

    def test_an_empty_completion_also_gets_the_stub(self):
        rows = {r["task_id"]: r["solution"] for r in self.write_samples()}
        self.assertEqual(rows["HumanEval/129"], smoke.STUB)

    def test_it_says_the_evaluator_is_missing_instead_of_guessing(self):
        saved = smoke.shutil.which
        smoke.shutil.which = lambda _name: None
        try:
            with self.assertRaises(SystemExit) as stop:
                smoke.evaluate(self.rows, self.all_ids, self.out, "current")
        finally:
            smoke.shutil.which = saved
        self.assertIn("evalplus.evaluate is not on PATH", str(stop.exception.code))


if __name__ == "__main__":
    unittest.main()
