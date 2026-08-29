#!/usr/bin/env python3
import json
from pathlib import Path

CONFIGS_DIR = Path(__file__).resolve().parents[1] / "configs"
OUT_FILE = CONFIGS_DIR / "docs_supported_platforms.json"


def extract_entries(vendor_file: Path):
    data = json.loads(vendor_file.read_text())
    vendor = vendor_file.stem
    out = []
    models = data.get("models", {})

    for system_model, mdata in models.items():
        base_rel = mdata.get("dasharo_rel_name") or mdata.get("DASHARO_REL_NAME")
        boards = mdata.get("board_models", {})

        if boards:
            for board_model, bdata in boards.items():
                rel = bdata.get("dasharo_rel_name") or bdata.get("DASHARO_REL_NAME") or base_rel
                out.append({
                    "system_vendor": vendor,
                    "system_model": system_model,
                    "board_model": board_model,
                    "dasharo_rel_name": rel,
                })
        else:
            out.append({
                "system_vendor": vendor,
                "system_model": system_model,
                "board_model": None,
                "dasharo_rel_name": base_rel,
            })
    return out


def main():
    entries = []
    for cfg in sorted(CONFIGS_DIR.glob("*.json")):
        if cfg.name == OUT_FILE.name:
            continue
        entries.extend(extract_entries(cfg))

    entries = [e for e in entries if e.get("dasharo_rel_name")]
    entries.sort(key=lambda e: (e["system_vendor"], e["system_model"], e["board_model"] or ""))

    payload = {
        "generated_from": "configs/*.json",
        "purpose": "Mapping between dmidecode-style identifiers and Dasharo release names for docs generation",
        "count": len(entries),
        "entries": entries,
    }
    OUT_FILE.write_text(json.dumps(payload, indent=2) + "\n")
    print(f"wrote {OUT_FILE} ({len(entries)} entries)")


if __name__ == "__main__":
    main()
