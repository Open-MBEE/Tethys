"""Meridian Operations Suite — the ground software of the Tethys mission (``TethysGroundSoftware``).

One subpackage per component of model 69, each class named for the model's part and documented
with the model's qualified name; every table it reads comes from ``argent_tables`` (generated
from the model), every model evaluation goes through :mod:`meridian.modelbridge`.
"""

from .suite import MeridianOperationsSuite  # noqa: F401

__all__ = ["MeridianOperationsSuite"]
