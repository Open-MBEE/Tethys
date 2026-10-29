"""F-SW1101: Model.calc cannot pass a bare number to a parameter typed by a quantity type, and the
client's Quantity carries no unit reduction, so a `calc def` with quantity parameters is only
reachable through Model.eval with the model's own unit literal. Run from the repo root with
PYTHONPATH=software/ground:software/generated/python build/software/venv/bin/python."""
from meridian.modelbridge import ModelBridge

with ModelBridge() as mb:
    for args in ((4.5, 21),):
        try:
            print("calc bare:", mb.calc("TethysGroundSoftware::OrbitDetermination", *args))
        except Exception as e:  # noqa: BLE001 - the probe reports whatever the client raises
            print("calc bare ->", type(e).__name__, str(e).splitlines()[0][:200])
    try:
        from opensysml.values import Quantity, Unit
        print("calc quantity:", mb.calc("TethysGroundSoftware::OrbitDetermination", Quantity(4.5, Unit(text="km")), 21))
    except Exception as e:  # noqa: BLE001
        print("calc quantity ->", type(e).__name__, str(e).splitlines()[0][:200])
    try:
        print("eval no context:", mb.eval("OrbitDetermination(4.5 [km], 21)"))
    except Exception as e:  # noqa: BLE001
        print("eval no context ->", type(e).__name__, str(e).splitlines()[0][:200])
    print("eval with context:", mb.eval("OrbitDetermination(4.5 [km], 21)", context="TethysGroundSoftware"))
