from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IOS_PROJECT = ROOT / "ios" / "Runner.xcodeproj" / "project.pbxproj"

REPLACEMENTS = (
    ("com.example.flutterApplication1.RunnerTests", "com.numuw.app.RunnerTests"),
    ("com.example.flutterApplication1", "com.numuw.app"),
)


def main() -> None:
    if not IOS_PROJECT.exists():
        raise SystemExit(f"Missing Xcode project: {IOS_PROJECT}")

    original = IOS_PROJECT.read_text(encoding="utf-8")
    updated = original
    for old, new in REPLACEMENTS:
        updated = updated.replace(old, new)

    if "com.example.flutterApplication1" in updated:
        raise SystemExit("Legacy iOS bundle identifier is still present after normalization.")

    if "com.numuw.app" not in updated:
        raise SystemExit("Numuw iOS bundle identifier was not found after normalization.")

    if updated != original:
        IOS_PROJECT.write_text(updated, encoding="utf-8")
        print("Updated iOS bundle identifiers to com.numuw.app.")
    else:
        print("iOS bundle identifiers are already normalized.")


if __name__ == "__main__":
    main()
