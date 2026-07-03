#!/usr/bin/env python3

import pandas as pd
import numpy as np

def training(delta_t, d, csv_file, scale_factor=1.0, sim_start_hour=0):

    try:
        df = pd.read_csv(csv_file)
    except Exception as e:
        raise FileNotFoundError(f"Could not read {csv_file}: {e}")
    
    df["Time"] = df["Time"] * scale_factor

    training_period_sec = d * 24 * 3600
    df_train = df[df["Time"] < training_period_sec].copy()
    
    seconds_per_day = 24 * 3600
    start_offset = sim_start_hour * 3600
    df_train["time_of_day"] = (df_train["Time"] + start_offset) % seconds_per_day
    
    window_duration_sec = delta_t * 3600
    df_train["window_index"] = (df_train["time_of_day"] // window_duration_sec).astype(int)
    
    W = int(24 / delta_t)
    COUNT = np.zeros(W, dtype=int)
    
    window_counts = df_train.groupby("window_index").size()
    for idx, count in window_counts.items():
        if 0 <= idx < W:
            COUNT[idx] = count

    return COUNT

def prob_estimate(COUNT):

    total_events = COUNT.sum()
    if total_events == 0:
        return np.zeros_like(COUNT, dtype=float), 0
    PD = COUNT / total_events
    return PD, total_events

def get_expected_count(t_test_start, delta_t, PD, training_sum, d, sim_start_hour):

    seconds_per_day = 24 * 3600
    window_duration_sec = delta_t * 3600
    start_offset = sim_start_hour * 3600
    time_of_day = (t_test_start + start_offset) % seconds_per_day
    window_index = int(time_of_day // window_duration_sec)
    if window_index >= len(PD):
        window_index = len(PD) - 1
    PD_test = PD[window_index]
    avg_daily_events = training_sum / d
    event_count_train = PD_test * avg_daily_events
    return event_count_train

def testing(delta_t, d, test_csv, PD, training_sum, beta, scale_factor=1.0, sim_start_hour=0):

    try:
        df_test = pd.read_csv(test_csv)
    except Exception as e:
        raise FileNotFoundError(f"Could not read {test_csv}: {e}")
    
    df_test["Time"] = df_test["Time"] * scale_factor
    df_test = df_test.sort_values("Time")
    
    test_start_time = df_test["Time"].min()
    test_end_time   = df_test["Time"].max()
    window_duration_sec = delta_t * 3600
    
    current_window_start = test_start_time
    print("\n--- Testing Phase ---")
    while current_window_start < test_end_time:
        current_window_end = current_window_start + window_duration_sec
        
        window_events = df_test[(df_test["Time"] >= current_window_start) &
                                (df_test["Time"] < current_window_end)]
        event_count = window_events.shape[0]
        
        expected_count = get_expected_count(current_window_start, delta_t, PD, training_sum, d, sim_start_hour)
        
        if event_count >= expected_count + beta:
            print(f"Starvation Attack detected in window starting at simulated time {current_window_start:.2f} sec:")
            print(f"  Observed events: {event_count}")
            print(f"  Expected events: {expected_count:.2f} + beta ({beta})")
        else:
            print(f"Window starting at simulated time {current_window_start:.2f} sec: normal")
            print(f"  Observed events: {event_count}")
            print(f"  Expected events: {expected_count:.2f} + beta ({beta})")
        
        current_window_start = current_window_end

def main():
    import sys
    
    print("=== Training Phase ===")
    try:
        delta_t = float(input("Enter the window period (ΔT) in hours : "))
        d = float(input("Enter the training period (d) in days : "))
        scale_factor = float(input("Enter scale factor for time conversion : "))
        sim_start_hour = float(input("Enter simulated start hour : "))
    except Exception as e:
        print("Invalid input:", e)
        sys.exit(1)
    
    training_csv = input("Enter the training CSV filename : ") or "train.csv"
    
    try:
        COUNT = training(delta_t, d, training_csv, scale_factor, sim_start_hour)
    except FileNotFoundError as fe:
        print(fe)
        sys.exit(1)
    
    PD, training_sum = prob_estimate(COUNT)
    
    print("\nTraining phase results:")
    print("Event counts per window:")
    for i, count in enumerate(COUNT):
        print(f"  Window {i+1}: {count}")
    print("\nProbability Distribution (PD) per window:")
    for i, p in enumerate(PD):
        print(f"  Window {i+1}: {p:.4f}")
    print(f"\nTotal events in training: {training_sum}")
    
    print("\n=== Testing Phase ===")
    test_csv = input("Enter the testing CSV filename : ") or "test.csv"
    try:
        beta = float(input("Enter the threshold beta for detection: "))
    except Exception as e:
        print("Invalid input for beta:", e)
        sys.exit(1)
    
    testing(delta_t, d, test_csv, PD, training_sum, beta, scale_factor, sim_start_hour)

if __name__ == '__main__':
    main()
