#!/usr/bin/env python3

import heapq


def delay_3_cycles(outer_start, middle_start, inner_start):
    return (
        10
        + outer_start * middle_start * (inner_start * 1 + 2 + (inner_start - 1) * 2)
        + outer_start * (middle_start * 1 + 2 + (middle_start - 1) * 2)
        + ((outer_start * 1 + 2) + 2 + (outer_start - 1) * 2)
    )


def evaluate_delay_3_config(target_cycles, max_start_val=0xFF, n_best=30):
    results = []
    for a in range(max_start_val):
        for b in range(max_start_val):
            for c in range(max_start_val):
                counters = (a, b, c)
                actual_cycles = delay_3_cycles(*counters)
                delta = abs(target_cycles - actual_cycles)
                heapq.heappush(results, (delta, counters))
    best = heapq.nsmallest(n_best, results)
    for diff, counters in best:
        print(f"{diff} {counters}")


evaluate_delay_3_config(1_000_000)
# 2 (30, 55, 201)
# 2 (30, 101, 109)
# 2 (30, 110, 100)
# 2 (30, 202, 54)
# 2 (82, 16, 253)
# 2 (82, 32, 126)
# 2 (82, 127, 31)
# 2 (82, 254, 15)
# 2 (123, 21, 128)
# 2 (123, 43, 62)
# 2 (123, 63, 42)
# 2 (123, 129, 20)
# 2 (205, 13, 124)
# 2 (205, 25, 64)
# 2 (205, 65, 24)
# 2 (205, 125, 12)
# 4 (16, 84, 247)
# 4 (16, 93, 223)
# 4 (16, 96, 216)
# 4 (16, 112, 185)
# 4 (16, 124, 167)
# 4 (16, 168, 123)
# 4 (16, 186, 111)
# 4 (16, 217, 95)
# 4 (16, 224, 92)
# 4 (16, 248, 83)
# 4 (83, 55, 72)
# 4 (83, 73, 54)
# 4 (166, 9, 222)
# 4 (166, 223, 8)
