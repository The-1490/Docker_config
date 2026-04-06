import os, time
while True:
    print("autoscaler placeholder running, poll interval:", os.getenv("POLL_INTERVAL", "15"), flush=True)
    time.sleep(60)
