#!/usr/bin/env python3
"""Profile one benchmark workload with Instruments and summarize where the time goes.

    python3 Benchmarks/profile.py chat.stream openaikit 300

Records a Time Profiler trace with `xcrun xctrace`, exports the samples, and prints the
functions with the most self time and the most inclusive time. The .trace file is kept so you
can open it in Instruments.
"""

import collections
import os
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
BENCH = os.path.join(HERE, ".build", "release", "Bench")


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    workload, sdk = sys.argv[1], sys.argv[2]
    iterations = sys.argv[3] if len(sys.argv) > 3 else "200"
    interval = sys.argv[4] if len(sys.argv) > 4 else "0"
    out_dir = os.environ.get("PROFILE_DIR", tempfile.gettempdir())
    trace = os.path.join(out_dir, f"{workload}-{sdk}.trace")
    subprocess.run(["rm", "-rf", trace], check=True)
    subprocess.run(
        ["xcrun", "xctrace", "record", "--template", "Time Profiler", "--output", trace, "--no-prompt",
         "--launch", "--", BENCH, "run", workload, sdk, iterations, interval],
        check=True, stdout=subprocess.DEVNULL,
    )
    subprocess.run(["dsymutil", BENCH, "-o", BENCH + ".dSYM"], check=True, stderr=subprocess.DEVNULL)
    subprocess.run(["xcrun", "xctrace", "symbolicate", "--input", trace, "--dsym", BENCH + ".dSYM"],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    xml = subprocess.run(
        ["xcrun", "xctrace", "export", "--input", trace, "--xpath",
         '/trace-toc/run[@number="1"]/data/table[@schema="time-profile"]'],
        check=True, capture_output=True,
    ).stdout
    root = ET.fromstring(xml)

    # xctrace deduplicates repeated elements with id/ref attributes.
    by_id = {}
    for element in root.iter():
        if "id" in element.attrib:
            by_id[element.attrib["id"]] = element

    def resolve(element):
        return by_id.get(element.attrib["ref"], element) if "ref" in element.attrib else element

    self_time = collections.Counter()
    inclusive = collections.Counter()
    total = 0
    for row in root.iter("row"):
        backtrace = row.find("tagged-backtrace")
        if backtrace is None:
            backtrace = row.find("backtrace")
        weight = row.find("weight")
        state = row.find("thread-state")
        if state is not None and resolve(state).attrib.get("fmt", "Running") != "Running":
            continue
        if backtrace is None:
            continue
        backtrace = resolve(backtrace)
        value = int(resolve(weight).text) if weight is not None and resolve(weight).text else 1
        frames = [resolve(f).attrib.get("name", "?") for f in backtrace.findall("frame")]
        if not frames:
            continue
        total += value
        self_time[frames[0]] += value
        for name in set(frames):
            inclusive[name] += value

    def short(name):
        return name if len(name) <= 110 else name[:107] + "..."

    print(f"Trace: {trace}")
    print(f"\nTop self time ({workload}, {sdk})")
    for name, value in self_time.most_common(25):
        print(f"  {100 * value / total:5.1f}%  {short(name)}")
    print("\nTop inclusive time (OpenAIKit / OpenAI / Foundation frames)")
    shown = 0
    for name, value in inclusive.most_common(400):
        if any(key in name for key in ("OpenAIKit", "OpenAI", "JSONDecoder", "Decod", "ServerSent", "URLSession", "AsyncBytes", "AsyncThrowingStream", "Data")):
            print(f"  {100 * value / total:5.1f}%  {short(name)}")
            shown += 1
            if shown >= 30:
                break


if __name__ == "__main__":
    main()
