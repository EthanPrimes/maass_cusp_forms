import argparse
import numpy as np
import time
import os

def estimate_pi(n_samples, seed):
    rng = np.random.default_rng(seed)
    x = rng.random(n_samples)
    y = rng.random(n_samples)
    inside = (x**2 + y**2) <= 1.0
    return 4.0 * inside.mean()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--job-id", type=int, required=True)
    parser.add_argument("--n-samples", type=int, default=10_000_000)
    parser.add_argument("--outdir", type=str, default="output")
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)

    seed = 1000 + args.job_id
    start = time.time()
    pi_hat = estimate_pi(args.n_samples, seed)
    runtime = time.time() - start

    outfile = os.path.join(args.outdir, f"result_{args.job_id}.txt")
    with open(outfile, "w") as f:
        f.write(f"job_id {args.job_id}\n")
        f.write(f"n_samples {args.n_samples}\n")
        f.write(f"pi_estimate {pi_hat}\n")
        f.write(f"runtime_sec {runtime}\n")

if __name__ == "__main__":
    main()
