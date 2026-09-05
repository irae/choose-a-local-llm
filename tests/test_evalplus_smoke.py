"""Tests for benchmarks/evalplus-smoke.py.

Only the parts that run without a server: the budget rule, and the
padding that `evalplus.evaluate` needs. The generation and the evaluator
call a live server and a venv binary, so they stay out.

The calibration files are the committed ones under benchmarks/.
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

CONVERGED_LOW = os.path.join(BENCH, "calibration-gemma12-gguf-off.json")
CONVERGED_HIGH = os.path.join(BENCH, "calibration-qwen36-think.json")
NEVER_CONVERGES = os.path.join(BENCH, "calibration-gemma12-lmstudio-thinking-on.json")


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
    pairs.setdefault("SMOKE_CALIBRATION", None)
    with environment(**pairs):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            value = smoke.resolve_budget()
        return value, out.getvalue()


def budget_refusal(**pairs):
    pairs.setdefault("SMOKE_MAX_TOKENS", None)
    pairs.setdefault("SMOKE_CALIBRATION", None)
    with environment(**pairs):
        out = io.StringIO()
        try:
            with contextlib.redirect_stdout(out):
                smoke.resolve_budget()
        except SystemExit as stop:
            return str(stop.code)
    raise AssertionError("resolve_budget did not refuse")


class TheSubsetIsFixed(unittest.TestCase):
    def test_the_four_problems_are_the_ones_the_header_names(self):
        self.assertEqual(smoke.SUBSET,
                         ["HumanEval/53", "HumanEval/45",
                          "HumanEval/34", "HumanEval/129"])

    def test_the_budget_rule_constants(self):
        self.assertEqual(smoke.BUDGET_FLOOR, 8192)
        self.assertEqual(smoke.BUDGET_FACTOR, 1.5)


class Budget(unittest.TestCase):
    def test_a_converged_calibration_gives_observed_max_times_1_5(self):
        value, log = budget(SMOKE_CALIBRATION=CONVERGED_HIGH)
        with open(CONVERGED_HIGH) as f:
            rows = json.load(f)
        observed = max(int(r["completion_tokens"]) for r in rows)
        self.assertEqual(value, int(observed * 1.5))
        self.assertIn("observed_max=%d" % observed, log)
        self.assertIn("max_tokens=%d" % value, log)

    def test_a_small_calibration_takes_the_floor(self):
        value, log = budget(SMOKE_CALIBRATION=CONVERGED_LOW)
        self.assertEqual(value, 8192)
        self.assertIn("max_tokens=8192", log)

    def test_the_override_wins_and_says_where_it_came_from(self):
        value, log = budget(SMOKE_MAX_TOKENS="12345",
                            SMOKE_CALIBRATION=CONVERGED_HIGH)
        self.assertEqual(value, 12345)
        self.assertIn("source=SMOKE_MAX_TOKENS", log)

    def test_the_override_reads_a_calibration_that_never_converges(self):
        value, _ = budget(SMOKE_MAX_TOKENS="30000",
                          SMOKE_CALIBRATION=NEVER_CONVERGES)
        self.assertEqual(value, 30000)


class BudgetRefusals(unittest.TestCase):
    def test_no_calibration_and_no_override_refuses(self):
        message = budget_refusal()
        self.assertIn("SMOKE_CALIBRATION is not set", message)

    def test_a_missing_calibration_file_refuses(self):
        message = budget_refusal(SMOKE_CALIBRATION="/nonexistent/calibration.json")
        self.assertIn("not found", message)

    def test_a_calibration_that_never_converges_refuses(self):
        message = budget_refusal(SMOKE_CALIBRATION=NEVER_CONVERGES)
        self.assertIn("finish_reason=length", message)
        self.assertIn("SMOKE_MAX_TOKENS", message)
        with open(NEVER_CONVERGES) as f:
            rows = json.load(f)
        truncated = [r["task_id"] for r in rows if r.get("finish_reason") == "length"]
        self.assertTrue(truncated)
        for task_id in truncated:
            self.assertIn(task_id, message)


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
