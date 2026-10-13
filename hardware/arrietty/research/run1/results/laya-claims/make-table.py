"""Build the laya-claims table: our number beside the authors' published one.

Every published figure carries the page it comes from, so a reader can
check it: BENCHMARKS.md of the authors' repository at commit 42626c34,
or the `Router` docstring in `laya/router.py` of the same commit.
"""
import json

R = "hardware/arrietty/research/run1/results/laya-claims/laya_benchmark_results.json"
d = json.load(open(R))
MODELS = ["laya", "laya-multilingual"]

# published value per (row, model); None where the authors publish nothing
PUBLISHED = {
    "typed-decisions, 2,000 decisions": {"laya": 0.361, "laya-multilingual": 0.342},
    "MASSIVE intent, English": {"laya": 0.783, "laya-multilingual": 0.657},
    "MASSIVE intent, not English": {"laya": 0.306, "laya-multilingual": 0.451},
    "MASSIVE scenario, English": {"laya": None, "laya-multilingual": None},
    "MASSIVE scenario, not English": {"laya": None, "laya-multilingual": None},
    "XNLI, English": {"laya": 0.860, "laya-multilingual": 0.843},
    "XNLI, not English": {"laya": 0.521, "laya-multilingual": 0.731},
    "English suites, macro": {"laya": 0.684, "laya-multilingual": 0.619},
    "MASSIVE intent, Portuguese": {"laya": 0.470, "laya-multilingual": 0.450},
    "AG News": {"laya": 0.953, "laya-multilingual": None},
    "DAIR Emotion": {"laya": 0.600, "laya-multilingual": None},
    "SST-5": {"laya": 0.372, "laya-multilingual": None},
}


def ms_per_question(suite_names, model):
    secs = sum(d["suites"][s][model]["seconds"] for s in suite_names if s in d["suites"])
    n = sum(d["suites"][s][model]["raw"]["n"] for s in suite_names if s in d["suites"])
    return 1000 * secs / n if n else float("nan")


def family(prefix):
    return [k for k in d["suites"] if k.startswith(prefix)]


ROWS = []
S, U = d["summary"], d["suites"]
ROWS.append(("typed-decisions, 2,000 decisions",
             {m: S["typed_decisions"][m]["accuracy"] for m in MODELS},
             {m: S["typed_decisions"][m]["ece"] for m in MODELS},
             {m: U["typed_decisions"][m]["raw"]["n"] for m in MODELS},
             {m: ms_per_question(["typed_decisions"], m) for m in MODELS}))
for label, key, part in (("MASSIVE intent, English", "massive_intent_english_vs_rest", "english"),
                         ("MASSIVE intent, not English", "massive_intent_english_vs_rest", "non_english"),
                         ("MASSIVE scenario, English", "massive_scenario_english_vs_rest", "english"),
                         ("MASSIVE scenario, not English", "massive_scenario_english_vs_rest", "non_english"),
                         ("XNLI, English", "xnli_english_vs_rest", "english"),
                         ("XNLI, not English", "xnli_english_vs_rest", "non_english")):
    fam = key.split("_english_vs_rest")[0]
    names = family(fam + ".")
    if part == "english":
        names = [n for n in names if n.endswith(".en")]
    else:
        names = [n for n in names if not n.endswith(".en")]
    ROWS.append((label, {m: S[key][part][m] for m in MODELS}, None,
                 {m: sum(U[n][m]["raw"]["n"] for n in names) for m in MODELS},
                 {m: ms_per_question(names, m) for m in MODELS}))
ROWS.append(("English suites, macro",
             {m: S["english"][m]["macro_accuracy"] for m in MODELS},
             {m: S["english"][m]["macro_ece"] for m in MODELS},
             {m: S["english"][m]["n_questions"] for m in MODELS},
             {m: ms_per_question([k for k in U if k.startswith("en.")], m) for m in MODELS}))
for label, suite in (("MASSIVE intent, Portuguese", "massive_intent.pt"),
                     ("AG News", "en.ag_news"),
                     ("DAIR Emotion", "en.emotion"),
                     ("SST-5", "en.sst5")):
    if suite not in U:
        continue
    ROWS.append((label,
                 {m: U[suite][m]["raw"]["accuracy"] for m in MODELS},
                 {m: U[suite][m]["raw"]["ece"] for m in MODELS},
                 {m: U[suite][m]["raw"]["n"] for m in MODELS},
                 {m: ms_per_question([suite], m) for m in MODELS}))

print("| set | checkpoint | our score | published | difference | our ECE | our ms per question | questions |")
print("| --- | --- | --- | --- | --- | --- | --- | --- |")
for label, acc, ece, n, ms in ROWS:
    for m in MODELS:
        pub = PUBLISHED.get(label, {}).get(m)
        diff = "%+.4f" % (acc[m] - pub) if pub is not None else "—"
        print("| %s | `%s` | %.4f | %s | %s | %s | %.2f | %d |"
              % (label, m, acc[m], ("%.3f" % pub) if pub is not None else "not published",
                 diff, ("%.4f" % ece[m]) if ece else "—", ms[m], n[m]))

print()
print("| calibration | checkpoint | our ECE | published | difference |")
print("| --- | --- | --- | --- | --- |")
for tag, key, pub in (("as shipped", "mean_ece_shipped", {"laya": 0.466, "laya-multilingual": 0.314}),
                      ("after the authors' fit", "mean_ece_refit", {"laya": 0.081, "laya-multilingual": 0.106})):
    for m in MODELS:
        v = d["calibration_repair"][m][key]
        print("| %s | `%s` | %.4f | %.3f | %+.4f |" % (tag, m, v, pub[m], v - pub[m]))

print()
print("| checkpoint | questions per call | our p50 ms | authors' T4 p50 ms | our ms per question |")
print("| --- | --- | --- | --- | --- |")
T4 = {("laya", 1): 39.5, ("laya", 10): 158.6, ("laya", 50): 771.3,
      ("laya-multilingual", 1): 32.8, ("laya-multilingual", 10): 72.3,
      ("laya-multilingual", 50): 337.4}
for m in MODELS:
    for k in (1, 5, 10, 50):
        c = d["latency"][m]["%d_questions" % k]
        ref = T4.get((m, k))
        print("| `%s` | %d | %.1f | %s | %.2f |"
              % (m, k, c["p50_ms"], ("%.1f" % ref) if ref else "not published",
                 c["ms_per_question"]))
