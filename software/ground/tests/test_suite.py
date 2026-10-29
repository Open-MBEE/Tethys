"""The suite's structure against runs/sw-ground-structure.txt (TethysGroundSoftware::meridianOperationsSuite)."""

from conftest import literal, number

from argent_tables import ground
from meridian import MeridianOperationsSuite

S = "TethysGroundSoftware::meridianOperationsSuite"


def test_component_count_and_product_names(structure):
    suite = MeridianOperationsSuite()
    assert suite.component_count == int(number(structure[f"{S}.componentCount"]))
    names = [n.strip().strip('"') for n in structure[f"{S}.productNames"].strip("[]").split(",")]
    assert suite.product_names == names
    assert suite.simulator_count == int(number(structure[f"{S}.simulatorCount"]))


def test_every_component_names_its_model_part():
    suite = MeridianOperationsSuite()
    for component, row in zip(suite.components, ground.GROUND_COMPONENTS):
        assert component.model.definition == row.definition and component.product_name == row.product_name


def test_verdict_enums_match_model():
    assert [v.name.lower().replace("_", "") for v in ground.CommandVerdict] == [l.lower() for l in ("accepted", "unknownOpcode", "argumentOutOfRange", "modeNotAllowed", "awaitingSecondApproval")]
    assert literal("[CommandVerdict::accepted]") == "accepted"
