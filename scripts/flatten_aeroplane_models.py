import json
from pathlib import Path


def flatten_models(input_path: str) -> list[dict]:
    """Flatten manufacturer -> model JSON into rows suitable for a raw table."""
    payload = json.loads(Path(input_path).read_text())
    rows = []

    for manufacturer, models in payload.items():
        for model_name, attributes in models.items():
            rows.append(
                {
                    "manufacturer": manufacturer,
                    "aircraft_model": model_name,
                    "max_seats": attributes.get("max_seats"),
                    "max_weight": attributes.get("max_weight"),
                    "max_distance": attributes.get("max_distance"),
                    "engine_type": attributes.get("engine_type"),
                }
            )

    return rows


if __name__ == "__main__":
    import argparse
    import csv

    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    print(args)
    

    rows = flatten_models(args.input)
    print(f"Total aeroplane model rows created: {len(rows)}")
    Path(args.output).parent.mkdir(parents=True, exist_ok=True)

    with open(args.output, "w", newline="") as fp:
        writer = csv.DictWriter(fp, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    print(f"CSV file created successfully: {args.output}")

