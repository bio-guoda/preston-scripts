# Expects one n-quad per line

import sys

ACTIVITY = "http://www.w3.org/ns/prov#activity"
WAS_INFORMED_BY = "http://www.w3.org/ns/prov#wasInformedBy"

def main():
    for line in sys.stdin:
        if "<" + ACTIVITY + ">" in line:
            print(line.replace(ACTIVITY, WAS_INFORMED_BY), end="")

if __name__ == "__main__":
    file = None
    if len(sys.argv) > 1:
        import io
        inputPath = sys.argv[1]
        file = open(inputPath, "r")
        sys.stdin = io.StringIO(file.read())

    main()

    if file:
        file.close()
