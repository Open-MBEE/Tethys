"""The suite's model bridge: every model evaluation goes through the pinned OpenSysML Python client
against a ``sysml-grpc`` service built from the pinned checkout.

Nothing here reimplements a model calculation. ``ModelBridge.calc`` invokes a ``calc def`` by its
qualified name with positional arguments, ``eval`` evaluates an expression against an instantiated
subject (as ``runs/sw-ground-*.txt`` were recorded), and every call records its wall-clock time so
tests can report what the model costs.
"""

from __future__ import annotations

import glob
import os
import time
from dataclasses import dataclass, field

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
DEFAULT_BINARY = os.path.join(ROOT, "build", "opensysml", "sysml-grpc")
MODEL_DIR = os.path.join(ROOT, "model")


def model_files(model_dir: str = MODEL_DIR) -> list[str]:
    """The model's files in the order the generator and ``scripts/runs.sh`` load them."""
    return sorted(glob.glob(os.path.join(model_dir, "*.kerml"))) + sorted(glob.glob(os.path.join(model_dir, "*.sysml")))


@dataclass
class Timing:
    operation: str
    target: str
    seconds: float


@dataclass
class ModelBridge:
    """A connection to a private ``sysml-grpc`` service with the whole model parsed once.

    The service binary is ``$OPENSYSML_BINARY`` or ``build/opensysml/sysml-grpc``; the client
    starts it as a private child and stops it with ``close()``.
    """

    binary: str = DEFAULT_BINARY
    model_dir: str = MODEL_DIR
    timings: list[Timing] = field(default_factory=list)
    _connection: object = None
    _model: object = None

    def open(self) -> "ModelBridge":
        import opensysml

        if not os.environ.get("OPENSYSML_BINARY"):
            os.environ["OPENSYSML_BINARY"] = self.binary
        t0 = time.monotonic()
        self._connection = opensysml.connect()
        self.timings.append(Timing("connect", self.binary, time.monotonic() - t0))
        files = model_files(self.model_dir)
        t0 = time.monotonic()
        self._model = self._connection.parse_sources(files)
        self.timings.append(Timing("parse_sources", f"{len(files)} files", time.monotonic() - t0))
        return self

    def close(self) -> None:
        if self._connection is not None:
            self._connection.close()
            self._connection = None
            self._model = None

    def __enter__(self):
        return self.open()

    def __exit__(self, *exc):
        self.close()

    @property
    def model(self):
        if self._model is None:
            self.open()
        return self._model

    def eval(self, expression: str, subject: str | None = None, context: str | None = None):
        """Evaluate ``expression`` in the model: in the scope of ``context`` (a package or
        element whose imports the expression's names and units resolve through) and against
        ``subject`` when one is named."""
        t0 = time.monotonic()
        try:
            return self.model.eval(expression, context_symbol_id=context, subject=subject)
        finally:
            self.timings.append(Timing("eval", expression, time.monotonic() - t0))

    def calc(self, symbol: str, *arguments):
        """Invoke a ``calc def`` by qualified name with positional arguments; the returned value."""
        t0 = time.monotonic()
        try:
            result = self.model.calc(symbol, arguments=list(arguments))
        finally:
            self.timings.append(Timing("calc", symbol, time.monotonic() - t0))
        return getattr(result, "value", result)

    def execute_action(self, symbol: str, **inputs):
        t0 = time.monotonic()
        try:
            return self.model.execute_action(symbol, inputs=inputs or None)
        finally:
            self.timings.append(Timing("execute_action", symbol, time.monotonic() - t0))

    def total_seconds(self) -> float:
        return sum(t.seconds for t in self.timings)


def magnitude(value):
    """The number inside a client value: a Quantity's magnitude, a one-element list's element."""
    if isinstance(value, list) and len(value) == 1:
        return magnitude(value[0])
    for attr in ("magnitude", "value"):
        if hasattr(value, attr) and not isinstance(value, (int, float, str, bool)):
            return magnitude(getattr(value, attr))
    return value
